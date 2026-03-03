import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';

@Injectable()
export class ClientMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const hostname = req.hostname; 
    // filatex.smartapp.com

    const parts = hostname.split('.');

    if (parts.length > 2) {
      req['clientCode'] = parts[0];  // filatex
    } else {
      req['clientCode'] = 'local';   // fallback
    }

    next();
  }
}