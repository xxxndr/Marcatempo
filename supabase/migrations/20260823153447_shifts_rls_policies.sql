-- Policy RLS per shifts: admin/manager vedono e gestiscono tutti i
-- turni, un dipendente vede solo i propri
create policy "shifts_select_admin_manager" on shifts
  for select
  using (current_employee_role() in ('admin', 'manager') and client_id = current_employee_client_id());

create policy "shifts_select_own" on shifts
  for select
  using (employee_id = auth.uid() and client_id = current_employee_client_id());

create policy "shifts_write_admin_manager" on shifts
  for all
  using (current_employee_role() in ('admin', 'manager') and client_id = current_employee_client_id());
