import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy, 'jwt') {
  constructor() {
    super({
      jwtFromRequest: ExtractJwt.fromExtractors([
        (request: any) => request?.cookies?.['access_token'],
      ]),
      secretOrKey: process.env.JWT_SECRET || 'dev_secret_key',
      ignoreExpiration: false,
    });
  }

  async validate(payload: any) {
    // console.log('JWT PAYLOAD:', payload);
    return {
      userId: payload.userId,
      clientCode: payload.clientCode,
      userCode: payload.userCode,
    };
  }
}