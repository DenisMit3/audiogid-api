/** @type {import('next').NextConfig} */
const nextConfig = {
    assetPrefix: process.env.CDN_URL || '',
    swcMinify: false,
    
    // Force unique build ID to bust browser cache
    generateBuildId: async () => {
        return `build-${Date.now()}`;
    },

    images: {
        remotePatterns: [
            {
                protocol: 'http',
                hostname: '82.202.159.64',  // Cloud.ru VM
            },
            {
                protocol: 'https',
                hostname: 'storage.yandexcloud.net',  // Yandex Object Storage
            },
            {
                protocol: 'http',
                hostname: 'localhost',  // Local MinIO
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
                        value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' http://82.202.159.64:* https://storage.yandexcloud.net data: blob:; media-src 'self' http://82.202.159.64:* https://storage.yandexcloud.net data: blob:; connect-src 'self' http://82.202.159.64:8000 http://localhost:8000;"
                    }
                ]
            }
        ];
    },
};

module.exports = nextConfig;
