-- ============================================================
-- 7 Barber — schema do Supabase (banco de dados na nuvem)
-- ============================================================
-- Como usar:
--   1) Acesse supabase.com e crie um projeto gratuito
--   2) No menu lateral, abra "SQL Editor"
--   3) Cole este arquivo inteiro e clique em "Run"
--   4) Vá em Settings → API e copie a URL + a chave "anon public"
--   5) Cole as duas no app (Painel admin → aba "Dados")
-- ============================================================

-- Tabela de serviços (corte, barba, etc.)
create table if not exists services (
  id text primary key,
  name text not null,
  price numeric not null default 0
);

-- Tabela de dias (horários disponíveis + agendamentos)
create table if not exists days (
  iso text primary key,                          -- ex: '2026-08-18'
  available jsonb not null default '[]'::jsonb, -- ['08:00','08:30',...]
  bookings jsonb not null default '{}'::jsonb   -- {'08:00': {nome, telefone, ...}}
);

-- Tabela de configurações (notificações, etc.)
create table if not exists settings (
  id text primary key,
  value jsonb not null
);

-- Libera acesso público (anon key) — o app conecta direto do navegador
alter table services enable row level security;
alter table days enable row level security;
alter table settings enable row level security;

drop policy if exists "public all services" on services;
create policy "public all services" on services
  for all using (true) with check (true);

drop policy if exists "public all days" on days;
create policy "public all days" on days
  for all using (true) with check (true);

drop policy if exists "public all settings" on settings;
create policy "public all settings" on settings
  for all using (true) with check (true);

-- ============================================================
-- PUSH NOTIFICATIONS (pop-up mesmo com o site fechado)
-- ============================================================

-- Guarda a "inscrição" de push de cada dispositivo do admin
-- (gerada pelo navegador quando ele clica em "Ativar notificações").
create table if not exists push_subscriptions (
  id uuid primary key default gen_random_uuid(),
  endpoint text not null unique,
  subscription jsonb not null,   -- objeto completo devolvido por pushManager.subscribe()
  created_at timestamptz not null default now()
);

alter table push_subscriptions enable row level security;

drop policy if exists "public all push_subscriptions" on push_subscriptions;
create policy "public all push_subscriptions" on push_subscriptions
  for all using (true) with check (true);

-- Um evento é inserido aqui a cada novo agendamento (pelo navegador do
-- cliente, no momento em que ele confirma). Um Database Webhook do
-- Supabase (configurado no painel, aba Database → Webhooks) escuta
-- INSERT nesta tabela e chama a Edge Function "send-push", que manda
-- o pop-up de verdade pra todos os dispositivos inscritos em
-- push_subscriptions — mesmo que o navegador do admin esteja fechado.
create table if not exists booking_events (
  id uuid primary key default gen_random_uuid(),
  iso text not null,
  time text not null,
  service_name text,
  price numeric,
  client_name text,
  created_at timestamptz not null default now()
);

alter table booking_events enable row level security;

drop policy if exists "public insert booking_events" on booking_events;
create policy "public insert booking_events" on booking_events
  for insert with check (true);

drop policy if exists "public read booking_events" on booking_events;
create policy "public read booking_events" on booking_events
  for select using (true);
