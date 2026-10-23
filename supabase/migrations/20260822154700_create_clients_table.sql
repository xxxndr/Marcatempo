-- Tabella dei clienti (locali/bar/ristoranti), radice della multitenancy:
-- vedi notes/product/app.md, sezioni "Multitenancy" e "Ordine di
-- creazione degli accessi".

create table clients (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  signup_code text unique,
  created_at timestamptz not null default now()
);

-- Solo select per authenticated: le righe le crea la piattaforma via
-- service_role, mai l'Admin da dentro l'app.
alter table clients enable row level security;

grant select
  on clients
  to authenticated;
