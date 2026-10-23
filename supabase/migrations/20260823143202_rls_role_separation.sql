-- Policy RLS per separare i tre ruoli utente (admin, manager, employee).
-- L'isolamento vive nel database, coerente col vincolo di sicurezza di
-- CLAUDE.md. Multitenancy (client_id) arriva nel Blocco 1.4/1.5.

-- current_employee_role(): legge il ruolo dell'utente autenticato.
-- SECURITY DEFINER per evitare che una policy su employees scateni RLS
-- su se stessa leggendo employees.
create function public.current_employee_role()
returns user_role
language sql
security definer
stable
set search_path = public
as $$
  select role from employees where id = auth.uid();
$$;

-- Di default Postgres concede EXECUTE a PUBLIC (chiunque, anche senza
-- login) su ogni funzione appena creata. La togliamo e la ridiamo solo
-- a chi ha fatto login.
revoke execute on function public.current_employee_role() from public;
grant execute on function public.current_employee_role() to authenticated;
