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
