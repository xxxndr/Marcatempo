-- Vincolo di non-cancellazione (Blocco 1.3, GDPR): blocca fisicamente
-- ogni UPDATE/DELETE a livello di database (le policy RLS da sole non
-- bastano, bypassabili da service_role). Applicato a timeclock_events e
-- absences e alle tabelle gemelle di correzione. Non a "shifts", che
-- viene modificata di continuo nei blocchi 4/7/8. Vedi
-- notes/product/app.md, sezione "Conservazione dati (GDPR)".

create or replace function public.enforce_immutability()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  raise exception 'operazione non permessa: % è immutabile per conservazione dati (Blocco 1.3)', tg_table_name;
end;
$$;

create or replace trigger timeclock_events_immutable
  before update or delete on timeclock_events
  for each row execute function public.enforce_immutability();

create or replace trigger absences_immutable
  before update or delete on absences
  for each row execute function public.enforce_immutability();

create or replace trigger timeclock_anomalies_immutable
  before update or delete on timeclock_anomalies
  for each row execute function public.enforce_immutability();

create or replace trigger absences_anomalies_immutable
  before update or delete on absences_anomalies
  for each row execute function public.enforce_immutability();
