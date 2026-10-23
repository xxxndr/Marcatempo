-- Ricrea tutte le policy RLS e la vista absences_grid wrappando in
-- (select ...) le chiamate a current_employee_role(),
-- current_employee_client_id() e auth.uid(): da valutazione per riga a
-- InitPlan calcolato una volta per query (lint Supabase
-- auth_rls_initplan). Vedi notes/dev/refactor.md R2. Logica di accesso
-- invariata: commenti e motivazioni restano nei file originali delle
-- policy.

-- employees (vedi 20260823145858_employees_rls_policies.sql)

drop policy "employees_select_admin_manager" on employees;
create policy "employees_select_admin_manager" on employees
  for select
  using ((select current_employee_role()) in ('admin', 'manager') and client_id = (select current_employee_client_id()));

drop policy "employees_select_own" on employees;
create policy "employees_select_own" on employees
  for select
  using (id = (select auth.uid()) and client_id = (select current_employee_client_id()));

drop policy "employees_write_admin" on employees;
create policy "employees_write_admin" on employees
  for all
  using ((select current_employee_role()) = 'admin' and client_id = (select current_employee_client_id()));

-- shifts (vedi 20260823153447_shifts_rls_policies.sql)

drop policy "shifts_select_admin_manager" on shifts;
create policy "shifts_select_admin_manager" on shifts
  for select
  using ((select current_employee_role()) in ('admin', 'manager') and client_id = (select current_employee_client_id()));

drop policy "shifts_select_own" on shifts;
create policy "shifts_select_own" on shifts
  for select
  using (employee_id = (select auth.uid()) and client_id = (select current_employee_client_id()));

drop policy "shifts_write_admin_manager" on shifts;
create policy "shifts_write_admin_manager" on shifts
  for all
  using ((select current_employee_role()) in ('admin', 'manager') and client_id = (select current_employee_client_id()));

-- absences (vedi 20260823153959_absences_rls_policies.sql)

drop policy "absences_insert_admin_manager" on absences;
create policy "absences_insert_admin_manager" on absences
  for insert
  with check (
    client_id = (select current_employee_client_id())
    and (
      (select current_employee_role()) = 'admin'
      or ((select current_employee_role()) = 'manager' and type not in ('illness', 'injury'))
    )
  );

-- timeclock_events (vedi 20260823154456_timeclock_events_rls_policies.sql)

drop policy "timeclock_events_select_admin_manager" on timeclock_events;
create policy "timeclock_events_select_admin_manager" on timeclock_events
  for select
  using ((select current_employee_role()) in ('admin', 'manager') and client_id = (select current_employee_client_id()));

drop policy "timeclock_events_select_own" on timeclock_events;
create policy "timeclock_events_select_own" on timeclock_events
  for select
  using (employee_id = (select auth.uid()) and client_id = (select current_employee_client_id()));

-- sync_log (vedi 20260823154733_sync_log_rls_policies.sql)

drop policy "sync_log_select_admin" on sync_log;
create policy "sync_log_select_admin" on sync_log
  for select
  using ((select current_employee_role()) = 'admin' and client_id = (select current_employee_client_id()));

-- timeclock_anomalies (vedi 20260823170300_timeclock_anomalies_rls_policies.sql)

drop policy "timeclock_anomalies_select_admin_manager" on timeclock_anomalies;
create policy "timeclock_anomalies_select_admin_manager" on timeclock_anomalies
  for select
  using ((select current_employee_role()) in ('admin', 'manager') and client_id = (select current_employee_client_id()));

drop policy "timeclock_anomalies_insert_admin_manager" on timeclock_anomalies;
create policy "timeclock_anomalies_insert_admin_manager" on timeclock_anomalies
  for insert
  with check ((select current_employee_role()) in ('admin', 'manager') and client_id = (select current_employee_client_id()));

-- absences_anomalies (vedi 20260823170400_absences_anomalies_rls_policies.sql)

drop policy "absences_anomalies_select_admin_manager" on absences_anomalies;
create policy "absences_anomalies_select_admin_manager" on absences_anomalies
  for select
  using (
    client_id = (select current_employee_client_id())
    and (
      (select current_employee_role()) = 'admin'
      or (
        (select current_employee_role()) = 'manager'
        and exists (
          select 1 from absences
          where absences.id = absences_anomalies.absence_id
            and absences.type not in ('illness', 'injury')
        )
      )
    )
  );

drop policy "absences_anomalies_insert_admin_manager" on absences_anomalies;
create policy "absences_anomalies_insert_admin_manager" on absences_anomalies
  for insert
  with check (
    client_id = (select current_employee_client_id())
    and (
      (select current_employee_role()) = 'admin'
      or (
        (select current_employee_role()) = 'manager'
        and exists (
          select 1 from absences
          where absences.id = absences_anomalies.absence_id
            and absences.type not in ('illness', 'injury')
        )
      )
    )
  );

-- weekly_schedule_templates (vedi 20260824100200_weekly_schedule_templates_rls_policies.sql)

drop policy "weekly_schedule_templates_select_admin_manager" on weekly_schedule_templates;
create policy "weekly_schedule_templates_select_admin_manager" on weekly_schedule_templates
  for select
  using ((select current_employee_role()) in ('admin', 'manager') and client_id = (select current_employee_client_id()));

drop policy "weekly_schedule_templates_select_own" on weekly_schedule_templates;
create policy "weekly_schedule_templates_select_own" on weekly_schedule_templates
  for select
  using (employee_id = (select auth.uid()) and client_id = (select current_employee_client_id()));

drop policy "weekly_schedule_templates_write_admin" on weekly_schedule_templates;
create policy "weekly_schedule_templates_write_admin" on weekly_schedule_templates
  for all
  using ((select current_employee_role()) = 'admin' and client_id = (select current_employee_client_id()));

-- clients (vedi 20260824100300_clients_rls_policies.sql)

drop policy "clients_select_admin" on clients;
create policy "clients_select_admin" on clients
  for select
  using ((select current_employee_role()) = 'admin' and id = (select current_employee_client_id()));

-- absences_grid (vedi 20260825091000_absences_grid_view.sql): stessa
-- vista, stesse colonne, chiamate wrappate. security_barrier va
-- ridichiarato: create or replace non conserva le opzioni omesse.

create or replace view absences_grid
  with (security_barrier = true)
  as
  select
    a.id,
    a.client_id,
    a.employee_id,
    a.start_date,
    a.end_date,
    a.portion,
    a.created_at,
    case
      when a.employee_id = (select auth.uid()) then a.type::text
      when (select current_employee_role()) = 'admin' then a.type::text
      when a.type in ('illness', 'injury') then 'assente'
      else a.type::text
    end as display_type
  from absences a
  where a.client_id = (select current_employee_client_id())
    and (
      (select current_employee_role()) in ('admin', 'manager')
      or a.employee_id = (select auth.uid())
    );
