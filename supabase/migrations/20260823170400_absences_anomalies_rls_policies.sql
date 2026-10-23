-- Policy RLS per absences_anomalies: admin legge/segnala su tutto;
-- manager solo su assenze non sanitarie (mai illness/injury, dato
-- particolare GDPR — vedi notes/product/app.md, sezione "Visibilità
-- di malattia/infortunio per il ruolo Manager (privacy)"). Nessuna
-- policy di update/delete: append-only, rinforzata dal trigger di
-- immutabilità.
drop policy if exists "absences_anomalies_select_admin_manager" on absences_anomalies;
create policy "absences_anomalies_select_admin_manager" on absences_anomalies
  for select
  using (
    client_id = current_employee_client_id()
    and (
      current_employee_role() = 'admin'
      or (
        current_employee_role() = 'manager'
        and exists (
          select 1 from absences
          where absences.id = absences_anomalies.absence_id
            and absences.type not in ('illness', 'injury')
        )
      )
    )
  );

drop policy if exists "absences_anomalies_insert_admin_manager" on absences_anomalies;
create policy "absences_anomalies_insert_admin_manager" on absences_anomalies
  for insert
  with check (
    client_id = current_employee_client_id()
    and (
      current_employee_role() = 'admin'
      or (
        current_employee_role() = 'manager'
        and exists (
          select 1 from absences
          where absences.id = absences_anomalies.absence_id
            and absences.type not in ('illness', 'injury')
        )
      )
    )
  );
