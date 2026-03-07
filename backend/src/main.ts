
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { AppModule } from './app.module';
import cookieParser from 'cookie-parser';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  app.use(cookieParser());
  
  // app.enableCors({
  //   origin: [
  //     // 'http://localhost:3000',
  //     // 'http://localhost:3001',        // 👈 ADD
  //     // 'http://10.205.14.157:3000',    // 👈 Your IP
  //     // 'http://10.205.14.157:3001',    // 👈 ADD  
  //     // 'http://127.0.0.1:3000',
  //     // 'http://filatex.smartapp.com:3000',  // 👈 ADD Subdomain
  //     // 'http://filatex.smartapp.com:3001',  // 👈 ADD Subdomain
  //     'http://filatex.smartapp.com:3000',
  //   ],
  //   credentials: true,
  // });

  //global/wild card for all prefixed urls
  app.enableCors({
  origin: (origin, callback) => {
    if (!origin) return callback(null, true);

    if (
      origin.includes('smartapp.com') ||
      origin.includes('localhost')
    ) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
});

  await app.listen(4000, '0.0.0.0');
}
bootstrap();
