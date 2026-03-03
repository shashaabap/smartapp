import { IsNotEmpty } from 'class-validator';

export class LoginDto {
  
  @IsNotEmpty()
  userCode: string;

  @IsNotEmpty()
  password: string;
}
