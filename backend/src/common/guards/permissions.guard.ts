import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PERMISSIONS_KEY } from '../decorators/permissions.decorator';
import { DatabaseService } from '../../database/database.service';

@Injectable()
export class PermissionsGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private databaseService: DatabaseService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const requiredPermissions = this.reflector.getAllAndOverride<string[]>(
      PERMISSIONS_KEY,
      [
        context.getHandler(),
        context.getClass(),
      ],
    );

    if (!requiredPermissions) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      throw new ForbiddenException('Unauthorized');
    }

    const route = request.route.path; // example: /admin/users

    // 🔥 Query DB for permission check
    const result = await this.databaseService.query(
      `
      SELECT 1
      FROM users_roles_mapping urm
      JOIN role_page_control_access rpca
        ON rpca.role_id = urm.role_id
      JOIN pages p
        ON p.id = rpca.page_id
      JOIN controls c
        ON c.id = rpca.control_id
      WHERE urm.user_id = $1
        AND p.api_base_path = $2
        AND c.control_code = ANY($3)
        AND rpca.can_access = TRUE
      LIMIT 1
      `,
      [user.userId, route, requiredPermissions],
    );

    if (result.length === 0) {
      throw new ForbiddenException('Access denied');
    }

    return true;
  }
}