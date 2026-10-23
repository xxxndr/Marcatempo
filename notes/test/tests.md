# tests

Lista di cosa scrivere. Fatto/non fatto, ore reali ed esito -> test/history.md.

## flutter test - file in test/

- T1 studio - Impianto
- T2 delega - Supplementare/straordinario su weekly_contracted_hours (ROADMAP 15.4)
- T3 delega - Aggregazione giornaliera ore (17.1)
- T4 delega - Ritardi, reale vs pianificato (14.1)
- T5 mai delegare - Cifre del PDF paghe (18.1), stessa criticità della voce ROADMAP

## pgTAP - file .sql in test/supabase/

- T6 studio - Impianto (sintassi SQL nuova, vedi study.md -> Fonti, pgtap.org)
- T7 delega - Isolamento multi-tenant su tutte le tabelle (Blocco 5: tutte le tabelle client-scoped devono esistere)
- T8 delega - Isolamento dipendente-dipendente, ruoli, malattia/infortunio nascosti al manager (Blocco 5, stesso motivo)
- T9 delega - Dipendente disattivato: ogni policy nega
- T10 studio - Trigger immutabilità: UPDATE/DELETE sempre rifiutati

## deno test - file in test/supabase_functions/

- T11 studio - Impianto
- T12 delega - set-employee-active: 403 non-admin, 404 altro locale, 409 se stesso, 400 payload
- T13 delega - create-employee e self-signup: ruolo forzato, codice non valido, anti brute-force

Restano manuali su device, mai automatici: drag-and-drop, QR, push, cicli online/offline -> test/history.md

Fonti: pgTAP supabase.com/docs/guides/database/testing - deno test supabase.com/docs/guides/functions/unit-test
