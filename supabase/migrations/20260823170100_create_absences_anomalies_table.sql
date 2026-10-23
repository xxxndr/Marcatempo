-- Tabella gemella di "absences" per correggere un errore senza toccare
-- la riga originale (Blocco 1.3, GDPR): vedi notes/product/app.md,
-- sezione "Conservazione dati (GDPR)".

create table absences_anomalies (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id),
  absence_id uuid not null references absences(id),
  reported_by uuid not null references employees(id),
  note text not null,
  created_at timestamptz not null default now()
);
