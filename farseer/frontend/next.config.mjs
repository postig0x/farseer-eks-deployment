/** @type {import('next').NextConfig} */
const nextConfig = {
  async rewrites() {
    return [
      {
        source: '/api/log',
        destination: 'http://backend:8000/api/log'
      }
    ]
  }
};

export default nextConfig;
