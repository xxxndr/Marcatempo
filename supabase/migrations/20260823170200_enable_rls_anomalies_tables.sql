-- Attiva RLS sulle nuove tabelle gemelle, stesso criterio già seguito
-- per le tabelle principali: senza policy, con RLS attivo, nessuno può
-- leggere o scrivere finché i prossimi file non riaprono l'accesso
-- caso per caso.
alter table timeclock_anomalies enable row level security;
alter table absences_anomalies enable row level security;
