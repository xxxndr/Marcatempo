-- Contatore tentativi falliti di risoluzione signup_code, per limitare il
-- brute-force sulla edge function self-signup (Blocco 3.2). Vedi
-- product/app.md, sezione "Ordine di creazione degli accessi".
-- Nessuna policy per authenticated: la tocca solo la edge function con la
-- secret key.

create table signup_code_attempts (
  user_id uuid primary key references auth.users(id) on delete cascade,
  failed_count integer not null default 0,
  blocked_at timestamptz,
  updated_at timestamptz not null default now()
);

alter table signup_code_attempts enable row level security;
