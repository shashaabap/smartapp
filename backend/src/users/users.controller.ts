import { Controller, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('admin/users')
@UseGuards(JwtAuthGuard)  // Only JWT for now
export class UsersController {

  @Post()
  createUser() {
    return { message: 'User created successfully' };
  }

}