// // lib/auth.ts - Server-side authentication (ASYNC cookies)
// import { cookies } from 'next/headers';
// import { redirect } from 'next/navigation';
// import { config } from './config';

// export async function getServerAuth() {
//   // 👈 FIXED: Await cookies()
//   const cookieStore = await cookies();
//   const token = cookieStore.get('access_token')?.value;
  
//   if (!token) {
//     redirect('/login');
//   }
  
//   // Call your NestJS /auth/me using your existing config
//   const res = await fetch(`${config.API_URL}/auth/me`, {
//     headers: {
//       Cookie: `access_token=${token}`,
//     },
//   });
  
//   if (!res.ok) {
//     redirect('/login');
//   }
  
//   const data = await res.json();
//   return { user: data.user };
// }


// lib/auth.ts - Enhanced with subdomain support
import { cookies } from 'next/headers';
import { headers } from 'next/headers';
import { redirect } from 'next/navigation';
import { config } from './config';

export async function getServerAuth() {
  const cookieStore = await cookies();
  const token = cookieStore.get('access_token')?.value;
  
  if (!token) {
    redirect('/login');
  }
  
  const res = await fetch(`${config.API_URL}/auth/me`, {
    headers: {
      Cookie: `access_token=${token}`,
    },
  });
  
  if (!res.ok) {
    redirect('/login');
  }
  
  const data = await res.json();
  return { user: data.user };
}

// 👈 NEW: Extract clientCode from subdomain (for login page)
export async function getClientCode() {
  const headerStore = await headers();
  const hostname = headerStore.get('host') || 'localhost:3000';
  
  // filatex.smarapp.com → "filatex"
  // localhost → "local" 
  const subdomainMatch = hostname.match(/^([^.]+)\.(smarapp\.com|localhost)/);
  return subdomainMatch ? subdomainMatch[1] : 'local';
}

