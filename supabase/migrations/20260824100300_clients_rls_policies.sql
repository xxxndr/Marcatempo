-- Policy RLS per clients: solo Admin legge il proprio locale (è lui che
-- paga l'abbonamento, non Manager) — nessuna scrittura per authenticated,
-- vedi grant in create_clients_table.sql
create policy "clients_select_admin" on clients
  for select
  using (current_employee_role() = 'admin' and id = current_employee_client_id());
