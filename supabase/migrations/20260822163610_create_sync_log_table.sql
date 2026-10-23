-- Tabella di log dei tentativi di sincronizzazione offline-first
-- Non contiene i dati sincronizzati (timbrature, risposte turni, ecc), solo
-- la traccia di ogni tentativo, per poter capire in futuro perché un dato
-- non si è sincronizzato senza dover ispezionare i JSON locali sul telefono

create type sync_status as enum ('success', 'failed', 'conflict');

create table sync_log (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id),
  table_name text not null,
  record_id uuid not null,
  attempted_at timestamptz not null default now(),
  status sync_status not null,
  error_message text
);
