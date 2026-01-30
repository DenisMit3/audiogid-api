/** @type {import('next').NextConfig} */
const nextConfig = {
    assetPrefix: process.env.CDN_URL || '',
    swcMinify: false,

    images: {
        remotePatterns: [
            {
                protocol: 'https',
                hostname: 'public.blob.vercel-storage.com',
            },
        ],
    },
    async headers() {
        return [
            {
                source: '/:path*',
                headers: [
                    {
                        key: 'Content-Security-Policy',
                        value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' https://public.blob.vercel-storage.com data: blob:; media-src 'self' https://public.blob.vercel-storage.com data: blob:; connect-src 'self' https://public.blob.vercel-storage.com;"
                    }
                ]
            }
        ];
    },
};

module.exports = nextConfig;
