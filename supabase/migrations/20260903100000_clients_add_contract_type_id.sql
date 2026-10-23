-- Corregge 20260830100100: il tipo di contratto (CCNL) è un attributo del
-- cliente (locale), non del singolo dipendente — tutti i dipendenti dello
-- stesso locale condividono lo stesso CCNL. Vedi notes/product/app.md,
-- sezione "Tipo di contratto (CCNL)". Nullable: nessun default inventato.

alter table clients
  add column contract_type_id uuid references contract_types(id);
