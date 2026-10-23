-- Quanti giorni mostra la griglia turni (Blocco 4): non fissa a un mese,
-- la cadenza dei turni varia da locale a locale (settimanale, quindicinale,
-- mensile). Default 7 giorni. Stesso pattern SECURITY DEFINER già usato per
-- regenerate_client_signup_code: nessun nuovo grant di scrittura su
-- clients, tutta la mutazione passa da questa funzione.

alter table clients
  add column grid_range_days integer not null default 7;

create function public.set_client_grid_range_days(days integer)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if (select current_employee_role()) <> 'admin' then
    raise exception 'not authorized';
  end if;

  if days < 1 then
    raise exception 'invalid range';
  end if;

  update clients
  set grid_range_days = days
  where id = (select current_employee_client_id());
end;
$$;

revoke execute on function public.set_client_grid_range_days(integer) from public;
grant execute on function public.set_client_grid_range_days(integer) to authenticated;
