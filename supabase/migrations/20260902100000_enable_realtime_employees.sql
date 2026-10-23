-- Abilita il realtime sulla tabella employees, necessario perché
-- EmployeesPage (Blocco 3.4) usa .stream() per aggiornare la lista da sola
-- dopo promozione/eliminazione/creazione, senza uscire e rientrare.

alter publication supabase_realtime add table employees;
