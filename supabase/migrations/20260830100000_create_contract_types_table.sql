-- Tipo di contratto collettivo (CCNL) applicato ai dipendenti di un locale.
-- Non è per-cliente: locali diversi possono condividere lo stesso CCNL.
-- Contiene solo i valori che (a) cambiano davvero da un CCNL all'altro e
-- (b) sono già letti da una funzionalità dell'app — vedi
-- notes/product/app.md, sezione "Tipo di contratto (CCNL)", e
-- notes/legal/law.md per le fonti di legge. Tutto il resto (ROL,
-- comporto, preavvisi, clausole elastiche) resta fuori: competenza
-- dell'ufficio paghe, mai calcolato né applicato qui.

create table contract_types (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    full_time_weekly_hours numeric(4, 2) not null
        check (full_time_weekly_hours > 0 and full_time_weekly_hours <= 48),
    daily_rest_hours numeric(4, 2) not null
        check (daily_rest_hours > 0 and daily_rest_hours <= 24),
    created_at timestamptz not null default now()
);

alter table contract_types enable row level security;

-- Dato di riferimento condiviso tra tutti i clienti (non isolato per
-- client_id): sola lettura per authenticated, nessuna scrittura da app —
-- righe gestite solo via migration lato sviluppatore.
create policy "contract_types_select_authenticated" on contract_types
  for select
  using (true);

grant select
  on contract_types
  to authenticated;

-- CCNL Fipe-Confcommercio (Pubblici Esercizi), rinnovato 5 giugno 2024 —
-- valori verificati su testo primario fipe.it, vedi notes/legal/law.md,
-- sezione "Orario di lavoro: riposi e massimali".
insert into contract_types (name, full_time_weekly_hours, daily_rest_hours) values
  ('CCNL Fipe-Confcommercio — Pubblici Esercizi (2024)', 40, 11);
