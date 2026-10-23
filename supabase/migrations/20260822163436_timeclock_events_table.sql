-- Tabella delle timbrature (entrata/uscita)
-- "source" distingue se la timbratura è avvenuta via QR dinamico o via PIN
-- di fallback, utile in futuro per capire quanto viene usato il fallback

create type timeclock_event_type as enum ('clock_in', 'clock_out');
create type timeclock_source as enum ('qr', 'pin');

create table timeclock_events (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references clients(id),
  employee_id uuid not null references employees(id),
  event_type timeclock_event_type not null,
  occurred_at timestamptz not null,
  source timeclock_source not null,
  created_at timestamptz not null default now()
);
