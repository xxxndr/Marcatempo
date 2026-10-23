-- Template settimanale fisso (Blocco 1.6), una riga per dipendente/giorno,
-- usato dal generatore turni (Blocco 10). day_of_week: 0=lunedì...6=domenica.
--
-- start_time_1/end_time_1 = turno continuativo o prima fascia dello
-- spezzato; start_time_2/end_time_2 = seconda fascia. Check sotto impone
-- coerenza per day_type e ordine cronologico tra le fasce (nessun minimo
-- di pausa: delegato alla contrattazione territoriale, vedi
-- notes/product/app.md, sezione "Vincoli di legge sull'orario di lavoro").

create table weekly_schedule_templates (
    id uuid primary key default gen_random_uuid(),
    client_id uuid not null references clients(id),
    employee_id uuid not null references employees(id),
    day_of_week smallint not null check (day_of_week between 0 and 6),
    day_type weekly_schedule_day_type not null,
    start_time_1 time,
    end_time_1 time,
    start_time_2 time,
    end_time_2 time,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (employee_id, day_of_week),
    check (
        (day_type = 'rest'
            and start_time_1 is null and end_time_1 is null
            and start_time_2 is null and end_time_2 is null)
        or (day_type = 'continuous'
            and start_time_1 is not null and end_time_1 is not null
            and end_time_1 > start_time_1
            and start_time_2 is null and end_time_2 is null)
        or (day_type = 'split'
            and start_time_1 is not null and end_time_1 is not null
            and start_time_2 is not null and end_time_2 is not null
            and end_time_1 > start_time_1
            and end_time_2 > start_time_2
            and start_time_2 > end_time_1)
    )
);

alter table weekly_schedule_templates enable row level security;

grant select, insert, update, delete
  on weekly_schedule_templates
  to authenticated;
