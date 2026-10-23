-- Concede al ruolo "authenticated" il permesso di base sulle nuove
-- tabelle gemelle, stesso criterio già seguito per le tabelle principali
-- (grant_authenticated_privileges.sql): il filtro riga per riga e per
-- comando resta compito delle RLS, non di questo GRANT.
grant select, insert, update, delete
  on timeclock_anomalies, absences_anomalies
  to authenticated;
