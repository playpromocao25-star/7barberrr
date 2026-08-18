# ☁️ Como ativar o Sync na Nuvem (Supabase) — 7 Barber

Esse passo é **opcional**. O app já funciona 100% salvando tudo no navegador
(localStorage). Mas se você quiser que os dados apareçam em **todos os seus
dispositivos** (celular, computador, tablet) e fiquem seguros mesmo se o
navegador for limpo, siga esse guia — leva uns 5 minutos e é **grátis**.

---

## 1) Criar conta e projeto no Supabase

1. Acesse **[supabase.com](https://supabase.com)** e clique em **Start your project**
2. Faça login com GitHub, Google ou e-mail
3. Clique em **New project**
4. Preencha:
   - **Name**: `7barber` (ou o que quiser)
   - **Database Password**: escolha uma senha **forte** e **guarde ela** (não precisa pra usar o app, mas é bom ter)
   - **Region**: escolha o mais perto do Brasil: `South America (São Paulo)`
5. Clique em **Create new project** e aguarde 1-2 minutinhos

---

## 2) Criar as tabelas

1. No menu lateral, vá em **SQL Editor** (ícone `>_` no canto)
2. Clique em **New query**
3. Cole o conteúdo do arquivo **`supabase-schema.sql`** (que está junto deste)
4. Clique em **Run** (ou Ctrl+Enter)
5. Deve aparecer "Success. No rows returned" — tá certo

---

## 3) Pegar a URL e a chave

1. No menu lateral, vá em **Settings → API** (ícone de engrenagem)
2. Em **Project URL**, copie o valor (começa com `https://xxxxx.supabase.co`)
3. Em **Project API keys**, na linha **anon / public**, clique em **Copy** (a chave é um texto longo que começa com `eyJ...`)
4. **NÃO** use a chave `service_role` — ela dá acesso total ao banco, perigoso

---

## 4) Colar no app

1. Abra o site da 7 Barber
2. Vá em **Painel do administrador** (digite a senha)
3. Clique na aba **Dados**
4. Cole:
   - **URL do projeto Supabase**: a URL que você copiou
   - **Chave anon public**: a chave `eyJ...` que você copiou
5. Clique em **Ativar sync na nuvem**
6. Deve aparecer um toast verde confirmando ✅

---

## 5) Subir os dados atuais pra nuvem

1. Ainda na aba **Dados**, clique em **☁️ Enviar tudo pra nuvem agora**
2. Pronto! Tudo que você já tinha no navegador agora também tá na nuvem

A partir de agora, qualquer:
- novo agendamento
- novo serviço
- nova configuração de notificação
- alteração de horário

…é salvo **automaticamente** na nuvem, e aparece em todos os seus dispositivos.

---

## Como funciona o "sync entre dispositivos"

- **Cenário A — um celular + um computador**: você configura o Supabase nos
  dois. Quando alguém agenda pelo celular, o computador já vê na hora que
  abrir a aba. E vice-versa.
- **Cenário B — sua esposa também administra**: ela também configura o
  Supabase no celular dela com a mesma URL + chave. Ela vê tudo que você fez,
  e vice-versa.
- **Modo offline**: mesmo sem internet, o app continua funcionando (dados
  ficam no localStorage). Quando voltar a internet, os dados sobem pra
  nuvem automaticamente.

---

## Backup local (sempre recomendado!)

Mesmo com a nuvem, faça backup local de vez em quando:

1. Aba **Dados → Baixar backup (arquivo .json)**
2. Salve o arquivo em algum lugar seguro (Google Drive, e-mail, pendrive)
3. Se acontecer algum problema, é só clicar em **Restaurar de um arquivo .json**

---

## Dúvidas comuns

**Os dados ficam seguros?**
- Sim, ficam no Supabase (que é usado por empresas grandes). Mas se você
  expor a `anon key` publicamente, qualquer pessoa poderia ver/modificar os
  dados — por isso, **não compartilhe sua chave anon em lugar nenhum** (só no
  app mesmo, que usa ela pra funcionar).

**Quanto custa?**
- O plano gratuito do Supabase dá 500 MB de banco + 2 GB de tráfego por mês.
  Pra uma barbearia com agendamentos, isso dá pra **anos** de uso.

**Posso trocar de projeto Supabase depois?**
- Sim, é só criar outro projeto, rodar o SQL, e colar as novas credenciais
  na aba Dados do app.

**E se eu quiser parar de usar a nuvem?**
- Aba Dados → **Desconectar da nuvem**. Os dados continuam salvos no
  localStorage. Você pode reconectar a qualquer momento.

---

## Conteúdo do arquivo `supabase-schema.sql`

Se preferir, aqui está o SQL completo pra você colar no SQL Editor:

```sql
-- Tabela de serviços (corte, barba, etc.)
create table if not exists services (
  id text primary key,
  name text not null,
  price numeric not null default 0
);

-- Tabela de dias (horários disponíveis + agendamentos)
create table if not exists days (
  iso text primary key,         -- ex: 2026-08-18
  available jsonb not null default '[]'::jsonb,   -- ["08:00","08:30",...]
  bookings jsonb not null default '{}'::jsonb    -- {"08:00": {nome, telefone, ...}}
);

-- Tabela de configurações (notificações, etc.)
create table if not exists settings (
  id text primary key,
  value jsonb not null
);

-- Libera acesso público (anon) — o app se conecta direto do navegador
alter table services enable row level security;
alter table days enable row level security;
alter table settings enable row level security;

create policy "public read services" on services for select using (true);
create policy "public write services" on services for all using (true) with check (true);

create policy "public read days" on days for select using (true);
create policy "public write days" on days for all using (true) with check (true);

create policy "public read settings" on settings for select using (true);
create policy "public write settings" on settings for all using (true) with check (true);
```

> ⚠️ As policies acima liberam leitura/escrita pública. Pra uma barbearia
> com agendamentos isso é OK, mas se quiser restringir mais (por exemplo,
> só a aba admin pode escrever), é só me avisar que eu ajusto.
