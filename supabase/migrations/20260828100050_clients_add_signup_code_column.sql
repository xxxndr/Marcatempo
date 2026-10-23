-- Colonna già aggiunta in create_clients_table.sql, ma quella migration
-- era già stata deployata prima di questo edit: da qui in avanti solo
-- migration nuove, mai più editing di file già deployati. Vedi
-- dev/environment.md, nota "edge function locali impossibili, DB cloud
-- usato anche come test".

alter table clients add column if not exists signup_code text unique;
