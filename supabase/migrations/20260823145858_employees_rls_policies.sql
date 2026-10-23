-- Policy RLS per employees: admin/manager vedono tutti i profili, un
-- dipendente vede solo il proprio. Il self-signup (Blocco 3.1) scrive
-- via service key nella edge function, bypassando questa RLS: qui resta
-- solo admin per scritture dirette dal client.
create policy "employees_select_admin_manager" on employees
  for select
  using (current_employee_role() in ('admin', 'manager') and client_id = current_employee_client_id());

create policy "employees_select_own" on employees
  for select
  using (id = auth.uid() and client_id = current_employee_client_id());

create policy "employees_write_admin" on employees
  for all
  using (current_employee_role() = 'admin' and client_id = current_employee_client_id());
