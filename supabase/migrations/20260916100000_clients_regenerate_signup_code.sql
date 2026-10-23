-- Rigenerazione signup_code dalla schermata Admin (Blocco 3.9). Stesso
-- pattern SECURITY DEFINER già usato per resolve_signup_code() e
-- generate_employee_pin(): nessun nuovo grant di scrittura su clients,
-- tutta la mutazione passa da questa funzione. Vedi product/app.md,
-- sezione "Ordine di creazione degli accessi".

create function public.regenerate_client_signup_code()
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  new_code text;
begin
  if (select current_employee_role()) <> 'admin' then
    raise exception 'not authorized';
  end if;

  new_code := public.generate_signup_code();

  update clients
  set signup_code = new_code
  where id = (select current_employee_client_id());

  return new_code;
end;
$$;

revoke execute on function public.regenerate_client_signup_code() from public;
grant execute on function public.regenerate_client_signup_code() to authenticated;
