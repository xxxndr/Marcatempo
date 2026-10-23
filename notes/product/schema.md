# schema

## Contesto

- contenitore: tabella Drift/SQLite, non più file JSON — dev/refactor.md R3
- vincolo: un record per evento, mai un aggregato mensile — product/app.md -> gestione_della_connessione_assente_offline_first
- convenzione: nomi campi in inglese, descrizioni in italiano
- obbligatori: event_id, client_id, user_id, type, method, timestamp, sync_status

## Campi

- event_id (uuid): generato dal telefono al momento della timbratura. Chiave idempotente: se l'invio viene ritentato dopo un errore di rete, il server riconosce lo stesso evento e non lo duplica
- client_id (uuid): locale a cui appartiene la timbratura, coerente con la multitenancy a schema condiviso + RLS
- user_id (uuid): dipendente che ha timbrato
- type (enum: clock_in | clock_out)
- method (enum: qr | pin): il PIN è equivalente al QR, non un'anomalia (product/app.md -> pin_come_fallback_esteso) — campo informativo, non cambia la validazione
- qr_token (text, null se method = pin): valore scansionato, validato dal server contro la rotazione a 10s + 2s di margine
- timestamp (timestamptz): istante reale della timbratura, non quello della sincronizzazione. ISO 8601 con offset esplicito, Europe/Rome
- sync_status (enum: pending | synced): pending finché il dispositivo non riesce a inviare a Supabase
- synced_at (timestamptz, null finché pending)
