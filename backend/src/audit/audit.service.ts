import { Injectable, Logger, InternalServerErrorException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';

@Injectable()
export class AuditService {
  private readonly logger = new Logger(AuditService.name);

  constructor(private readonly db: DatabaseService) {}

  async log(params: {
    clientId: number;
    userId: number | null;
    action: string;
    entity: string;
    entityId?: number;
    oldValue?: any;
    newValue?: any;
    ip?: string;
    userAgent?: string;
  }) {
    try {
      await this.db.query(
        `
        INSERT INTO audit_log
        (
          client_id,
          user_id,
          action,
          entity,
          entity_id,
          old_value,
          new_value,
          ip_address,
          user_agent
        )
        VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
        `,
        [
          params.clientId,
          params.userId,
          params.action,
          params.entity,
          params.entityId || null,
          params.oldValue ? JSON.stringify(params.oldValue) : null,
          params.newValue ? JSON.stringify(params.newValue) : null,
          params.ip || null,
          params.userAgent || null,
        ],
      );
    } catch (error) {
      this.logger.error(`Audit log failed for ${params.action} on ${params.entity}:`, error);
      // Don't throw - audits are fire-and-forget to avoid breaking business logic [web:30]
      // If critical, uncomment: throw new InternalServerErrorException('Audit logging failed');
    }
  }
}
