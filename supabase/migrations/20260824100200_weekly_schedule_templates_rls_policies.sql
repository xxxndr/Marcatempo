-- Policy RLS per weekly_schedule_templates: stesso schema di employees —
-- admin/manager vedono i template di tutti i dipendenti del proprio
-- locale, un dipendente vede solo il proprio, solo admin scrive
create policy "weekly_schedule_templates_select_admin_manager" on weekly_schedule_templates
  for select
  using (current_employee_role() in ('admin', 'manager') and client_id = current_employee_client_id());

create policy "weekly_schedule_templates_select_own" on weekly_schedule_templates
  for select
  using (employee_id = auth.uid() and client_id = current_employee_client_id());

create policy "weekly_schedule_templates_write_admin" on weekly_schedule_templates
  for all
  using (current_employee_role() = 'admin' and client_id = current_employee_client_id());
