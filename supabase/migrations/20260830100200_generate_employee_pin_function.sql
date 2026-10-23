-- Generazione PIN personale del dipendente (Blocco 3.3). Il PIN deve
-- essere univoco solo all'interno dello stesso client_id (bar/locale),
-- non globalmente — due dipendenti di bar diversi possono avere lo
-- stesso PIN. Vedi product/app.md, sezione "Ordine di creazione
-- degli accessi". SECURITY DEFINER come resolve_signup_code() e
-- current_employee_client_id(): serve leggere pin_hash di tutti i
-- dipendenti del client per il controllo di unicità, cosa che la RLS
-- dipendente↔dipendente normalmente non permette.

create extension if not exists pgcrypto with schema extensions;

create function public.generate_employee_pin(p_client_id uuid)
returns text
language plpgsql
security definer
set search_path = public, extensions
as $$
declare
  candidate text;
  collision boolean;
begin
  loop
    candidate := lpad(floor(random() * 10000)::text, 4, '0');
    select exists (
      select 1 from employees
      where client_id = p_client_id
        and pin_hash is not null
        and pin_hash = crypt(candidate, pin_hash)
    ) into collision;
    exit when not collision;
  end loop;
  return candidate;
end;
$$;

revoke execute on function public.generate_employee_pin(uuid) from public;
grant execute on function public.generate_employee_pin(uuid) to authenticated;
