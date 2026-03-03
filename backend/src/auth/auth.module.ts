import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './jwt.strategy';
import { PermissionService } from './permission.service';
import { PermissionGuard } from './guards/permission.guard';
import { AuditModule } from '../audit/audit.module';

@Module({
  imports: [
    JwtModule.register({
      secret: process.env.JWT_SECRET,
      signOptions: { expiresIn: '8h' },
    }),
     AuditModule, // ✅ THIS IS THE KEY for AuditModule
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy ,PermissionService,PermissionGuard,] ,
  exports: [JwtModule, PermissionService,],
})
export class AuthModule {}
