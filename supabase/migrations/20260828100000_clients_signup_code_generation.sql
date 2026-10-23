-- Generazione automatica del signup_code alla creazione di un cliente
-- (Blocco 3.1). Vedi product/app.md, sezione "Ordine di creazione
-- degli accessi".

create function public.generate_signup_code()
returns text
language plpgsql
as $$
declare
  alphabet text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  code text;
begin
  loop
    code := '';
    for i in 1..8 loop
      code := code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    exit when not exists (select 1 from clients where signup_code = code);
  end loop;
  return code;
end;
$$;

create function public.set_client_signup_code()
returns trigger
language plpgsql
as $$
begin
  if new.signup_code is null then
    new.signup_code := public.generate_signup_code();
  end if;
  return new;
end;
$$;

create trigger clients_set_signup_code
  before insert on clients
  for each row
  execute function public.set_client_signup_code();
