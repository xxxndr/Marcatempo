-- Funzione helper per la multitenancy (Blocco 1.4): legge il client_id
-- dell'utente autenticato. Stesso motivo di SECURITY DEFINER già usato in
-- current_employee_role() (vedi 20260823143202_rls_role_separation.sql).

create function public.current_employee_client_id()
returns uuid
language sql
security definer
stable
set search_path = public
as $$
  select client_id from employees where id = auth.uid();
$$;

-- Stesso motivo di current_employee_role() (vedi
-- 20260823143202_rls_role_separation.sql): togliamo l'EXECUTE di
-- default a PUBLIC e lo ridiamo solo a chi ha fatto login.
revoke execute on function public.current_employee_client_id() from public;
grant execute on function public.current_employee_client_id() to authenticated;
