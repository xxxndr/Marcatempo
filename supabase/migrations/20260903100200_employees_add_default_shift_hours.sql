-- Ore di default per dipendenti a orario flessibile (has_fixed_weekly_schedule
-- = false): lunghezza di partenza del blocco quando l'Admin lo crea in griglia,
-- sempre modificabile a mano. Vedi notes/product/app.md, sezione
-- "Generazione automatica dei turni", voce lunghezza_default_blocco.
-- Nullable, nessun calcolo automatico: lo imposta l'Admin una volta.
-- Tetto 13h (24h - 11h di riposo minimo consecutivo, D.Lgs. 66/2003): check
-- pratico anti-errore, stesso criterio già usato per weekly_contracted_hours.

alter table employees
  add column default_shift_hours numeric(4, 2)
    check (default_shift_hours is null or
           (default_shift_hours > 0 and default_shift_hours <= 13));
