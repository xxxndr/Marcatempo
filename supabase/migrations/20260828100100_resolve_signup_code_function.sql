-- Risoluzione signup_code -> client_id per il self-signup (Blocco 3.1).
-- SECURITY DEFINER come current_employee_client_id(), stesso motivo: un
-- utente senza ancora riga employees non può leggere clients per RLS.
-- Vedi product/app.md, sezione "Ordine di creazione degli accessi".

create function public.resolve_signup_code(code text)
returns uuid
language sql
security definer
stable
set search_path = public
as $$
  select id from clients where signup_code = code;
$$;

revoke execute on function public.resolve_signup_code(text) from public;
grant execute on function public.resolve_signup_code(text) to authenticated;
