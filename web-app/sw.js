const CACHE = 'fast-reader-v3';

const APP_SHELL = [
    './',
    'index.html',
    'css/style.css',
    'js/app.js',
    'js/reader.js',
    'js/extractor.js',
    'manifest.json',
    'icons/icon-192.png',
    'icons/icon-512.png',
];

// Install: pre-cache the app shell
self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE)
            .then(cache => cache.addAll(APP_SHELL))
            .then(() => self.skipWaiting())
    );
});

// Activate: clean old caches
self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(keys =>
            Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
        ).then(() => self.clients.claim())
    );
});

// Fetch: cache-first for app shell, network-first for everything else
self.addEventListener('fetch', event => {
    const url = new URL(event.request.url);

    // Only handle same-origin GET requests with cache-first
    if (event.request.method !== 'GET') return;

    // For CDN resources (pdf.js), use network-first + cache
    if (url.origin !== self.location.origin) {
        event.respondWith(
            fetch(event.request)
                .then(res => {
                    const clone = res.clone();
                    caches.open(CACHE).then(c => c.put(event.request, clone));
                    return res;
                })
                .catch(() => caches.match(event.request))
        );
        return;
    }

    // App shell: cache-first
    event.respondWith(
        caches.match(event.request).then(cached => {
            if (cached) return cached;
            return fetch(event.request).then(res => {
                const clone = res.clone();
                caches.open(CACHE).then(c => c.put(event.request, clone));
                return res;
            });
        })
    );
});
