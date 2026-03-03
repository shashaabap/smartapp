import { 
  Controller, Post, Body, Get, Req, UseGuards, Res 
} from '@nestjs/common';
import { AuthService, ApiResponse } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import type { Request, Response } from 'express';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('login')
  async login(
    @Req() req: Request,
    @Body() dto: LoginDto,
    @Res({ passthrough: true }) res: Response
  ) {
    const result = await this.authService.login(req, dto);
    
        res.cookie('access_token', result.token, {
          httpOnly: true,
          secure: false,          // VERY IMPORTANT for http
          sameSite: 'lax',
          maxAge: 8 * 60 * 60 * 1000,
        });

    const { token, ...responseData } = result;
    return responseData;
  }

  @UseGuards(JwtAuthGuard)
  @Get('me')
  async me(@Req() req: Request) {
    const { clientCode, userCode } = req.user as any;
    return this.authService.getMe(clientCode, userCode);
  }

  // Bootstrap endpoint for dynamic navigation
  @UseGuards(JwtAuthGuard)
  @Get('bootstrap')
  async bootstrap(@Req() req: Request) {
    // Fixed: Use consistent access pattern from your JWT guard/middleware
    const { clientCode, userCode } = req.user as any;
    return this.authService.bootstrap(clientCode, userCode);
  }

  @Post('logout')
  logout(@Res({ passthrough: true }) res: Response) {
    res.clearCookie('access_token', {
      httpOnly: true,
      sameSite: 'lax',
    });

    return { message: 'Logged out' };
  }
}
