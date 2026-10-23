-- Policy RLS per sync_log: solo admin legge (log tecnico di debug),
-- nessuna policy di scrittura per lo stesso motivo di timeclock_events
-- (arriverà dalle funzioni di sync dei Blocchi 8/12)
create policy "sync_log_select_admin" on sync_log
  for select
  using (current_employee_role() = 'admin' and client_id = current_employee_client_id());
