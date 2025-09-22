const CACHE_NAME = 'votantes-pwa-v1';
const urlsToCache = [
    '/votantes-pwa/',
    '/votantes-pwa/index.html',
    '/votantes-pwa/styles.css',
    '/votantes-pwa/app.js',
    '/votantes-pwa/manifest.json',
    'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css',
    'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css',
    'https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js'
];

// Instalar Service Worker y cachear recursos
self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => {
                console.log('Cache abierto');
                return cache.addAll(urlsToCache);
            })
    );
});

// Activar Service Worker y limpiar caches antiguos
self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (cacheName !== CACHE_NAME) {
                        console.log('Eliminando cache antiguo:', cacheName);
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
});

// Interceptar peticiones y servir desde cache cuando sea posible
self.addEventListener('fetch', event => {
    // No cachear peticiones a la API
    if (event.request.url.includes('/api/')) {
        event.respondWith(
            fetch(event.request).catch(() => {
                return new Response(JSON.stringify({
                    error: 'Sin conexión a internet'
                }), {
                    headers: { 'Content-Type': 'application/json' }
                });
            })
        );
        return;
    }

    // Para otros recursos, usar cache con fallback a red
    event.respondWith(
        caches.match(event.request)
            .then(response => {
                // Retornar desde cache si existe
                if (response) {
                    return response;
                }

                // Si no está en cache, hacer petición a la red
                return fetch(event.request).then(response => {
                    // No cachear respuestas no válidas
                    if (!response || response.status !== 200 || response.type !== 'basic') {
                        return response;
                    }

                    // Clonar la respuesta porque solo se puede consumir una vez
                    const responseToCache = response.clone();

                    // Agregar al cache para uso futuro
                    caches.open(CACHE_NAME)
                        .then(cache => {
                            cache.put(event.request, responseToCache);
                        });

                    return response;
                });
            })
            .catch(() => {
                // Si falla tanto cache como red, mostrar página offline
                if (event.request.destination === 'document') {
                    return new Response(`
                        <!DOCTYPE html>
                        <html>
                        <head>
                            <meta charset="UTF-8">
                            <meta name="viewport" content="width=device-width, initial-scale=1.0">
                            <title>Sin Conexión</title>
                            <style>
                                body {
                                    font-family: sans-serif;
                                    display: flex;
                                    align-items: center;
                                    justify-content: center;
                                    height: 100vh;
                                    margin: 0;
                                    background: #f0f0f0;
                                }
                                .offline {
                                    text-align: center;
                                    padding: 20px;
                                }
                                .offline h1 {
                                    color: #333;
                                }
                                .offline p {
                                    color: #666;
                                }
                            </style>
                        </head>
                        <body>
                            <div class="offline">
                                <h1>⚡ Sin Conexión</h1>
                                <p>No hay conexión a internet.</p>
                                <p>La aplicación funcionará cuando se restablezca la conexión.</p>
                            </div>
                        </body>
                        </html>
                    `, {
                        headers: { 'Content-Type': 'text/html' }
                    });
                }
            })
    );
});

// Mensaje al recibir push notifications (futuro)
self.addEventListener('push', event => {
    const options = {
        body: event.data ? event.data.text() : 'Nueva notificación',
        icon: '/votantes-pwa/icon-192.png',
        badge: '/votantes-pwa/icon-192.png'
    };

    event.waitUntil(
        self.registration.showNotification('Gestión de Votantes', options)
    );
});