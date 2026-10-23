-- Indici su tutte le colonne FK dello schema (dev/refactor.md R1): le FK in
-- Postgres non creano indici da sole, e le policy RLS filtrano sempre
-- per client_id — senza indice ogni select scansiona l'intera tabella.

create index employees_client_id_idx on employees (client_id);

create index shifts_client_id_idx on shifts (client_id);
create index shifts_employee_id_idx on shifts (employee_id);

create index absences_client_id_idx on absences (client_id);
create index absences_employee_id_idx on absences (employee_id);

create index timeclock_events_client_id_idx on timeclock_events (client_id);
create index timeclock_events_employee_id_idx on timeclock_events (employee_id);

create index sync_log_client_id_idx on sync_log (client_id);

create index timeclock_anomalies_client_id_idx on timeclock_anomalies (client_id);
create index timeclock_anomalies_timeclock_event_id_idx on timeclock_anomalies (timeclock_event_id);
create index timeclock_anomalies_reported_by_idx on timeclock_anomalies (reported_by);

create index absences_anomalies_client_id_idx on absences_anomalies (client_id);
create index absences_anomalies_absence_id_idx on absences_anomalies (absence_id);
create index absences_anomalies_reported_by_idx on absences_anomalies (reported_by);

create index weekly_schedule_templates_client_id_idx on weekly_schedule_templates (client_id);
create index weekly_schedule_templates_employee_id_idx on weekly_schedule_templates (employee_id);

create index clients_contract_type_id_idx on clients (contract_type_id);
