/** @type {import('next').NextConfig} */
const nextConfig = {
    async rewrites() {
        return [
            {
                source: '/api/proxy/:path*',
                destination: 'https://audiogid-api.vercel.app/v1/:path*',
            },
        ]
    },
};

module.exports = nextConfig;
