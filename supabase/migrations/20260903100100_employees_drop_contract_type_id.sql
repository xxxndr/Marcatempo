-- Rimuove contract_type_id da employees: spostato su clients (vedi
-- 20260903100000), evita che dipendenti dello stesso locale finiscano
-- su CCNL diversi.

alter table employees
  drop column contract_type_id;
