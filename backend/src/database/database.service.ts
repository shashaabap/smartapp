// src/database/database.service.ts
import { Injectable, OnModuleDestroy } from '@nestjs/common';
import { Pool, PoolClient } from 'pg';

@Injectable()
export class DatabaseService implements OnModuleDestroy {
  private pool: Pool;

  constructor() {
    this.pool = new Pool({
      host: process.env.DB_HOST,
      port: Number(process.env.DB_PORT),
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      max: 10,
      idleTimeoutMillis: 30000,
      connectionTimeoutMillis: 2000,
    });
  }

  /* ================= BASIC QUERY ================= */

  async query<T = any>(sql: string, params: any[] = []): Promise<T[]> {
    const result = await this.pool.query(sql, params);
    return result.rows;
  }

  /* ================= FUNCTION CALL ================= */

  async callFunction<T>(
    functionName: string,
    params: any[],
    client?: PoolClient, // 👈 allows transaction usage
  ): Promise<T> {
    const placeholders = params.map((_, i) => `$${i + 1}`).join(',');
    const sql = `SELECT ${functionName}(${placeholders}) AS result`;

    const executor = client ?? this.pool;
    const result = await executor.query(sql, params);

    return result.rows[0]?.result as T;
  }

  /* ================= GET RAW CLIENT ================= */

  async getClient(): Promise<PoolClient> {
    return this.pool.connect();
  }

  /* ================= CENTRALIZED TRANSACTION ================= */

  async withTransaction<T>(
  clientId: number,
  callback: (trx: {
    query: <R = any>(sql: string, params?: any[]) => Promise<R[]>;
    callFunction: <R = any>(fn: string, params: any[]) => Promise<R>;
  }) => Promise<T>,
): Promise<T> {
  const client = await this.pool.connect();

  try {
    await client.query('BEGIN');

    // 🔥 SET TENANT CONTEXT
await client.query(`SET LOCAL app.client_id = '${clientId}'`);

    const trx = {
      query: async <R = any>(sql: string, params: any[] = []) => {
        const res = await client.query(sql, params);
        return res.rows as R[];
      },

      callFunction: async <R = any>(fn: string, params: any[]) => {
        const placeholders = params.map((_, i) => `$${i + 1}`).join(',');
        const sql = `SELECT ${fn}(${placeholders}) AS result`;
        const res = await client.query(sql, params);
        return res.rows[0]?.result as R;
      },
    };

    const result = await callback(trx);

    await client.query('COMMIT');

    return result;
  } catch (error) {
    await client.query('ROLLBACK');
    throw error;
  } finally {
    client.release();
  }
}

  /* ================= CLEAN SHUTDOWN ================= */

  async onModuleDestroy() {
    await this.pool.end();
  }
}