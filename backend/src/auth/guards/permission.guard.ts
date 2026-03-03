import {
  CanActivate,
  ExecutionContext,
  Injectable,
  ForbiddenException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { PermissionService } from '../permission.service';
import { PERMISSION_KEY, PageControlPermission } from '../decorators/has-permission.decorator';

@Injectable()
export class PermissionGuard implements CanActivate {
  constructor(
    private reflector: Reflector,
    private permissionService: PermissionService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const permission =
      this.reflector.getAllAndOverride<PageControlPermission>(
        PERMISSION_KEY,
        [context.getHandler(), context.getClass()],
      );

    if (!permission) {
      return true;
    }

    const request = context.switchToHttp().getRequest();

    if (!request.user) {
      throw new ForbiddenException('Unauthenticated');
    }

    const { clientCode, userCode, roles = [] } = request.user;

    // 🔓 ROLE-BASED ADMIN BYPASS (SAFE)
    if (roles.includes('admin')) {
      return true;
    }

    await this.permissionService.enforcePageControlAccess(
      clientCode,
      userCode,
      permission.pageCode,
      permission.controlCode,
    );

    return true;
  }
}