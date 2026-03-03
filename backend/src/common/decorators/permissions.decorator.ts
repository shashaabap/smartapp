import { SetMetadata } from '@nestjs/common';

export const PERMISSIONS_KEY = 'permissions';

export const Permissions = (...controls: string[]) =>
  SetMetadata(PERMISSIONS_KEY, controls);