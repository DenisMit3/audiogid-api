/** @type {import('next').NextConfig} */
const nextConfig = {
    async rewrites() {
        return [
            {
                source: '/api/proxy/:path*',
                destination: 'https://audiogid-api.vercel.app/:path*',
            },
        ]
    },
};

module.exports = nextConfig;
