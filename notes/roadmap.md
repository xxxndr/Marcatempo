# roadmap

- metodo: blocchi piccoli da zero
- attività: stima ore comprensiva di codice+studio+test+fix bug
- checkpoint: chiude il blocco
- riferimento commit: numero attività (es. "completato 0.1")
- formato riga: `n [OK]/[] ore testo`
- prezzo/commerciale: solo in business/marketing.md
- prossimo step: 4.1t -> 4.2

## Blocco 0 — Setup account e ambiente

Checkpoint: flutter doctor senza errori bloccanti, dashboard Supabase accessibile, progetto Firebase collegato. Ore totali: 5.8

- 0.1 [OK] 0.3h Creare account Supabase (piano gratuito)
- 0.2 [OK] 2h Installare Flutter SDK + editor (VS Code consigliato)
- 0.3 [OK] 1h Installare Android Studio (solo per SDK/emulatore Android)
- 0.4 [OK] 0.2h Creare progetto Supabase vuoto (regione EU)
- 0.5 [OK] 1h Collegare dispositivo Android reale o emulatore, verificare flutter doctor pulito
- 0.6 [OK] 0.3h Configurare la stringa di connessione con il pooler Supavisor in transaction mode (porta 6543)
- 0.7 [OK] 1h Creare progetto Firebase e collegarlo a Supabase/Flutter (necessario per le notifiche push FCM del Blocco 6)

## Blocco 1 — Schema del database (solo SQL, niente app)

Checkpoint: rivediamo insieme lo schema prima di scrivere Dart. Ore totali: 19

- 1.1 [OK] 7h Progettazione e creazione tabelle (dipendenti, ruoli, turni, timbrature, assenze, log sincronizzazione), studio base di Supabase (Table Editor, SQL Editor) e verifica relazioni
- 1.2 [OK] 2h Policy RLS (Row Level Security) per separare Admin/Manager/Dipendente, con test di accesso
- 1.3 [OK] 1h Vincolo di non-cancellazione automatica (conformità GDPR, 5-10 anni di conservazione)
- 1.4 [OK] 5h Multitenancy: tabella clients + colonna client_id su ogni tabella, aggiornamento di tutte le policy RLS per isolare anche per cliente (oltre che per ruolo), test con due clienti finti in parallelo per verificare che non si vedano i dati a vicenda
- 1.5 [OK] 2h Policy RLS dipendente↔dipendente: un dipendente legge solo le proprie righe (user_id = proprio utente), Admin/Manager vedono tutti i dipendenti del cliente, test con due dipendenti finti
- 1.6 [OK] 2h Campi anagrafica per la generazione automatica dei turni (vedi Blocco 10): weekly_contracted_hours, has_fixed_weekly_schedule, template giorno-per-giorno (riposo/continuativo/spezzato), senior

## Blocco 2 — Scheletro Flutter + login Admin

Checkpoint: login Admin funzionante su dispositivo reale. Ore totali: 9

- 2.1 [OK] 5h Progetto Flutter, collegamento client Supabase, studio struttura base di un progetto Flutter (widget, cartelle, hot reload)
- 2.2 [OK] 4h Login Admin (email/password), build su device, test e fix

## Blocco 3 — Gestione dipendenti (self-signup via codice locale + PIN)

Checkpoint: un dipendente finto si registra da solo con il codice del locale e appare correttamente nella schermata Admin; gestione dipendenti reali di prova senza errori. Ore totali: 31

- 3.1 [OK] 3.5h Backend: signup_code su clients + funzione di risoluzione + edge function self-signup, niente UI, test da terminale (dettagli: product/app.md)
- 3.2 [OK] 2.5h UI: schermata Admin per il codice + pagina self-signup, test (dopo che 3.1 funziona)
- 3.3 [OK] 2.5h Generazione PIN personale lato server, test
- 3.4 [OK] 6.5h Schermata Admin gestione dipendenti: lista, promozione ruolo, eliminazione, fallback manuale (create-employee corretta), test
- 3.5 [OK] 5.5h Form esteso anagrafica (ore contrattuali, orario fisso, Senior, ore di default — dettagli: product/app.md), test
- 3.6 [OK] 4h Disattivazione dipendente, non cancellazione (dettagli: test/history.md 2026-09-12)
- 3.7 [OK] 1h Bootstrap primo cliente: crea clients, passa il codice, promozione manuale ad Admin, test
- 3.8 [OK] 1h Opzionale: condividi codice via share-sheet nativo (share_plus), test
- 3.9 [OK] 1.5h Rigenerazione signup_code dalla schermata Admin (funzione SQL SECURITY DEFINER dedicata, dettagli: test/history.md), test
- 3.10 [OK] 1h Autofill sistema (Google/Keychain) su email/password in login e self-signup: autofillHints + AutofillGroup, test. Escluso create-employee (motivo: product/app.md -> creazione_ed_eliminazione_profilo_dipendente_edge_function)
- 3.11 [OK] 2h Refactor: scheletro form (Center -> ConstrainedBox(360) -> Form -> FilledButton con spinner) duplicato identico in 5 pagine (login, self-signup, complete-signup, create-employee, edit-employee) — estrarre in un widget condiviso (app_form_scaffold.dart)

## Blocco 4 — Griglia turni, range configurabile (drag-and-drop)

Checkpoint: griglia turni stabile e usabile su dispositivo reale. Ore totali: 16.5

- 4.1 [OK] 7h UI calendario a griglia (range di giorni configurabile dall'Admin, default 7, non più fisso al mese): migration grid_range_days su clients + funzione SECURITY DEFINER, clients_repository, shifts_repository (query filtrata per intervallo, non stream), shift_time_utils (fuso Europe/Rome via libreria timezone), primo Notifier Riverpod del progetto (shifts_notifier, stato condiviso tra header e griglia), shifts_grid_page, shifts_settings_page — ore originali (4h) non più valide, scope cresciuto
- 4.1t [] 0h Test su device di 4.1, rimandato dalla notte del 23/09 (ore già dentro la stima di 4.1)
- 4.2 [] 9.5h Drag-and-drop turni (trascina/allunga blocco), lunghezza di default del blocco appena creato = template del giorno se orario fisso, altrimenti default_shift_hours del dipendente (Blocco 3.5) se flessibile, inizio/fine turno salvati come data+ora completa su fuso orario IANA (Europe/Rome, gestisce da solo il cambio ora legale), test con un mese di prova, casi limite (turno che attraversa la mezzanotte), fix

## Blocco 5 — Ferie e malattie nella griglia

Checkpoint: ferie/malattie visibili correttamente in griglia. Ore totali: 3

- 5.1 [] 3h Icone cliccabili per le 5 assenze (F/M/ING/INF/P, vedi product/app.md), collegamento al servizio di aggregazione ore, test

## Blocco 6 — Notifiche (push FCM + email)

Checkpoint: notifica push ricevuta con app in foreground, background e completamente chiusa; popup in-app e toggle email funzionanti. Ore totali: 14

- 6.1 [] 4h Integrazione Firebase Cloud Messaging in Flutter (plugin, permessi notifiche, gestione token dispositivo), studio base FCM
- 6.2 [] 5h Edge Function di trigger (evento/webhook Supabase -> Edge Function -> FCM -> telefono), test invio
- 6.3 [] 2h Popup in-app (sempre attivo, non disattivabile) come canale garantito accanto al push
- 6.4 [] 3h Toggle email per-utente nelle impostazioni notifiche (default attivo, opt-out, stile Tinder), flag booleano nel profilo controllato lato server, riusa infrastruttura email del Blocco 18

## Blocco 7 — Proposta e accettazione turni (nucleo)

Checkpoint: un ciclo completo Condividi -> Accetta/Modifica -> eventuale nuova proposta funziona senza perdite di stato. Ore totali: 19

- 7.1 [] 1h Stato del turno esteso a tre valori (status): pending / accepted / modified
- 7.2 [] 4h Tasto "Condividi" sulla griglia: invio in un'unica azione a tutti i dipendenti coinvolti, ciascuno con vista personalizzata dei soli propri turni
- 7.3 [] 5h Nuova sezione dashboard dipendente "Orari di lavoro" (lista turni con stato)
- 7.4 [] 4h Tasti Accetta/Modifica, con textarea di motivazione obbligatoria su Modifica prima di poter confermare
- 7.5 [] 2h Notifica di ritorno all'Admin su richiesta di modifica (riusa infrastruttura Blocco 6); nessuna chat: l'Admin rifà la proposta da zero nella griglia
- 7.6 [] 3h Test scenari completi (accetta, modifica, Admin rifà proposta, storico conservato)

## Blocco 8 — Proposta e accettazione turni (offline-first risposta dipendente)

Checkpoint: nessuna risposta del dipendente persa in almeno 5 cicli di test online/offline misti, conflitti di versione gestiti correttamente. Ore totali: 12

- 8.1 [] 4h Scrittura locale immediata della risposta (Accetta/Modifica) in JSON per singolo evento (shift_id, user_id, status, reason se modified, timestamp, versione del turno a cui si riferisce)
- 8.2 [] 5h Sync automatico al ritorno della connessione, con controllo di coerenza sulla versione del turno (risposta scartata/segnalata se obsoleta, non applicata alla cieca)
- 8.3 [] 3h Test scenari online/offline/conflitto di versione (risposta data mentre l'Admin ha nel frattempo rifatto la proposta)

## Blocco 9 — Ruolo Manager

Checkpoint: permessi Manager e flusso di revisione Admin confermati e testati. Ore totali: 13

- 9.1 [] 4h Permessi base: turni/griglia sì (come Admin), export PDF e dati economici no
- 9.2 [] 3h Gate sul tasto Condividi: se a premerlo è il Manager, la proposta va prima in revisione ad Admin invece che ai dipendenti
- 9.3 [] 2h Revisione Admin: editing diretto nella stessa griglia drag-and-drop (non i tasti Accetta/Modifica del dipendente, perché Admin ha già pieno accesso di editing); solo quando Admin stesso preme Condividi scatta il flusso verso i dipendenti
- 9.4 [] 2h Notifica di riepilogo al Manager con tutti i cambiamenti fatti da Admin sul batch intero (riusa pattern "notifica di ritorno" del Blocco 7.5)
- 9.5 [] 2h Test scenari completi (Manager propone, Admin accetta invariato, Admin modifica, doppio ruolo Manager-anche-dipendente sui propri turni)

## Blocco 10 — Generazione automatica dei turni

Checkpoint: una proposta generata su un mese di prova rispetta ore contrattuali, riposo minimo e copertura per ogni area, senza mai spostare i dipendenti Senior; la funzione di controllo segnala correttamente le stesse violazioni anche su turni fatti a mano. Ore totali: 40

- 10.1 [] 3h Aree: nuova tabella areas, CRUD Admin (crea/rinomina/elimina liberamente), campo area_id aggiunto qui al form dipendente del Blocco 3.5 (non prima: la tabella areas non esiste ancora al Blocco 3) — ogni dipendente appartiene a una sola area
- 10.2 [] 2h Orario di apertura/chiusura del locale: nuovo campo a livello di cliente, usato come guida (non blocco) quando l'Admin crea un turno in griglia — sempre superabile per eventi speciali
- 10.3 [] 3h Schermata copertura minima, separata dalla griglia: giorno della settimana, ora inizio, ora fine, area, numero minimo di dipendenti — editabile in ogni momento
- 10.4 [] 3h Calcolo automatico di quante persone sono realmente presenti in una data fascia/area, contando i turni già in griglia che coprono quell'orario — mai inserito a mano
- 10.5 [] 5h Algoritmo server-side, prima passata: piazzamento automatico dei dipendenti con flag "Senior" secondo il loro template settimanale
- 10.6 [] 8h Algoritmo server-side, seconda passata: riempimento dei dipendenti flessibili rispettando ore contrattuali settimanali, riposo minimo (legal/law.md -> orario_di_lavoro_riposi_e_massimali) e copertura minima per area
- 10.7 [] 3h Integrazione nella griglia esistente: il risultato appare come proposta editabile, l'Admin la corregge se serve e la condivide con il flusso già esistente (Blocco 7) — nessun bottone di randomizzazione, scelta deliberata per priorità alla sicurezza legale
- 10.8 [] 4h Funzione di controllo sempre attiva, non bloccante: dopo ogni creazione turni (a mano o generati) verifica riposo minimo, ore contrattuali sforate, copertura minima per area — solo avviso ad Admin, mai un blocco
- 10.9 [] 5h Test scenari completi (dipendenti Senior mai spostati, copertura non raggiungibile segnalata non ignorata, riposo minimo mai violato, ore contrattuali rispettate, avvisi corretti su turni fatti a mano)
- 10.10 [] 4h Disponibilità dichiarata dal dipendente: pagina calendario (Dipendente), selezione giorno/fascia oraria, motivo libero non obbligatorio, notifica ad Admin, vincolo automatico nell'algoritmo (10.5/10.6) senza bisogno di conferma Admin, test

## Blocco 11 — QR dinamico (server + kiosk)

Checkpoint: QR dinamico funzionante su un secondo dispositivo ("fisso al bar"). Ore totali: 9

- 11.1 [] 6h Edge function per generazione/rotazione QR ogni 10 secondi, validazione lato server con margine di 2 secondi sul QR appena scaduto (vedi notes/product/app.md, sezione "Autenticazione e sicurezza"), studio concetto di edge function, test rotazione
- 11.2 [] 3h Schermata "modalità kiosk" da esporre fisicamente al locale — schermo sempre acceso, risparmio batteria disattivato per l'app, nessun blocco/sblocco richiesto — test leggibilità da smartphone reale

## Blocco 12 — Timbratura dipendente (scan QR + offline-first)

Checkpoint: nessuna timbratura persa in almeno 5 cicli di test online/offline misti — componente più critico del progetto. Ore totali: 13.5

- 12.1 [] 3h Scansione QR da smartphone dipendente, test
- 12.2 [] 6h Scrittura JSON locale per evento (mai file mensile unico) + stato "in attesa di sincronizzazione", test online/offline
- 12.3 [] 3h Sync automatico al ritorno della connessione, test (modalità aereo, riattivazione, verifica su Supabase)
- 12.4 [] 1.5h Conferma visiva post-timbratura (nome, cognome, promemoria uscita)

## Blocco 13 — PIN come fallback

Checkpoint: PIN e QR producono lo stesso risultato lato dati. Ore totali: 3

- 13.1 [] 3h Timbratura alternativa via PIN (stesso flusso dati del QR, copre anche il caso "dispositivo del bar offline e senza QR aggiornato"), test che non generi falsi allarmi

## Blocco 14 — Confronto orario reale vs pianificato

Checkpoint: ritardi rilevati correttamente, nessun falso positivo/negativo. Ore totali: 5

- 14.1 [] 5h Logica server-side di confronto timbratura/turno pianificato, segnalazione ritardi, test

## Blocco 15 — Ore supplementari e cambio turno (validazione Admin)

Checkpoint: classificazione supplementare/straordinario corretta su casi di prova part-time e full-time, flusso di approvazione testato. Ore totali: 12

- 15.1 [] 3h Rilevamento ore oltre il turno pianificato, salvate separate finché non confermate
- 15.2 [] 2h Rilevamento cambio turno (dipendente diverso da quello pianificato), notifica push + popup in-app sempre attivo all'Admin (riusa Blocco 6.2/6.3) — corretto il 2026-08-27, non più via email: il limite email del piano gratuito Supabase la rende inadatta come canale garantito, vedi notes/product/app.md sezione "Invio email"
- 15.3 [] 3.5h Popup di validazione Admin (conferma/rifiuta), dato che passa a Supabase solo dopo conferma, test scenari
- 15.4 [] 2h Classificazione automatica supplementare/straordinario in base a weekly_contracted_hours (vedi notes/product/app.md, sezione "Ore supplementari e cambio turno" — regola definita dalla legge, non serve chiarimento con l'ufficio paghe del cliente), test su casi part-time e full-time
- 15.5 [] 1.5h Notifica in sola visualizzazione al Manager (stesso canale di Admin, nessun tasto di conferma/rifiuto): il potere di approvare resta esclusivo di Admin, anche in sua assenza prolungata

## Blocco 16 — Conteggio ritardi e richieste di modifica turno per dipendente

Checkpoint: contatori coerenti con i dati reali di un mese di prova. Ore totali: 3

- 16.1 [] 3h Contatore per dipendente su due dati separati (riusa dati già raccolti dai Blocchi 14 e 7): numero di ritardi rilevati, numero di richieste di modifica turno (stato modified) — puramente informativo per l'Admin

## Blocco 17 — Servizio di aggregazione giornaliera ore

Checkpoint: totali di prova coincidono con il calcolo manuale. Ore totali: 5

- 17.1 [] 5h Servizio che accumula ore normali, supplementari confermate, malattie, ferie per dipendente/giorno, verifica manuale dei totali su un mese di prova

## Blocco 18 — Export PDF mensile e invio email

Checkpoint: un mese completo di dati di prova produce un PDF corretto al 100%, export turni funzionante. Ore totali: 13

- 18.1 [] 6h Generazione PDF (ore ordinarie, supplementari confermate, ferie, malattie) lato server, verifica di ogni cifra a mano (componente ad alta criticità)
- 18.2 [] 3h Invio email manuale con autocomplete indirizzi già usati, test
- 18.3 [] 3h Export PDF via email del turno (settimanale/mensile) come canale di riserva per chi non può usare l'app, riusa la stessa infrastruttura di generazione PDF/invio manuale dei punti precedenti
- 18.4 [] 1h Vincolo di non-cancellazione su shifts (stesso trigger + tabella gemella shifts_anomalies già usati per timeclock_events/absences nel Blocco 1.3) — da qui in poi un turno esportato ha valore economico/legale

## Blocco 19 — Backup automatico

Checkpoint: backup notturno attivo e verificato per almeno una settimana reale (tiene sveglio anche il progetto Supabase free tier). Ore totali: 6

- 19.1 [] 6h Script GitHub Actions: dump notturno via Supabase CLI, rotazione a 5 file (backup_YYYY-MM-DD.sql), studio concetto di secrets GitHub, test trigger manuale e rotazione

## Blocco 20 — Test end-to-end, beta reale, rilascio

Checkpoint: nessun bug bloccante dopo la settimana di beta reale -> rilascio. Ore totali: 17+

- 20.1 [] 3h Audit di coerenza legale-numerica: ogni soglia numerica in migration/edge function con significato legale (riposi, ore massime, supplementare/straordinario) confrontata con notes/legal/law.md, verifica che numeri collegati tra loro siano coerenti (es. turno massimo derivato dal riposo minimo). Non certifica la correttezza di legal/law.md stesso, solo la coerenza interna del codice — la revisione legale resta a un consulente del lavoro, fuori da questa attività
- 20.2 [] 2h Build APK di release, checklist finale pre-lancio
- 20.3 [] 12+h Beta reale in un bar/ristorante con dipendenti veri per qualche giorno, raccolta feedback, correzione bug emersi (variabile: dipende da quanti bug emergono sul campo)

## Blocco 21 — Impostazioni

Checkpoint: toggle tema chiaro/scuro funzionante e persistente tra riavvii. Ore totali: 2

- 21.1 [OK] 2h Pagina Impostazioni condivisa Admin/Manager/Dipendente, punto d'appoggio per le voci di configurazione future. Prima voce: toggle tema chiaro/scuro/sistema (ThemeMode su MaterialApp, persistito con shared_preferences, nuova dipendenza), test

## Totale generale

~267.8 ore (Blocco 20 variabile, potrebbe aumentare in base ai bug emersi in beta reale).

Le stime sono per singola iterazione di ogni blocco: se un blocco richiede più di un giro di correzioni, le ore vanno moltiplicate di conseguenza. L'estensione futura con agente IA è esclusa da questa stima, valutata a parte a app base completa.

## Estensione futura: agente IA

Fuori scope dai blocchi 0-20, da riprendere solo a app base completata. Disegno tecnico completo in product/app.md -> estensione_futura_agente_ia. Prezzo/strategia commerciale in business/marketing.md.

Come lo integreremmo:

- solo lato server (Edge Function Supabase, Deno), mai nel client Flutter compilato
- l'agente è un utente Supabase con permessi Manager, mai Admin — stesse policy RLS di un Manager umano, zero policy nuove da scrivere
- motore: Claude in modalità tool use, con un insieme chiuso di strumenti mappati su RPC Postgres già vincolate da RLS (propose_shift, read_availability, read_employee_requests, generate_shifts)
- ogni proposta dell'agente passa dallo stesso gate Condividi -> revisione Admin già costruito per il Manager umano (Blocco 9) — nessun gate nuovo
- log di controllo append-only (ai_agent_log), visibile ad Admin
- chiave API Anthropic fornita e gestita dal singolo cliente (bring your own key), salvata cifrata per client_id — nessuna fatturazione a consumo gestita da noi
