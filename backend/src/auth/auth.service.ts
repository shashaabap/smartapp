import { Injectable, UnauthorizedException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { LoginDto } from './dto/login.dto';
import * as jwt from 'jsonwebtoken';
import { AuditService } from '../audit/audit.service';
import { RedisService } from '../redis/redis.service';
import { Request } from 'express';

// Define the expected response structure from your PostgreSQL functions


export interface ApiResponse {
  error_id: number;
  error_message?: string;
  client?: {
    client_id: number;
    client_code: string;  // 👈 ADD THIS
    client_name: string;
  };
  user?: {
    id: number;
    user_code: string;
    user_name: string;
    email: string;
    failed_attempts: number;
    last_failed_login?: string | null;
    client_code?: string;  // 👈 ADD THIS (optional)
  };
  permissions?: any;
  roles?: any;
}



@Injectable()
export class AuthService {
  constructor(
    private readonly db: DatabaseService,
    private readonly auditService: AuditService,
    private readonly redisService: RedisService,
  ) {}

  async login(req: Request, dto: LoginDto) {
    const hostname = req.hostname; // filatex.smartapp.com
    const parts = hostname.split('.');
    const clientCode = parts.length > 2 ? parts[0] : 'local';
    // 1️⃣ Validate login (read-only, outside transaction)
    const loginResult: ApiResponse = await this.db.callFunction<ApiResponse>(
      'fn_validate_user_login_json',
      [clientCode, dto.userCode, dto.password],
    );
// console.log("Hostname:", req.hostname);
// console.log("Extracted clientCode:", clientCode);
    if (!loginResult || loginResult.error_id !== 0) {
      throw new UnauthorizedException(loginResult?.error_message || 'Invalid credentials');
    }

    const { client, user } = loginResult;
    if (!user || !client) {
      throw new UnauthorizedException('Invalid user or client data');
    }

    // 2️⃣ Lock check
    const isLocked =
      user.failed_attempts >= 5 &&
      user.last_failed_login &&
      new Date(user.last_failed_login).getTime() > Date.now() - 15 * 60 * 1000;

    if (isLocked) {
      await this.auditService.log({
        clientId: client.client_id,
        userId: user.id,
        action: 'LOGIN_LOCKED',
        entity: 'users',
      });
      throw new UnauthorizedException('Account temporarily locked. Try again after 15 minutes.');
    }

    // 3️⃣✅ TRANSACTION: Reset attempts + Audit log (atomic!)
    await this.db.withTransaction(client.client_id, async (trx) => {
      // Reset failed attempts & update login time
      await trx.query(
        `
        UPDATE users
        SET failed_attempts = 0,
            last_failed_login = NULL,
            last_login = now()
        WHERE client_id = $1 AND 
        user_code = $2
        `,
        [client.client_id, user.user_code],
      );

      // Direct audit log (transaction-safe)
      await trx.query(
        `
        INSERT INTO audit_log (client_id, user_id, action, entity, entity_id, created_dt)
        VALUES ($1, $2, $3, $4, $5, now())
        `,
        [client.client_id, user.id, 'LOGIN', 'users', user.id],
      );
    });

    // 4️⃣ Fetch access (read-only)
    const accessResult: ApiResponse = await this.db.callFunction<ApiResponse>(
      'fn_get_user_access_json',
      [clientCode, dto.userCode],
    );
    // 🔥 CACHE PERMISSIONS
      const cacheKey = `perm:${clientCode}:${dto.userCode}`;

      if (accessResult?.permissions) {
        await this.redisService.set(
          cacheKey,
          JSON.stringify(accessResult.permissions),
          60 * 60, // 1 hour TTL
        );
      }

    if (!accessResult || accessResult.error_id !== 0) {
      throw new UnauthorizedException('Access resolution failed');
    }

    // 5️⃣ JWT Token
          const token = jwt.sign(
            {
              userId: user.id,
              clientCode: clientCode,
              userCode: dto.userCode,
            },
            process.env.JWT_SECRET!,
            { expiresIn: '8h' },
          );

        return {
          token,
          user: { 
            clientCode: clientCode, 
            userCode: dto.userCode,
            role: accessResult.roles?.[0] || 'EMPLOYEE'  // 👈 Single role for UI
          }
        };

  }

  // 👤 GET LOGGED-IN USER (for protected routes)
        async getMe(clientCode: string, userCode: string) {
          const accessResult: ApiResponse = await this.db.callFunction<ApiResponse>(
            'fn_get_user_access_json',
            [clientCode, userCode],
          );

          if (!accessResult || accessResult.error_id !== 0) {
            throw new UnauthorizedException('Invalid or expired session');
          }

          return {
            user: {
              clientCode,
              userCode,
              role: accessResult.roles?.[0] || 'EMPLOYEE',
            },
            permissions: accessResult.permissions,  // 👈 separate
          };
        }


  // 🆕 BOOTSTRAP - Dynamic navigation from PostgreSQL function

async bootstrap(clientCode: string, userCode: string): Promise<any> {
  // console.log('BOOTSTRAP CALLED WITH:', clientCode, userCode);

  const result = await this.db.callFunction<any>(
    'fn_get_user_bootstrap_json',
    [clientCode, userCode],
  );

  if (!result) {
    throw new UnauthorizedException('Bootstrap data load failed');
  }

  return result; // 👈 Return directly
}
      
}
