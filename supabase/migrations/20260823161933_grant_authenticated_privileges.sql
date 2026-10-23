-- Concede al ruolo "authenticated" (utenti loggati via Supabase Auth)
-- il permesso di base per toccare le tabelle. Senza questo, anche con
-- le RLS a posto, Postgres nega l'accesso prima ancora di valutare le
-- policy (il filtro riga per riga resta comunque compito delle RLS,
-- non di questo GRANT).
--
-- absences non ha "select" qui: la lettura passa solo dalla vista
-- absences_grid (vedi 20260825091000_absences_grid_view.sql), per
-- impedire un accesso diretto alla tabella che rivelerebbe il tipo
-- malattia/infortunio a chi non deve vederlo.
grant select, insert, update, delete
  on employees, shifts, timeclock_events, sync_log
  to authenticated;

grant insert
  on absences
  to authenticated;
