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
                        value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' http://82.202.159.64:* https://storage.yandexcloud.net https://*.tile.openstreetmap.org https://cdnjs.cloudflare.com http://localhost:* http://127.0.0.1:* https://upload.wikimedia.org https://*.wikimedia.org https://commons.wikimedia.org https://i.imgur.com https://*.flickr.com https://live.staticflickr.com data: blob: *; media-src 'self' http://82.202.159.64:* https://storage.yandexcloud.net http://localhost:* https://upload.wikimedia.org data: blob:; connect-src 'self' http://82.202.159.64:* http://localhost:* http://127.0.0.1:* ws://localhost:* https://*.tile.openstreetmap.org https://nominatim.openstreetmap.org;"
                    }
                ]
            }
        ];
    },
};

module.exports = nextConfig;
