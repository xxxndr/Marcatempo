-- Vista di lettura per absences: sostituisce l'accesso diretto alla
-- tabella (revocato in grant_authenticated_privileges.sql) e nasconde il
-- tipo malattia/infortunio a chi non ha competenza a vederlo —
-- Provvedimento Garante Privacy 146/2019, punto 1.5.d: vedi
-- notes/product/app.md, sezione "Visibilità di malattia/infortunio
-- per il ruolo Manager (privacy)".
--
-- Vista di proprietà del ruolo che esegue le migration, quindi bypassa
-- l'RLS della tabella sottostante per costruzione: la logica di
-- visibilità riga per riga (isolamento client, chi vede cosa) è quindi
-- riscritta qui esplicitamente nel WHERE, non ereditata da absences.
-- security_barrier impedisce che l'ottimizzatore sposti condizioni del
-- chiamante dentro la vista prima della valutazione del CASE, cosa che
-- altrimenti potrebbe far trapelare il tipo vero per via indiretta.

create view absences_grid
  with (security_barrier = true)
  as
  select
    a.id,
    a.client_id,
    a.employee_id,
    a.start_date,
    a.end_date,
    a.portion,
    a.created_at,
    case
      when a.employee_id = auth.uid() then a.type::text
      when current_employee_role() = 'admin' then a.type::text
      when a.type in ('illness', 'injury') then 'assente'
      else a.type::text
    end as display_type
  from absences a
  where a.client_id = current_employee_client_id()
    and (
      current_employee_role() in ('admin', 'manager')
      or a.employee_id = auth.uid()
    );

grant select on absences_grid to authenticated;
