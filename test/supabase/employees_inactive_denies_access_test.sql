-- Un dipendente disattivato (active=false) perde l'accesso a ogni riga,
-- anche quando il suo ruolo sarebbe admin: prova che il gate è il controllo
-- "active" dentro le funzioni helper (20260911100100_inactive_employees_lose_access.sql),
-- non il ruolo. Dentro una transazione con ROLLBACK: nessun dato resta.
begin;

select plan(2);

insert into clients (id, name)
values ('aaaaaaaa-0000-0000-0000-000000000001', 'Cliente Test pgTAP');

insert into auth.users (id) values ('11111111-0000-0000-0000-000000000001');
insert into employees (id, client_id, first_name, last_name, role, active)
values (
  '11111111-0000-0000-0000-000000000001',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'Admin', 'Disattivato', 'admin', false
);

insert into auth.users (id) values ('22222222-0000-0000-0000-000000000001');
insert into employees (id, client_id, first_name, last_name, role, active)
values (
  '22222222-0000-0000-0000-000000000001',
  'aaaaaaaa-0000-0000-0000-000000000001',
  'Altro', 'Dipendente', 'employee', true
);

-- Da qui in poi si opera come farebbe l'app: ruolo authenticated, sub del
-- JWT uguale all'id dell'admin disattivato appena creato.
set local role authenticated;
select set_config('request.jwt.claim.sub', '11111111-0000-0000-0000-000000000001', true);

select is(
  (select count(*) from employees)::int,
  0,
  'admin disattivato: select su employees non vede nessuna riga, nemmeno la propria'
);

with updated as (
  update employees set role = 'employee'
  where id = '22222222-0000-0000-0000-000000000001'
  returning 1
)
select is(
  (select count(*) from updated)::int,
  0,
  'admin disattivato: update su employees non modifica nessuna riga'
);

select * from finish();

rollback;
