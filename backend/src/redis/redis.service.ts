import { Injectable, OnModuleDestroy, Logger } from '@nestjs/common';
import Redis from 'ioredis';

@Injectable()
export class RedisService implements OnModuleDestroy {
  private redis: Redis;
  private readonly logger = new Logger(RedisService.name);

 constructor() {
  this.redis = new Redis({
    host: '127.0.0.1',  // Fix IPv6 issue
    port: Number(process.env.REDIS_PORT) || 6379,
    family: 4,
  });

  this.redis.on('error', (err: any) => {
    if (err.code === 'ECONNREFUSED' || err.message?.includes('ECONNREFUSED')) {
      return;  // ✅ Completely silent
    }
    this.logger.error('Redis error', err);
  });

  this.redis.on('connect', () => this.logger.log('✅ Redis connected'));
}

  async get(key: string): Promise<string | null> {
    try {
      return await this.redis.get(key);
    } catch {
      return null; // Graceful fallback - no Redis? No problem
    }
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    try {
      if (ttlSeconds) {
        await this.redis.set(key, value, 'EX', ttlSeconds);
      } else {
        await this.redis.set(key, value);
      }
    } catch {
      // Silent fail - app works without cache
    }
  }

  async del(key: string): Promise<void> {
    try {
      await this.redis.del(key);
    } catch {
      // Silent fail
    }
  }

  async onModuleDestroy() {
    try {
      await this.redis.quit();
    } catch {
      // Already disconnected
    }
  }
}
