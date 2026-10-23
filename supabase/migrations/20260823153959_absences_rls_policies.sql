-- Policy RLS per absences. Nessuna policy di select qui: la lettura passa
-- dalla vista absences_grid (vedi 20260825091000_absences_grid_view.sql),
-- che nasconde il tipo malattia/infortunio a chi non ha competenza —
-- Provvedimento Garante Privacy 146/2019, vedi notes/product/app.md,
-- sezione "Visibilità di malattia/infortunio per il ruolo Manager
-- (privacy)". Manager può inserire solo assenze non sanitarie: malattia/
-- infortunio le inserisce solo Admin (stessa fonte).
--
-- Solo insert: update/delete sono bloccati dal trigger di immutabilità
-- (vedi immutability_trigger.sql, Blocco 1.3, GDPR) — le correzioni
-- passano dalla tabella gemella absences_anomalies.
drop policy if exists "absences_select_admin_manager" on absences;
drop policy if exists "absences_select_own" on absences;

drop policy if exists "absences_insert_admin_manager" on absences;
create policy "absences_insert_admin_manager" on absences
  for insert
  with check (
    client_id = current_employee_client_id()
    and (
      current_employee_role() = 'admin'
      or (current_employee_role() = 'manager' and type not in ('illness', 'injury'))
    )
  );
