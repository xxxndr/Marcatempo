-- Un dipendente disattivato (Blocco 3.6) perde l'accesso ai dati nel
-- database, non nell'app: le due funzioni helper usate da ogni policy RLS
-- restituiscono NULL quando chi chiama non è più attivo, e ogni condizione
-- costruita su di esse diventa NULL, cioè nega. Un solo punto di modifica
-- copre tutte le tabelle, nessuna policy esistente va riscritta.
--
-- Perché non basta il ban lato Auth: quello impedisce nuovi login ma non
-- revoca una sessione già aperta sul telefono del dipendente, che resterebbe
-- valida fino alla scadenza del token. Questa barriera invece taglia
-- l'accesso all'istante, coerente col vincolo "client dumb" di CLAUDE.md.

create or replace function public.current_employee_role()
returns user_role
language sql
security definer
stable
set search_path = public
as $$
  select role from employees where id = auth.uid() and active;
$$;

create or replace function public.current_employee_client_id()
returns uuid
language sql
security definer
stable
set search_path = public
as $$
  select client_id from employees where id = auth.uid() and active;
$$;

-- Conseguenza delle due funzioni sopra: un disattivato non legge più nemmeno
-- la propria riga, quindi l'app non saprebbe distinguerlo da chi non ha
-- ancora un profilo (self-signup a metà) e lo manderebbe a completare la
-- registrazione. Questa funzione risponde a quella domanda sola, senza
-- esporre nessun altro dato del profilo.
create function public.current_employee_status()
returns text
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(
    (select case when active then 'active' else 'inactive' end
       from employees where id = auth.uid()),
    'none'
  );
$$;

-- Stesso motivo delle altre funzioni helper (vedi
-- 20260823143202_rls_role_separation.sql): via l'EXECUTE di default a
-- PUBLIC, resta solo a chi ha fatto login.
revoke execute on function public.current_employee_status() from public;
grant execute on function public.current_employee_status() to authenticated;
