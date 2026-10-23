-- Collega ogni dipendente al proprio tipo di contratto (CCNL) — vedi
-- 20260830100000_create_contract_types_table.sql. Nullable: stessa logica
-- già applicata a weekly_contracted_hours, nessun default per non
-- inventare un dato di lavoro in un record reale.

alter table employees
  add column contract_type_id uuid references contract_types(id);
