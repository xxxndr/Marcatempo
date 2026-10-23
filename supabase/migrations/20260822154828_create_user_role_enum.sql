-- Definisce i tre ruoli utente ammessi nell'app (admin, manager, employee)
-- come tipo enum Postgres, così il database stesso impedisce valori diversi
-- da quelli previsti quando verrà usato sulla colonna "role" di employees

create type user_role as enum ('admin', 'manager', 'employee');