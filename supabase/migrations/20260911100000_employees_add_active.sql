-- Disattivazione di un dipendente che lascia il locale (Blocco 3.6): blocca
-- l'accesso ma conserva tutto lo storico, perché le timbrature non possono
-- essere cancellate (vedi notes/product/app.md, sezione "Conservazione
-- dati (GDPR)"). Reversibile: un rientro si gestisce riportando active a true.

alter table employees
  add column active boolean not null default true;
