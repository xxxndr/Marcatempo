-- Policy RLS per timeclock_events: solo lettura per ora (admin/manager
-- tutte, employee solo le proprie). Nessuna policy di scrittura: la
-- timbratura vera arriverà nel Blocco 11/12 tramite funzione
-- server-side che valida QR/PIN e scrive con SECURITY DEFINER,
-- bypassando RLS — coerente col vincolo "client dumb, logica critica
-- solo lato server"
create policy "timeclock_events_select_admin_manager" on timeclock_events
  for select
  using (current_employee_role() in ('admin', 'manager') and client_id = current_employee_client_id());

create policy "timeclock_events_select_own" on timeclock_events
  for select
  using (employee_id = auth.uid() and client_id = current_employee_client_id());
