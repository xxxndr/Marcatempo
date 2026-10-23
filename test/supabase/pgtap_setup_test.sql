-- Primo test pgTAP: verifica solo che l'estensione sia attiva e lo schema
-- base esista, prima di scrivere test di contenuto reale (RLS, trigger).
-- Dentro una transazione con ROLLBACK: nessuna modifica resta nel DB anche
-- se in futuro un test qui dentro farà insert di prova.
begin;

select plan(2);

select has_extension('pgtap', 'estensione pgtap installata');
select has_table('public', 'employees', 'tabella employees esiste');

select * from finish();

rollback;
