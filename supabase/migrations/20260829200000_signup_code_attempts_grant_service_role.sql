-- Grant mancante su signup_code_attempts per service_role: la edge function
-- self-signup usa la secret key (service_role) per leggere/scrivere il
-- contatore tentativi falliti, ma la migration originale
-- (20260829090000_signup_code_attempts_table.sql) non le ha mai concesso i
-- permessi sulla tabella. Stesso tipo di bug già visto su employees/clients,
-- vedi notes/test/history.md.

grant select, insert, update on signup_code_attempts to service_role;
