import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  reactStrictMode: true,
  allowedDevOrigins: [
    // 'http://filatex.smartapp.com:3000',
    // 'http://10.205.14.157:3000',
    // 'http://localhost:3000',
     'filatex.smartapp.com',
     'rabhageriaedu.smartapp.com',
    '10.205.14.157',
    'localhost',   
  
  ],
};

export default nextConfig;