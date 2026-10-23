-- Tabella dei dipendenti (1:1 con auth.users). PIN salvato solo hashato.
-- Vedi product/app.md, sezioni "Creazione ed eliminazione profilo
-- dipendente (Edge Function)" e "Generazione automatica dei turni".

create table employees (
    id uuid primary key references auth.users(id) on delete cascade,
    client_id uuid not null references clients(id),
    first_name text not null,
    last_name text not null,
    role user_role not null,
    pin_hash text,
    weekly_contracted_hours numeric(4, 2)
        check (weekly_contracted_hours is null or
               (weekly_contracted_hours > 0 and weekly_contracted_hours <= 78)),
    has_fixed_weekly_schedule boolean not null default false,
    senior boolean not null default false,
    created_at timestamptz not null default now()
);