import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';
import vue from '@vitejs/plugin-vue';
import tailwindcss from '@tailwindcss/vite';
import { VitePWA } from 'vite-plugin-pwa';

export default defineConfig({
    test: {
        environment: 'happy-dom',
        include: ['tests/js/**/*.spec.js'],
        // The '@' alias is injected by laravel-vite-plugin (same config used
        // by vitest), so imports like '@/lib/utils' resolve in tests too.
        resolve: {
            alias: {
                '@': '/resources/js',
            },
        },
    },
    plugins: [
        laravel({
            input: 'resources/js/app.js',
            refresh: true,
        }),
        tailwindcss(),
        vue({
            template: {
                transformAssetUrls: {
                    base: null,
                    includeAbsolute: false,
                },
            },
        }),
        VitePWA({
            registerType: 'autoUpdate',
            injectRegister: false,
            includeAssets: [
                'favicon.svg',
                'favicon.ico',
                'apple-touch-icon.png',
                'pwa-512x512.png',
                'pwa-maskable-512x512.png',
            ],
            manifest: {
                name: 'Dental Record',
                short_name: 'Dental',
                description: 'Dental clinic patient record system',
                theme_color: '#0d9298',
                background_color: '#ffffff',
                display: 'standalone',
                scope: '/',
                start_url: '/',
                icons: [
                    { src: '/favicon-192x192.png', sizes: '192x192', type: 'image/png' },
                    { src: '/pwa-512x512.png', sizes: '512x512', type: 'image/png' },
                    { src: '/pwa-maskable-512x512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
                    { src: '/apple-touch-icon.png', sizes: '180x180', type: 'image/png' },
                ],
            },
            workbox: {
                globPatterns: ['**/*.{js,css,woff2,woff,svg,png,ico}'],
                // App shell: the server-rendered Inertia shell is fetched at SW
                // install time so the app still opens offline (login screen).
                navigateFallback: '/',
                navigateFallbackDenylist: [/^\/storage\//],
                additionalManifestEntries: ['/'],
                // Patient data (signatures, radiographs) is NEVER cached.
                runtimeCaching: [
                    {
                        urlPattern: /\/storage\//,
                        handler: 'NetworkOnly',
                    },
                ],
                cleanupOutdatedCaches: true,
            },
        }),
    ],
});
