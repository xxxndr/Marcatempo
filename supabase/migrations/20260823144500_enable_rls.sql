-- Attiva RLS sulle tabelle esistenti. Senza policy, con RLS attivo,
-- nessuno può leggere o scrivere: le policy dei prossimi file
-- riaprono l'accesso caso per caso.
alter table employees enable row level security;
alter table shifts enable row level security;
alter table absences enable row level security;
alter table timeclock_events enable row level security;
alter table sync_log enable row level security;
