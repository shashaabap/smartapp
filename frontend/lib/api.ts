// frontend/lib/api.ts
import { config } from './config';

export async function apiFetch(endpoint: string, options: RequestInit = {}) {
  const url = `${config.API_URL}${endpoint.startsWith('/') ? '' : '/'}${endpoint}`;
  
  const res = await fetch(url, {
    ...options,
    credentials: 'include',
    headers: {
      'Content-Type': 'application/json',
      ...options.headers,
    },
  });

  if (!res.ok) {
    const error = await res.json().catch(() => ({ message: 'Unknown error' }));
    throw new Error(error.message || 'API error');
  }

  return res.json();
}

// Usage: apiFetch('/auth/me') anywhere in your app!
