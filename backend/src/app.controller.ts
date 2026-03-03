import { Controller, Get, Req, UseGuards } from '@nestjs/common';
import { AppService } from './app.service';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  // Public endpoint (no auth)
  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  // Protected endpoint (JWT required)
  @UseGuards(JwtAuthGuard)
  @Get('secure')
  getSecure(@Req() req) {
    return {
      message: 'You are authenticated',
      user: req.user, // comes from JwtStrategy.validate()
    };
  }
}
