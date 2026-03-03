import { Injectable, ForbiddenException } from '@nestjs/common';
import { DatabaseService } from '../database/database.service';
import { RedisService } from '../redis/redis.service';

@Injectable()
export class PermissionService {
  constructor(private readonly db: DatabaseService,
              private readonly redisService: RedisService
  ) {}

  // async hasPageControlAccess(
  //   clientCode: string,
  //   userCode: string,
  //   pageCode: string,
  //   controlCode: string,
  // ): Promise<boolean> {
  //   const res = await this.db.query(
  //     'SELECT fn_has_page_control_access($1, $2, $3, $4) AS allowed',
  //     [clientCode, userCode, pageCode, controlCode],
  //   );

  //   return res[0]?.allowed === true;
  // }

async hasPageControlAccess(
  clientCode: string,
  userCode: string,
  pageCode: string,
  controlCode: string,
): Promise<boolean> {

  const cacheKey = `perm:${clientCode}:${userCode}`;

  const cached = await this.redisService.get(cacheKey);

  if (cached) {
    const permissions = JSON.parse(cached);

    const allowed = permissions.controls?.some(
      (c) =>
        c.page_code === pageCode &&
        c.control_code === controlCode,
    );

    return !!allowed;
  }

  // 🔁 Fallback to DB if cache missing
  const allowed = await this.db.callFunction<boolean>(
    'fn_has_page_control_access',
    [clientCode, userCode, pageCode, controlCode],
  );

  return allowed;
}



  async enforcePageControlAccess(
    clientCode: string,
    userCode: string,
    pageCode: string,
    controlCode: string,
  ) {
    const allowed = await this.hasPageControlAccess(
      clientCode,
      userCode,
      pageCode,
      controlCode,
    );

    if (!allowed) {
      throw new ForbiddenException(
        `Access denied → ${pageCode} : ${controlCode}`,
      );
    }
  }
}
