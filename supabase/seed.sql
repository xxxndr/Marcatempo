-- Dati finti per lo sviluppo locale, applicati in automatico dopo le
-- migration ad ogni "supabase db reset". Idempotente (on conflict do
-- nothing) per poter rilanciare il reset senza errori di duplicazione.
--
-- Due clienti finti per testare la multitenancy (isolamento dati tra
-- locali diversi, vedi Blocco 1.4): dipendenti/turni/ecc. finti si
-- aggiungeranno qui quando si arriverà a testare login e RLS a fondo
-- (Blocco 2+), perché richiedono anche righe corrispondenti in
-- auth.users, non solo nelle tabelle applicative.

insert into clients (id, name) values
  ('00000000-0000-0000-0000-000000000001', 'Bar Test Uno'),
  ('00000000-0000-0000-0000-000000000002', 'Ristorante Test Due')
on conflict (id) do nothing;
