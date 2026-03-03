import { SetMetadata } from '@nestjs/common';

export const PERMISSION_KEY = 'page_control_permission';

export interface PageControlPermission {
  pageCode: string;
  controlCode: string;
}

export const HasPermission = (
  pageCode: string,
  controlCode: string,
) =>
  SetMetadata(PERMISSION_KEY, {
    pageCode,
    controlCode,
  } as PageControlPermission);
