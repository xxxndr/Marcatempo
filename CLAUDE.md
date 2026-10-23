# CLAUDE

Indice argomento -> file -> sezione. Fonte di verità vive nei file collegati, mai duplicata qui.

## Indice — notes/product/app.md

- nome progetto, nome commerciale white-label -> nome
- vincolo sicurezza client dumb -> architettura_sicurezza_protezione_prodotto
- obiettivo app -> obiettivo_app
- stack Flutter/Supabase/pooling/multitenancy/struttura repo -> stack_tecnologico_scelto
- ruoli, self-signup, codice locale, PIN -> ruoli_e_flusso_di_utilizzo.ordine_di_creazione_degli_accessi
- limite email Supabase free / SMTP -> ruoli_e_flusso_di_utilizzo.invio_email_limite_piano_gratuito_supabase
- cosa vede/fa l'Admin titolare -> ruoli_e_flusso_di_utilizzo.lato_admin_titolare
- cosa vede/fa il dipendente -> ruoli_e_flusso_di_utilizzo.lato_dipendente
- creazione/eliminazione profilo dipendente (edge function) -> ruoli_e_flusso_di_utilizzo.creazione_ed_eliminazione_profilo_dipendente_edge_function
- QR dinamico, sicurezza timbratura -> autenticazione_e_sicurezza_della_timbratura
- offline-first doppia scrittura -> gestione_della_connessione_assente_offline_first
- griglia Admin, drag-and-drop -> interfaccia_admin
- tabella contract_types (CCNL), criterio inclusione -> tipo_di_contratto_ccnl
- generazione automatica turni, aree, copertura minima -> generazione_automatica_dei_turni
- supplementare vs straordinario -> ore_supplementari_e_cambio_turno
- PDF paghe, invio email -> export_per_ufficio_paghe
- condividi/accetta/modifica turni -> proposta_e_accettazione_turni
- ruolo Manager, gate revisione Admin -> ruolo_manager_intermedio
- agente IA (futuro, fuori scope) -> estensione_futura_agente_ia
- riposi/orari CCNL Fipe-Confcommercio -> vincoli_di_legge_sullorario_di_lavoro
- ROL/ex festività -> permessi_retribuiti_rol_ex_festivita
- infortunio INAIL -> infortunio_sul_lavoro_inail
- privacy malattia/infortunio per Manager -> visibilita_malattia_infortunio_ruolo_manager_privacy
- PIN come fallback esteso -> pin_come_fallback_esteso
- turni notturni, fuso orario -> turni_notturni_e_ora_legale
- canali notifica (push/popup/email opzionale) -> notifiche_cambio_turno_e_ore_supplementari
- NFC (scartato) -> nfc_valutato_e_scartato
- conservazione dati, immutabilità GDPR -> conservazione_dati_gdpr
- domande ancora aperte -> punti_ancora_da_definire
- disponibilità dichiarata dal dipendente (calendario) -> disponibilita_dichiarata_dal_dipendente_calendario
- tetto ore contrattuali, stanchezza (futuro) -> scelte_app_basate_su_questi_vincoli
- statistiche assenze ingiustificate (futuro) -> estensione_futura_statistiche_assenze_ingiustificate

## Indice — notes/legal/law.md

- contratto corretto (CCNL Fipe-Confcommercio) vs contratto pirata da non usare -> contratto_di_riferimento
- riposi giornaliero/settimanale, massimali orario, CCNL Fipe -> orario_di_lavoro_riposi_e_massimali
- clausole elastiche/flessibili part-time, revoca -> clausole_elastiche_e_flessibili_nel_part_time
- supplementare vs straordinario -> supplementare_vs_straordinario
- arrotondamento/tolleranza timbratura -> arrotondamento_e_tolleranza_sulla_timbratura
- ROL/ex festività -> permessi_retribuiti_rol_ex_festivita
- infortunio INAIL -> infortunio_sul_lavoro_inail
- terminologia assenze (ingiustificata) -> terminologia_delle_assenze
- privacy dati sanitari malattia/infortunio -> privacy_dati_sanitari_malattia_infortunio
- GDPR base legale e conservazione dati -> gdpr_base_legale_trattamento_e_conservazione_dati
- controlli a distanza, GPS, biometria facciale, buddy punching -> controlli_a_distanza_gps_e_biometria_facciale

## Altri file

- notes/product/screens.md -> albero sezioni/schermate per ruolo (Admin, Manager, Dipendente)
- notes/dev/architecture.md -> decisioni di architettura del codice Flutter (state management, DI, organizzazione cartelle) ed esempio di tree
- notes/roadmap.md -> roadmap a blocchi, stato reale (campo fatto true/false), stime ore — solo liste/checkpoint, motivazioni in product/app.md
- notes/test/history.md -> log test manuali già eseguiti, un blocco per sezione
- notes/test/tests.md -> guida ai test automatici da fare: tre livelli (flutter test, pgTAP via psql, deno test), nessuno richiede Docker
- notes/dev/refactor.md -> debito tecnico da rientrare: indici mancanti, policy RLS da wrappare in select, Drift al posto dei file JSON, Zod sugli input delle edge function
- notes/dev/environment.md -> tooling macchina locale stabile: OS, versioni Flutter/Android Studio/SDK, device di test, comandi Supabase CLI, pattern deploy edge function
- notes/dev/decisions.md -> log problemi risolti/decisioni tooling: SDK Android licenze, pattern Edge Function withSupabase, edge function locali impossibili, setup graphify/Gemini, backend estrazione semantica (Gemini/Groq), cifratura DB Supabase, timezone DB sempre UTC, errore "user is banned" non tradotto, pausa progetto free tier, backup notturni rotazione 5 file, limiti piano free vs 10-20 dipendenti
- notes/business/marketing.md -> pricing e concorrenti, unico file per questo
- notes/legal/law.md -> unica fonte per i fatti di diritto del lavoro italiano (CCNL Fipe-Confcommercio, D.Lgs., Garante Privacy) — product/app.md contiene solo le decisioni di prodotto e rimanda qui per la fonte legale
- notes/test/credentials.yaml -> credenziali account di test su Supabase cloud
- notes/test/study.md -> test delega/studio/non-delegare per ogni attività fatto:false della roadmap
- notes/business/ascom.md -> script di presentazione ad ASCOM Bologna per procurarsi i primi clienti di prova
- notes/business/competitor.md -> piano di test pratico delle app concorrenti su emulatore Android
- notes/product/schema.md -> campi della timbratura locale sul dispositivo (contenitore: tabella Drift, vedi dev/refactor.md R3)
- supabase/migrations/ -> schema Postgres via migration, RLS, seed.sql

## Regole operative

- Questo file resta sintetico: una riga per regola, motivazioni e cronaca nei file collegati
- Mai inventare per riempire un vuoto (dato di legge, design, output di un tool): dire che non è specificato e chiedere. Su diritto del lavoro italiano nessuna scorciatoia — precedente: product/app.md -> permessi_retribuiti_rol_ex_festivita
- Valutare la struttura prima di scrivere, non solo la correttezza del file: modularità, separazione UI/server/logica, duplicazione. Se c'è un'alternativa più solida della più diretta, dirla invece di procedere in silenzio
- Commenti minimali: solo in cima al file (cosa fa, perché esiste), nessun commento nel corpo del codice
- Metodo di scrittura (è ciò che permette ad Andrea di studiare): prima un piano di intervento a passi, poi chiedere conferma per partire con le modifiche o la creazione dei file. Una sola modifica per risposta: prima di passare alla successiva, fermarsi e chiedere conferma — la pausa dà spazio alle domande
- Ambiente di sviluppo -> notes/dev/environment.md -> Macchina
- Su "prossimo step?": rispondere subito con la riga `prossimo step:` di roadmap.md, senza ricognizione; controllo approfondito solo quando si inizia davvero a scrivere quello step
- Risposte brevi di default, ma senza tagliare informazione: se il tema è complesso, spiegare per intero comunque
