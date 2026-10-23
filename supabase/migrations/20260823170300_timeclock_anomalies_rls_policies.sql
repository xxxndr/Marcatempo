-- Policy RLS per timeclock_anomalies: solo admin/manager possono leggere
-- e segnalare anomalie. Nessuna policy di update/delete: la tabella è
-- append-only, coerente con la garanzia di conservazione del Blocco 1.3
-- (rinforzata anche a livello trigger, vedi immutability_trigger).
drop policy if exists "timeclock_anomalies_select_admin_manager" on timeclock_anomalies;
create policy "timeclock_anomalies_select_admin_manager" on timeclock_anomalies
  for select
  using (current_employee_role() in ('admin', 'manager') and client_id = current_employee_client_id());

drop policy if exists "timeclock_anomalies_insert_admin_manager" on timeclock_anomalies;
create policy "timeclock_anomalies_insert_admin_manager" on timeclock_anomalies
  for insert
  with check (current_employee_role() in ('admin', 'manager') and client_id = current_employee_client_id());
