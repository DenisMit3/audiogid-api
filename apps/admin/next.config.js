/** @type {import('next').NextConfig} */
const nextConfig = {
    swcMinify: false,
    images: {
        remotePatterns: [
            {
                protocol: 'https',
                hostname: 'public.blob.vercel-storage.com',
            },
        ],
    },
    async rewrites() {
        return [
            {
                source: '/api/proxy/:path*',
                destination: (process.env.NEXT_PUBLIC_API_URL || 'https://api.audiogid.app') + '/v1/:path*',
            },
        ]
    },
    typescript: {
        ignoreBuildErrors: true,
    },
    eslint: {
        ignoreDuringBuilds: true,
    },
};

module.exports = nextConfig;
