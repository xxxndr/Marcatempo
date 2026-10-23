-- Tabella dei turni di lavoro assegnati ai dipendenti
-- "updated_at" non è solo un campo di controllo: nel Blocco 8 (risposta
-- offline del dipendente) viene usato come "versione" del turno per capire
-- se una risposta arrivata da un dispositivo offline si riferisce ancora
-- alla proposta attuale o a una già superata da una nuova modifica

create table shifts (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id),
  employee_id uuid not null references employees(id),
  start_at timestamptz not null,
  end_at timestamptz not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
