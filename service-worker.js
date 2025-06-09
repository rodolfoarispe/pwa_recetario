const CACHE_NAME = 'apppreto-v39';
const urlsToCache = [
  './',
  './index.html',
  './recetario.jpg',
  './html2canvas.min.js',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  './favicon.ico',
  './apple-touch-icon-180x180.png'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(urlsToCache))
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request).then(response => response || fetch(event.request))
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.map(key => {
          if (key !== CACHE_NAME) return caches.delete(key);
        })
      )
    )
  );
});
