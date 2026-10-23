-- Tabella delle assenze: vacation/illness/unauthorized/personal_leave/
-- injury, segnate in griglia (icone italiane F/M/A/P/I). Fonti legali e
-- decisioni di scope in notes/product/app.md, sezioni "Permessi
-- retribuiti (ROL + ex festività)" e "Infortunio sul lavoro (INAIL)".
--
-- Date piene, non fasce orarie. portion (mezza/giornata intera) vale solo
-- per personal_leave (art. 114 c.7) — l'app registra il fatto grezzo, non
-- calcola ore né blocca nulla: vedi note per il perché.

create type absence_type as enum ('vacation', 'illness', 'unauthorized', 'personal_leave', 'injury');

create type day_portion as enum ('full_day', 'morning', 'afternoon');

create table absences (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id),
  employee_id uuid not null references employees(id),
  type absence_type not null,
  start_date date not null,
  end_date date not null,
  portion day_portion not null default 'full_day',
  created_at timestamptz not null default now(),
  check (portion = 'full_day' or type = 'personal_leave'),
  check (portion = 'full_day' or start_date = end_date)
);
