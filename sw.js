/* 7 Barber — service worker
   Responsável por mostrar a notificação push mesmo com o site fechado.
   Ele "acorda" quando o navegador recebe um push do servidor (via
   Supabase Edge Function), então isso funciona enquanto o celular/PC
   tiver internet e o navegador puder ser acordado pelo sistema —
   não precisa estar com a aba do site aberta. */

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(self.clients.claim());
});

self.addEventListener('push', (event) => {
  let data = {};
  try {
    data = event.data ? event.data.json() : {};
  } catch (e) {
    data = { title: '💈 7 Barber', body: event.data ? event.data.text() : 'Novo agendamento' };
  }

  const title = data.title || '💈 Novo agendamento — mais uma venda!';
  const options = {
    body: data.body || '',
    icon: data.icon || undefined,
    badge: data.badge || undefined,
    tag: data.tag || 'novo-agendamento',
    data: { url: data.url || '/' },
    requireInteraction: true
  };

  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const targetUrl = (event.notification.data && event.notification.data.url) || '/';
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clients) => {
      for (const client of clients) {
        if ('focus' in client) return client.focus();
      }
      if (self.clients.openWindow) return self.clients.openWindow(targetUrl);
    })
  );
});
