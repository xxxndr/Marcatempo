# history

- riga: una per voce
- bug: dev/decisions.md
- test automatico già esistente: si rimuove la voce, non si aggiorna

## next: T10

## T1 [OK] 1h - Impianto flutter test (2026-09-17)
App si avvia e mostra la schermata di login, Supabase locale reale. OK

## T2 [] 2h - Supplementare/straordinario su weekly_contracted_hours (15.4)

## T3 [] 2h - Aggregazione giornaliera ore (17.1)

## T4 [] 1.5h - Ritardi, reale vs pianificato (14.1)

## T5 [] 2h - Cifre del PDF paghe (18.1)

## T6 [OK] 1.5h - Impianto pgTAP (2026-09-17)
Estensione pgtap attiva, test smoke su schema. OK

## T7 [] 3h - Isolamento multi-tenant su tutte le tabelle (Blocco 5)

## T8 [] 2.5h - Isolamento dipendente-dipendente, ruoli, malattia/infortunio nascosti al manager (Blocco 5)

## T9 [OK] 1h - Dipendente disattivato: ogni policy nega (2026-09-17)
Admin disattivato: select e update su employees negati, anche sulla propria riga. OK

## T10 [] 1h - Trigger immutabilità: UPDATE/DELETE sempre rifiutati

Podman rootless blocca solo `supabase functions serve` (deploy/serve locale delle edge function, vedi dev/decisions.md). `deno test` non ne risente: gira il binario deno installato sulla macchina, nessun container - T11-T13 non sono bloccati.

## T11 [] 1.5h - Impianto deno test

## T12 [] 2h - set-employee-active: 403 non-admin, 404 altro locale, 409 se stesso, 400 payload

## T13 [] 2h - create-employee e self-signup: ruolo forzato, codice non valido, anti brute-force

## 1.2 - Policy RLS (2026-08-23)
RLS su employees/shifts/timeclock_events per admin/manager/employee, isolamento per ruolo confermato. OK

## 1.3 - Vincolo non-cancellazione GDPR (2026-08-23)
Trigger blocca UPDATE/DELETE su absences/absences_anomalies/timeclock_events anche da superuser senza RLS. OK (shifts esclusa di proposito)

## 1.4 - Multitenancy -> T7 non ancora scritto (2026-08-23)
Admin cliente A legge solo righe cliente A su employees, mai cliente B. OK

## 1.5 - RLS dipendente-dipendente -> T8 non ancora scritto (2026-08-23)
Dipendente legge/modifica solo la propria riga in employees, mai quella di un collega. OK

## 1.6 (2026-08-24)
Audit RLS/policy/grant su tutte le tabelle: 2 incongruenze trovate e corrette (weekly_schedule_templates, clients), nessun'altra. OK

## 2.2 - Login Admin (2026-08-24)
Login su device reale, routing a AdminHomePage. OK

## 3.1 parziale - create-employee (2026-08-26)
Edge function su device: JWT admin -> dipendente creato con credenziali. OK (non testato: chiamata da non-admin)

## Audit Security Advisor Supabase (2026-08-26)
3 warning risolti (search_path, grant PUBLIC). 2 avvisi aperti di proposito e motivati (absences_grid, Leaked Password Protection su piano Free).

## 3.1 continua - delete-employee (2026-08-26)
Funziona per dipendente senza storico. OK. Limite noto: nessun cascade su tabelle con dati storici - serve disattivazione, non delete.

## 3.1 - Backend self-signup (2026-08-28)
signup_code, resolve_signup_code, self-signup via edge function verificati in produzione. OK

## 3.2 - UI self-signup due passi (2026-08-29)
Due passi + anti brute-force (blocco dal 5° tentativo) verificati su device. OK

## 3.3 - Generazione PIN lato server (2026-08-30)
generate_employee_pin: 30 generazioni, sempre 4 cifre incl. zero iniziale, mai il valore di test. OK

## 3.6 - Disattivazione dipendente -> T9 parziale (2026-09-12)
Disattivazione/riattivazione da UI, login rifiutato con messaggio italiano, auto-disattivazione bloccata (409). OK

## 3.9 - Rigenerazione signup_code (2026-09-17)
Da UI: vecchio codice rifiutato dopo rigenerazione, nuovo funziona. OK
