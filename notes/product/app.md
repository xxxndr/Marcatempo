# app

prodotto/architettura, fonte di verità principale

## nome

- **interno:** Marcatempo, nome di lavoro tra i due — il cliente finale sceglie il nome commerciale white-label
- **nome_iniziale_abbandonato:** 'Due Terzi' — valido solo quando il progetto era pensato per un solo amico, non più: è un prodotto vendibile

## architettura_sicurezza_protezione_prodotto

Priorità: **massima**.

- **regola:** il client Flutter è ridotto a semplice interfaccia grafica; tutta la logica di business critica (calcolo ore, turni, generazione PDF) vive lato server Supabase (funzioni DB/edge function), mai duplicata nel Dart compilato
- **motivo:** protegge il prodotto da reverse engineering sull'APK e permette demo a tempo limitato disattivando l'accesso lato server, senza blocchi lato client aggirabili

## obiettivo_app

App per bar/ristoranti/altre imprese: dipendenti timbrano entrata/uscita in modo semplice e affidabile; titolare gestisce turni mensili (incl. ferie/malattie) e controlla automaticamente puntualità/ritardi.

## stack_tecnologico_scelto

### Frontend

- scelta: Flutter (Dart)
- motivi:
  - accesso nativo affidabile a fotocamera per QR
  - adatto a sviluppo AI-guidato, codice pulito
  - sintassi tipizzata simile a TypeScript, struttura a classi simile PHP/Laravel — curva dolce per lo sviluppatore
- alternativa scartata: React Native — preferibile solo se priorità fosse riuso competenze JS/TS, ma Flutter integra meglio la fotocamera

### Backend

- scelta: Supabase
- motivi:
  - dati relazionali (dipendente -> turni -> timbrature), Postgres li gestisce nativamente
  - gratuito per volume di un singolo bar
  - nessun server proprio da gestire
- alternativa scartata: Firebase/Firestore — NoSQL si adatta peggio a dati relazionali

- **connection_pooling:** Supavisor in transaction mode (porta 6543) per contenere RAM sul piano free; client Flutter passa sempre da PostgREST/RPC, mai connessione diretta a Postgres

### Multitenancy

- approccio: schema Postgres condiviso tra tutti i clienti, colonna client_id su ogni tabella, isolamento via RLS (policy verifica client_id riga = client dell'utente autenticato) — isolamento garantito dal DB, non dal client Dart
- alternative scartate:
  - progetto Supabase per cliente: moltiplica i limiti free per cliente, ogni progetto si pausa dopo 7gg inattività, N dashboard da monitorare
  - schema Postgres per cliente nello stesso progetto: isolamento intermedio ma migration manuali per schema, PostgREST richiede config esplicita per più schema
- portabilità: tabelle Postgres standard in ogni caso, compatibili con pg_dump già usato per i backup notturni
- RLS dipendente↔dipendente: isolamento per client_id non basta: seconda policy indipendente, un dipendente legge solo righe (turni/timbrature) dove user_id = proprio utente, mai i colleghi. Admin/Manager vedono tutti i dipendenti del proprio cliente

- **struttura_repository:** deciso 2026-08-24: quando arriverà (Blocco 2.1) il progetto Flutter nasce nella stessa cartella radice di questo repository, accanto a supabase/ (flutter create .), non in una sottocartella né in un repository separato

## ruoli_e_flusso_di_utilizzo

### ordine_di_creazione_degli_accessi

- riscritto: 2026-08-27, sostituisce la decisione del 2026-08-26: niente più invito via email
- motivo: piano free Supabase limita invio email a 2/ora — inutilizzabile con 10-20 dipendenti da registrare in una sessione (fonte: github.com/supabase/supabase/issues/34209)
- flusso:
  - codice_locale: clients.signup_code, 8 caratteri alfanumerici maiuscoli esclusi 0/O 1/I/L, generato alla creazione cliente. Admin lo rigenera in ogni momento — codice precedente smette subito di funzionare (unico meccanismo di revoca)
  - registrazione: dipendente fa sign-up standard Supabase Auth (email/password propria, nessuna email di sistema), inserisce signup_code e first_name/last_name (obbligatori su employees, unico punto di raccolta). Bottone 'Condividi' (Blocco 3.8, share_plus, zero config nativa Android) per mandare il codice su WhatsApp
  - risoluzione_codice: il dispositivo appena autenticato non può leggere clients (RLS) — funzione SECURITY DEFINER dedicata (pattern di current_employee_client_id(), vedi supabase/migrations/20260823143300_current_employee_client_id_function.sql) restituisce solo il client_id dal codice, mai l'elenco clienti/codici
  - completamento: Edge Function con secret key risolve il codice, crea riga employees (client_id, first_name/last_name dal form, role='employee' sempre forzato, mai dal form)
  - login: email reale + password, standard Supabase Auth, invariato
  - promozione_manager_admin: Admin fa update diretto su role di un profilo già registrato, coperto da RLS employees_write_admin
  - bootstrap_cliente_nuovo: Andrea crea riga clients (genera da sola signup_code), passa il codice al titolare che si registra come chiunque altro; Andrea promuove l'account ad admin con update diretto — manuale, una tantum, mai in-app
  - creazione_manuale_admin: fallback per chi non riesce a completare da solo il self-signup (non per chi non ha smartphone, quel caso è coperto dal PIN). Riusa create-employee (Blocco 3.4)
  - pin: non è una credenziale di accesso: metodo di timbratura quando il QR non è scansionabile, digitato sul dispositivo fisso del locale (non sul telefono del dipendente). Sempre presente: scelto dal dipendente al self-signup o assegnato da Admin nella creazione manuale. Il QR non è personale, è unico e del bar
- analisi_sicurezza_2026-08-27:
  - nessun rischio privilegio: role sempre forzato a employee lato server
  - rischio residuo: chi ottiene il codice senza essere dipendente vero può auto-registrarsi e comparire in lista, ma non legge dati altrui (RLS dipendente↔dipendente invariata). Mitigazione: rigenerazione codice on-demand da Admin
  - GDPR/Statuto Lavoratori: nessun impatto, vedi legal/law.md -> GDPR: base legale del trattamento e conservazione dati

### invio_email_limite_piano_gratuito_supabase

- limite: 2 email/ora con SMTP di default (ricerca web 2026-08-27)
- valutazione_per_uso:
  - self_signup: non manda mai email, limite non si applica
  - pdf_paghe_mensile: invio manuale, un file/dipendente al mese, 2/ora (48/giorno) bastano anche per 10-20 dipendenti spalmando nella giornata
  - comunicazioni_importanti: canale garantito è push (Blocco 6) + popup in-app (Blocco 6.3), non email
  - notifiche_email_opzionali: solo extra facoltativo, basso volume, limite free sufficiente
- conclusione: nessuna configurazione SMTP ora né pianificata, si riapre solo se un volume reale la richiedesse
- nota temporanea 2026-08-29, da chiudere prima del lancio:
  - trovato: progetto cloud aveva 'Confirm email' attivo (default, mai allineato a config.toml che lo prevede spento) — blocca il flusso self-signup in due passi (l'app non gestisce ancora il deep-link di ritorno)
  - azione_temporanea: disattivato 'Confirm email' solo sul DB di test/sviluppo (destinato a essere svuotato prima del lancio)
  - da_fare_prima_di_un_cliente_vero: riattivare Confirm email, configurare SMTP esterno (es. Resend) per il limite 2/ora, costruire gestione deep-link Android per il link di conferma

### lato_admin_titolare

- condivide signup_code coi nuovi dipendenti fuori app, gestisce profili (promozione, eliminazione, creazione manuale fallback)
- gestisce turni in griglia mensile drag-and-drop (trascina nome, allunga blocco per le ore)
- nella griglia inserisce anche ferie e malattie
- il sistema confronta automaticamente timbratura reale vs turno pianificato, segnala ritardi
- riceve popup di validazione per ore supplementari oltre il turno pianificato e cambi turno tra dipendenti

### lato_dipendente

- timbra entrata/uscita scansionando col proprio smartphone il QR fisso al bar (schermo/tablet in modalità kiosk)
- dopo la timbratura l'app mostra nome/cognome e conferma, con promemoria visivo (es. rosso) di marcare anche l'uscita

### creazione_ed_eliminazione_profilo_dipendente_edge_function

- base: employees.id è FK verso auth.users(id) on delete cascade (deciso 2026-08-25), aggiornato 2026-08-27 per il flusso self-signup via codice locale
- creazione_self_signup: dipendente fa sign-up standard (email/password proprie, nessuna email di sistema) + signup_code. Edge Function autenticata (JWT del nuovo utente) risolve il codice a client_id via funzione SECURITY DEFINER, inserisce riga employees con secret key (necessario: RLS employees_write_admin permette scrittura solo a chi è già admin). role sempre forzato a employee. Email sempre quella vera del dipendente — è il suo login definitivo + indirizzo notifiche opzionali
- creazione_fallback_manuale: invariato dal 2026-08-26, per problemi tecnici (non per chi non ha email). create-employee va ancora modificata (Blocco 3.4, non fatto): oggi genera email finta random, deciso che l'email deve diventare input obbligatorio (Admin scrive l'email vera). Password generata dalla function, role sempre employee, credenziali tornano nella risposta
- autofill_escluso_su_create_employee (decisione 2026-09-03): a differenza di login e self-signup (Blocco 3.10, autofillHints + AutofillGroup), su create-employee nessun autofill di sistema. Qui l'Admin inserisce le credenziali di un altro utente, ma l'autofill suggeriva le proprie — rischio concreto verificato su device (Samsung Pass)
- seed_locale: stessa create-employee, richiamata a mano da Andrea dopo db reset con email finte scelte a mano (es. mario.rossi@test.local) — mai insert diretto in auth.users da seed.sql (fragile secondo documentazione Supabase)
- eliminazione: auth.admin.deleteUser(), riga employees segue via on delete cascade. Funziona solo su dipendente senza storico (shifts/timeclock_events/absences/... referenziano employees(id) senza cascade di proposito, vedi conservazione_dati_gdpr)
- modifica: update diretto via RLS per nome/cognome/ruolo, nessuna Edge Function coinvolta
- disattivazione (Blocco 3.6, decisione 2026-09-11): mai esposto un pulsante "Elimina" in UI — un tap veloce da mobile su un dipendente sbagliato sarebbe una cancellazione di dati non recuperabile, sia rischio pratico (admin non tecnico) sia legale (perdita storico). L'eliminazione vera (delete-employee) resta nel codice solo per uso manuale da terminale, caso limite del dipendente creato per errore senza storico — mai richiamata dall'app. In UI esiste solo disattiva/riattiva (dettagli tecnici del meccanismo ancora in progettazione)

## autenticazione_e_sicurezza_della_timbratura

### qr_dinamico

- rotazione: ogni 10 secondi (deciso 2026-08-22)
- motivo: impedisce che il QR fotografato/trasferito su altro dispositivo venga riusato da remoto — un flusso a più passaggi richiede più di 10s anche allenato, un dipendente onesto scansiona in 1-2s
- validazione_server: accetta il QR attuale o l'appena scaduto, margine ~2s (assorbe solo latenza di rete, non basta per un tentativo di frode)

- **no_gps:** presenza fisica già garantita dal QR visibile solo al bar — evita di gestire GPS disattivato
- **pin:** metodo alternativo per emergenza (QR non leggibile/fotocamera non disponibile), non più legato al GPS
- **scalabilità:** valido indipendentemente dal numero di dipendenti
- **deterrente legale buddy punching (2026-09-02):** banner visibile solo ai dipendenti (non Admin/Manager), ricorda che timbrare per conto di un collega assente è giusta causa di licenziamento. Unica misura possibile, nessuna contromisura tecnica legale esiste per una piccola impresa senza RSU/RSA — ragionamento e fonte legale in legal/law.md -> controlli_a_distanza_gps_e_biometria_facciale. Dove/quando mostrarlo esattamente ancora da decidere
- **sblocco biometrico locale, valutato e scartato (2026-09-02):** idea scartata: il dipendente controlla lui stesso i blocchi del proprio telefono, può toglierli apposta per far usare il telefono a un collega — inutile contro una complicità voluta, che è il caso reale. Resta solo il deterrente legale sopra

## gestione_della_connessione_assente_offline_first

- meccanismo: ogni timbratura salvata prima in locale (un file JSON per evento, non un unico file mensile, per evitare corruzione su spegnimento improvviso), poi invio a Supabase; se manca connessione resta 'in attesa di sincronizzazione' e si invia da solo al ritorno della rete
- decisione 2026-08-30: una volta sincronizzato, il file locale NON viene cancellato — copia di riserva a costo zero in caso di perdita/corruzione lato server o contestazione, stesso principio dei backup DB

## interfaccia_admin

- griglia: range di giorni configurabile dall'Admin (impostazioni turni, default 7 giorni), non fissa a un mese — la cadenza dei turni varia da locale a locale, corretto 2026-09-24
- griglia: in-app per turni, ferie, malattie
- drag_and_drop: trascina nome dipendente, allunga/accorcia blocco per le ore, come MakeShift/Homebase/TimeTrex, nessun file esterno
- tipi assenza, corretto 2026-08-27: 5 tipi, non 2: F ferie, M malattia, ING ingiustificata, INF infortunio, P permesso (codici a 3 lettere per ING/INF per evitare scontro sulla lettera I; terminologia legale in legal/law.md -> Terminologia delle assenze)

## tipo_di_contratto_ccnl

- decisione 2026-08-30: tabella contract_types, non per-cliente (locali diversi condividono lo stesso CCNL), collegata a employees via contract_type_id (nullable, nessun default inventato)
- valori:
  - full_time_weekly_hours — soglia orario pieno, distingue supplementare/straordinario
  - daily_rest_hours — riposo minimo tra turni, usato dal generatore turni
- criterio_inclusione: un valore entra solo se (a) una funzionalità già decisa lo legge in una condizione, e (b) la legge conferma che varia da CCNL a CCNL (fonte daily_rest_hours: legal/law.md -> Orario di lavoro: riposi e massimali). ROL, comporto, preavvisi flessibilità, clausole elastiche/flessibili: tutti esclusi, restano solo testo di riferimento, mai calcolati
- seed_ccnl_fipe: Fipe-Confcommercio Pubblici Esercizi 2024: 40h / 11h, verificato su fipe.it

## generazione_automatica_dei_turni

- nuovi campi anagrafica:
  - weekly_contracted_hours: numero libero, non etichetta part-time/full-time (legal/law.md -> Orario di lavoro: riposi e massimali)
  - has_fixed_weekly_schedule: booleano
  - senior: booleano, priorità/protezione nell'algoritmo, indipendente dal precedente (nome scelto 2026-08-22 tra Storico/Elite/Senior)
  - area_id: ogni dipendente in una sola area
- template_orario_fisso: se has_fixed_weekly_schedule=true, template per ogni giorno (riposo, turno continuativo, o spezzato con due fasce), compilato una volta e riapplicato automaticamente. Se false, solo ore contrattuali settimanali, il generatore decide dinamicamente
- aree: categorie libere create da Admin (es. 'Area 1'), non nomi fissi cucina/sala per restare utili fuori da bar/ristoranti. Servono per la copertura minima (sapere 'quanti' non basta, serve 'dove')
- weekly_contracted_hours nullable: valorizzato solo nel form esteso Blocco 3.5, non alla creazione profilo (Blocco 3.1/3.2) — deciso 2026-08-25, nessun default numerico
- orario_apertura_chiusura_locale: aiuto in creazione turni, non blocco rigido (un evento speciale può richiedere turni oltre l'orario). La timbratura registra sempre la realtà
- copertura_minima: Admin la imposta in schermata separata (giorno, ora inizio/fine, area, numero minimo dipendenti), editabile sempre. Quanti presenti in una fascia non si inserisce mai a mano: calcolato dal sistema contando i dipendenti in griglia. Origine: episodio reale a Botanica Lab, turno scoperto per assenza non segnalata
- algoritmo a due passate:
  1. piazza automaticamente i Senior secondo il loro template, mai riproposti diversamente
  2. riempie gli slot rimanenti rispettando ore contrattuali, riposo minimo (legal/law.md -> orario_di_lavoro_riposi_e_massimali), copertura minima per giorno/fascia/area
- precisazione 2026-08-30: il riposo minimo si controlla solo tra ultimo turno del giorno e primo del giorno dopo, non tra le due fasce di uno spezzato nello stesso giorno — la pausa nello spezzato non ha un minimo nazionale fissato, nessun controllo applicabile lì (legal/law.md -> orario_di_lavoro_riposi_e_massimali)
- no_randomizzazione: scelta deliberata, priorità a sicurezza legale su varietà assegnazione
- output: proposta, non turno definitivo — entra nella griglia drag-and-drop, Admin la rivede/corregge, poi Condividi (vedi proposta_e_accettazione_turni)
- funzione_controllo_sempre_attiva: dopo creazione turni (manuale o generata) verifica: riposo minimo (legal/law.md -> orario_di_lavoro_riposi_e_massimali), ore contrattuali sforate, copertura minima raggiunta. Mai bloccante, solo avviso Admin — serve soprattutto per i turni fatti a mano
- lunghezza default blocco (2026-08-26):
  - orario_fisso: default = template giorno-per-giorno già in anagrafica, nessun calcolo
  - flessibile: scartata l'idea di weekly_contracted_hours/giorni lavorativi (il numero di giorni varia settimana per settimana per un flessibile, il dato non esiste). Deputy (tool reale) usa un default per dipendente basato sullo storico (fonte: help.deputy.com). Decisione finale: nuovo campo opzionale default_shift_hours, impostato a mano da Admin una volta per dipendente flessibile, riusato come lunghezza di partenza, sempre modificabile — nessun calcolo automatico, nessun dato inventato

## disponibilita_dichiarata_dal_dipendente_calendario

- stato: idea del 2026-08-29, non ancora costruita
- meccanismo: pagina calendario (passato/futuro), dipendente seleziona giorno + fascia oraria opzionale (o intera giornata) per dichiarare indisponibilità, motivazione libera non obbligatoria. Notifica push+banner ad Admin. Generazione automatica turni la rispetta come vincolo automatico, stesso trattamento dei Senior — nessuna conferma richiesta da Admin
- importante (2026-08-29): funzione deliberatamente informale, senza peso legale, uguale per tutti i dipendenti — non va confusa col meccanismo legale di revoca delle clausole elastiche/flessibili nel part-time (vedi legal/law.md)

## ore_supplementari_e_cambio_turno

- classificazione: l'app classifica da sola supplementare/straordinario usando weekly_contracted_hours — regola definita dalla legge (legal/law.md -> Supplementare vs straordinario), non da convenzione interna
- ore_supplementari: ore oltre il turno pianificato salvate separatamente dal totale normale (non sommate automaticamente), popup Admin per confermare/rifiutare
- franchigia simmetrica ±15min:
  - decisione: 2026-08-29 del titolare, senza consulenza legale professionale — ragionamento e fonti in legal/law.md -> Arrotondamento e tolleranza sulla timbratura
  - regola: timbratura entro ±15 min dall'orario pianificato -> arrotondata all'orario pianificato (niente supplementare né decurtazione). Oltre i 15 min, l'intera differenza conta (non solo l'eccesso oltre soglia)
- cambio_turno: se timbra un dipendente diverso da quello pianificato, la timbratura viene comunque registrata + popup Admin per confermare/giustificare
- dato_provvisorio: finché Admin non conferma, il dato resta solo nel file locale (offline-first); solo dopo conferma passa a Supabase come definitivo
- accumulo_giornaliero: servizio accumula ore normali, supplementari confermate, malattie, ferie separatamente — pronto per il PDF mensile
- ruolo_manager: riceve la stessa notifica di Admin ma in sola visualizzazione, nessun tasto conferma/rifiuto — potere di approvare resta esclusivo Admin anche se assente a lungo (vedi ruolo_manager_intermedio)

## export_per_ufficio_paghe

- PDF per dipendente/mese: ore ordinarie, supplementari confermate, ferie, malattie
- componente alta criticità: accuratezza dati non negoziabile, come il layer di scrittura file locale
- invio email manuale, indirizzo libero ad ogni invio (utile se cambia l'ufficio paghe), nessun invio automatico
- UX: autocomplete indirizzi già usati in invii precedenti

## proposta_e_accettazione_turni

- buco_originale: mancava come il turno creato da Admin arriva a conoscenza del dipendente
- flusso: Admin incastra gli orari poi un tasto Condividi invia le proposte a tutti in un'unica azione; ogni dipendente vede solo i propri turni in 'Orari di lavoro', non l'intera griglia
- no_negoziazione_diretta: anche per un cambio turno nato da accordo tra due dipendenti, restano sempre due proposte separate Admin -> dipendente — scelta deliberata: il titolare resta il fulcro, niente autonomia diretta tra dipendenti
- ui_dipendente: notifica + sezione 'Orari di lavoro' con proposta pending e due tasti: Accetta / Modifica
- scelta_lessicale: il bottone non si chiama 'Rifiuta' (troppo pesante psicologicamente) ma 'Modifica' — richiesta di aggiustamento, non insubordinazione. Cliccando Modifica è obbligatorio compilare un campo motivazione
- stati: pending (iniziale) -> accepted (confermato) oppure modified (richiesta modifica con motivazione, in attesa che Admin rifaccia la proposta)
- modifica_no_chat: una richiesta di modifica non apre una chat: genera notifica di ritorno ad Admin ('Dipendente X ha richiesto modifica al turno del giorno Y: [motivazione]'). Admin rifà la proposta da zero in griglia (nuovo giro Condividi, stato torna a pending) — perché modificare un turno spesso implica ricalcolare la copertura di altri dipendenti
- storico: le proposte con richiesta di modifica restano nello storico (coerente con conservazione dati GDPR), non cancellate
- fallback_pdf_email: tasto opzionale 'Esporta PDF' sulla stessa schermata, stesso flusso manuale dei cedolini (autocomplete indirizzi, nessun automatico) — per dipendente che non può usare l'app momentaneamente. Canale informativo di riserva, non sostituisce pending/accepted/modified
- turno non riscontrato entro inizio:
  - decisione: nessuno stato accepted scatta per timeout — fatti di legge (silenzio-assenso, potere direttivo datore, preavvisi CCNL) in legal/law.md -> Orario di lavoro: riposi e massimali e -> Clausole elastiche e flessibili nel part-time
  - motivo: il click esplicito Accetta/Modifica è già il consenso richiesto dalla legge per i part-time, indipendentemente dalle ore di preavviso — non serve distinguere part-time/full-time per questa funzionalità (l'anagrafica raccoglie ore/orario fisso per un motivo diverso: la generazione turni)
  - dettaglio: nessuna logica che rileva 'urgenza' del cambio turno (troppo fragile). Il contatore turni non riscontrati resta solo informativo, non una controfirma legale
  - banner_scartato (2026-09-14): pensato un banner fisso nel pannello Admin col promemoria preavvisi CCNL, tolto perché l'app non distingue i due casi legali rari (nuovo programma orario, clausola elastica pattuita) dal normalissimo cambio turno dell'ultimo minuto — sarebbe stato un testo fisso senza legame con cosa fa davvero l'Admin
- conteggio ritardi e richieste modifica:
  - descrizione: contatore per dipendente: numero ritardi rilevati (dal confronto automatico timbratura/turno) + numero richieste modifica (stato modified) — dato informativo per Admin, non collegato ad azioni automatiche
  - aggiunta 2026-08-30: la differenza in minuti già calcolata per la franchigia ±15min viene salvata per ogni evento, non solo aggregata — Admin vede anche di quanti minuti, evento per evento
- offline-first risposta dipendente:
  - meccanismo: risposta dipendente (Accetta/Modifica) stessa architettura offline-first delle timbrature: file JSON locale (shift_id, user_id, status, reason se modified, timestamp al secondo), sync al ritorno rete
  - controllo_coerenza_sync: ogni proposta porta una versione (timestamp ultima modifica lato server); la risposta del dipendente porta la versione a cui si riferisce. Se al sync non coincide più (Admin ha rifatto la proposta mentre il device era offline), la risposta è scartata e segnalata come obsoleta, mai applicata alla cieca — controllo deterministico su un solo campo

## punti_ancora_da_definire

- Email visibile nella lista Dipendenti (Blocco 3.4): emerso 2026-09-03 testando la creazione manuale. Oggi la lista mostra solo nome e cognome, letti da employees (che non ha la colonna email, sta solo in auth.users) — due dipendenti omonimi sono indistinguibili in lista. Servirebbe una edge function dedicata che esponga l'email (via admin API, secret key) insieme ai dati di employees. Non fatto ora, fuori scope della 3.4
- Riposo settimanale minimo (24h consecutive, D.Lgs. 66/2003 art.9): emerso 2026-08-30 discutendo contract_types. Il generatore turni oggi controlla solo il riposo giornaliero (11h) — manca un controllo equivalente per quello settimanale. Da decidere quando si costruisce il Blocco 10, non prima
- Admin unico del cliente: emerso 2026-09-02 testando il Blocco 3.4 su device reale, riprodotto due volte, eliminazione e declassamento. Oggi la schermata Dipendenti permette di eliminare o declassare di ruolo anche l'unico Admin di un client_id, lasciando il locale senza nessun account che possa gestirlo — richiederebbe intervento manuale di Andrea per rimediare (stesso meccanismo del bootstrap del primissimo admin, update diretto via SQL fuori dall'app). Confermato che la RLS employees_write_admin blocca anche il tentativo di auto-ripromuoversi ad admin dopo un declassamento, per design: chi scrive deve già essere admin. Da decidere se e come impedire la perdita dell'ultimo admin di un client_id (blocco su eliminazione E su declassamento), non prima di aver chiuso il Blocco 3.4

## ruolo_manager_intermedio

- descrizione: terzo ruolo oltre Admin/Dipendente: gestisce turni/griglia come Admin, ma niente export PDF né dati economici (ore supplementari confermate, ecc.)
- caso_uso: titolare assente a lungo (es. ferie di un mese), Manager gestisce i turni al suo posto
- gate_condivisione: quando Manager preme Condividi, la proposta va prima in revisione ad Admin, non subito ai dipendenti. Solo quando Admin stesso preme Condividi (proposta del Manager, identica o corretta) scatta il flusso verso i dipendenti (pending/accepted/modified). Nessuno stato/infrastruttura nuova, cambia solo chi può far scattare la condivisione
- admin_in_revisione: non usa Accetta/Modifica-con-motivazione (pensati per il dipendente che non può editare la griglia): Admin ha già i permessi di editing del Manager, corregge direttamente e condivide lui stesso, niente motivazione richiesta
- notifica_ritorno_manager: se Admin modifica la proposta, il Manager riceve notifica di riepilogo di tutti i cambiamenti sul batch intero — stesso pattern del 'ritorno a chi ha condiviso', un livello più in alto (Admin -> Manager invece di Dipendente -> Admin)
- turni_propri_manager: essendo anche lui dipendente, riceve la vista personalizzata 'Orari di lavoro' come chiunque altro
- potere_esecutivo_ore_supplementari_cambio_turno: resta solo Admin, anche se Admin è assente per un mese — il Manager vede la notifica ma non ha i tasti di conferma. Scartata deliberatamente un'idea: nessun trasferimento automatico del potere al Manager dopo un timeout (troppa complessità per un caso limite raro). Limite accettato esplicitamente: si regge sull'aspettativa che Admin controlli le notifiche anche in ferie; per urgenze reali resta il canale telefonico diretto Manager -> Admin fuori dall'app (deciso 2026-08-27, nessun banner in-app che lo ricordi)

## estensione_futura_statistiche_assenze_ingiustificate

Fuori scope attuale, non in roadmap.

Nata durante Blocco 1.2: absence_type include unauthorized (UI: 'ingiustificata', corretto 2026-08-27 — era stata rinominata 'arbitraria' il 2026-08-25 solo per liberare la lettera icona I per infortunio, ma 'ingiustificata' è il termine legale corretto, vedi legal/law.md; lo scontro lettera si risolve coi codici a 3 lettere ING/INF). Possibile sviluppo futuro: sezione statistiche che conta assenze ingiustificate per dipendente nel tempo. Aspetto prezzo se a pagamento: vedi business/marketing.md

## estensione_futura_agente_ia

Fuori scope attuale — solo segnaposto architetturale nel disegno dei ruoli, priorità resta completare l'app base.

- vincolo: permessi equivalenti al Manager, mai ad Admin (nessun potere esecutivo su ore supplementari/cambio turno, proposte sempre filtrate da Admin). Idea più avanti e meno definita: sezione statistiche condivisa Admin+agente, agente anche come consulente

Proposta implementazione (Claude Code):

- base: non ricerca web fatta, basata su capacità note di Supabase Edge Functions e API Anthropic (tool use) — da riverificare le versioni esatte se si parte davvero
- dove_vive: solo lato server, mai nel client Flutter compilato — stesso vincolo di sicurezza di base del progetto
- identita_db: utente Supabase reale con ruolo Manager, sottoposto alle stesse RLS di un Manager umano — zero policy nuove, il confinamento è già garantito dal DB
- motore: Edge Function (Deno) che chiama Claude in tool use con strumenti chiusi (no SQL arbitrario): propose_shift, read_availability, read_employee_requests, generate_shifts (riusa la generazione automatica già server-side). Ogni strumento è una RPC Postgres già vincolata da RLS
- modalità:
  - schedulata (cron via Edge Function) per proposte periodiche
  - su richiesta: campo testo libero 'Scrivi al gestore' nella dashboard dipendente, un solo scambio non una chat, coerente con la regola 'nessuna chat' del Modifica turno
- gate: ogni proposta dell'agente passa dallo stesso flusso Condividi -> revisione Admin del Manager umano — l'agente è un Manager come un altro
- log: tabella append-only ai_agent_log con ogni azione proposta, visibile ad Admin — per costruire fiducia prima di allargare permessi
- chiave_api: ogni cliente fornisce e gestisce la propria chiave Anthropic, cifrata e associata al proprio client_id — evita fatturazione a consumo lato nostro, il cliente controlla il proprio uso
- motivo_sovrapprezzo: il lavoro vero non è la chiamata API ma progettazione prompt/strumenti, test su casi limite, log di controllo

## vincoli_di_legge_sullorario_di_lavoro

- rimando: fatti di legge (riposi, massimali, CCNL Fipe-Confcommercio) in legal/law.md -> Orario di lavoro: riposi e massimali — guida per ogni decisione futura su ore/turni
- conseguenza_db: Blocco 1.6, weekly_schedule_templates: nessun numero unico per la pausa nel turno spezzato (la legge non ne fissa uno) — regola resta solo end_time_1 < start_time_2, senza minimo di durata

## permessi_retribuiti_rol_ex_festivita

- origine: ricerca 2026-08-24 da osservazione di un familiare dell'utente — tipo di assenza mancante nel disegno originale di absences
- rimando_legale: fatti di legge (fonte, monte ore per anzianità, scadenze, riproporzionamento part-time) in legal/law.md -> Permessi retribuiti (ROL + ex festività)
- decisione_schema_2026-08-25: absences registra solo il fatto grezzo (type, start_date, end_date, portion). L'app NON calcola il monte ore, non lo converte, non blocca nulla — motivo in legal/law.md -> Permessi retribuiti (ROL + ex festività). Conteggio ore/monte residuo resta dell'ufficio paghe. Niente campo hire_date (serviva solo a questo calcolo abbandonato)
- protezione_ux: banner di conferma non bloccante prima di salvare ('sei sicuro di voler segnare questo permesso per [dipendente], [data], [mezza/giornata intera]?') — come un libro paga cartaceo, l'app non sa se è corretto, fa solo riflettere un attimo

## infortunio_sul_lavoro_inail

- origine: ricerca 2026-08-25 da segnalazione utente, esperienza diretta di un familiare infortunato sul lavoro
- rimando_legale: fatti di legge (fonte, base assicurativa, trattamento economico, comporto) in legal/law.md -> Infortunio sul lavoro (INAIL)
- decisione_schema_2026-08-25: stessa logica del ROL — nuovo valore injury nell'enum absence_type, sempre giornata intera (mai portion). Nessun calcolo di percentuali di retribuzione né conteggio giorni di comporto lato app: competenza ufficio paghe, come per il ROL — inventarlo violerebbe la stessa regola CLAUDE.md. I dati restano solo riferimento documentale

## visibilita_malattia_infortunio_ruolo_manager_privacy

- origine: ricerca 2026-08-25 dal punto sospeso 'malattia cancellabile solo da Admin?' — dato sanitario, categoria particolare GDPR
- rimando_legale: legal/law.md -> Privacy: dati sanitari (malattia/infortunio)
- conseguenza: la domanda originale era troppo stretta: il Manager non deve proprio VEDERE che un'assenza è illness/injury, né in lettura né scrittura — vede solo 'assente' senza causale. Ferie/permesso/ingiustificata restano visibili come oggi
- decisione_2026-08-25: per illness/injury il Manager non inserisce né vede il tipo specifico, la classificazione resta sempre di Admin. Quando un dipendente pianificato non timbra, il sistema notifica sia Admin che Manager (stesso pattern di ore supplementari/cambio turno, Manager in sola visualizzazione) per reagire subito. Chiuso 2026-08-30: nessuna funzione/bottone nuovo da costruire, l'app non entra nel merito di come i ruoli si parlano fuori dall'app
- fatto (2026-08-25):
  - RLS absences_anomalies ristretta: Manager legge/segnala solo anomalie non sanitarie, Admin senza restrizioni
  - RLS absences: Manager inserisce solo assenze non sanitarie (malattia/infortunio solo Admin), tolta select diretta per authenticated (solo insert concesso)
  - nuova vista absences_grid, unico modo di leggere le assenze: Admin e il dipendente stesso vedono sempre il tipo vero, Manager vede 'assente' generico per malattia/infortunio altrui, tipo vero per il resto — accesso diretto alla tabella da parte del Manager non rivela più nulla (niente grant di lettura)
  - file: 20260823170400_absences_anomalies_rls_policies.sql, 20260823153959_absences_rls_policies.sql, 20260823161933_grant_authenticated_privileges.sql, 20260825091000_absences_grid_view.sql

## scelte_app_basate_su_questi_vincoli

- tetto_weekly_contracted_hours: 78 ore/settimana (13h/giorno × 6 giorni lavorabili) come check pratico anti-errore nel DB — non certifica da sola la conformità legale (che riguarda la media delle ore realmente lavorate, non il valore contrattuale)
- estensione_futura_stanchezza: fuori scope, nessun blocco roadmap — criterio in discussione: percentuale di sforamento (ore lavorate vs weekly_contracted_hours, es. contratto 30h -> settimana 40h = +33%), non soglia fissa. Più alta e crescente la percentuale, più alto lo stimato livello di stanchezza. Soglie non definite. Report solo per Admin

## pin_come_fallback_esteso

- natura: non un'anomalia da segnalare — metodo di timbratura equivalente al QR, nessun controllo/avviso speciale verso Admin
- caso_qr_non_leggibile: copre anche il dispositivo fisso che perde connessione e non riceve un QR aggiornato — per il dipendente indistinguibile da 'QR non leggibile', timbra col PIN senza logica aggiuntiva
- alternativa_scartata: QR generato localmente sul dispositivo del bar (tipo 2FA): richiederebbe un segreto nel client compilato, estraibile via reverse engineering per generare QR validi da remoto per sempre

## turni_notturni_e_ora_legale

Inizio/fine turno salvati sempre come data+ora completa (mai solo l'orario), fuso IANA Europe/Rome via librerie standard Dart/Postgres — cambio ora legale gestito automaticamente, un turno che attraversa la mezzanotte (es. 22:00-06:00) si calcola senza logica speciale.

## notifiche_cambio_turno_e_ore_supplementari

- canali_garantiti: push nativa + popup in-app, sempre attivi non disattivabili. Serve FCM (Firebase Cloud Messaging, gratuito, nativo Android). Trigger: Supabase (evento/webhook) -> Edge Function -> FCM -> telefono, logica lato server
- email: canale opzionale, toggle individuale nelle impostazioni di ogni utente (Admin/Manager/Dipendente), default ATTIVO (opt-out, non opt-in) come rete di sicurezza. Riusa l'infrastruttura email del PDF mensile, flag booleano nel profilo controllato lato server
- corretto 2026-08-27: nessuna eccezione al toggle nemmeno per il cambio turno non pianificato — canale garantito resta solo push+popup (il limite email del piano free rende l'email inadatta come canale garantito)
- whatsapp_business_api: valutato e bocciato: richiede approvazione Meta/Twilio, costo per messaggio, verifica business — sproporzionato

## nfc_valutato_e_scartato

Tag NFC passivi bocciati: statici e clonabili in pochi secondi con lettore/writer economico, vanificano la protezione anti-replay del QR dinamico. Su iPhone la lettura NFC richiede comunque l'app in primo piano con sessione attiva — nessun vantaggio UX reale sul QR.

## conservazione_dati_gdpr

- tempi: cifre esatte in legal/law.md -> GDPR: base legale del trattamento e conservazione dati. Implicazione: nessuna cancellazione automatica delle timbrature prima di quella soglia
- meccanismo di non-cancellazione (Blocco 1.3):
  - deciso: 2026-08-23, per due rischi concreti: cancellazione per errore, e perdita di valore probatorio in ispezione/causa (un dato cancellabile in ogni momento non vale come prova, anche se in pratica nessuno lo tocca)
  - scartato: soft-delete classico (deleted_at) — pensato per un annulla reversibile, fragile con RLS (ogni query deve ricordarsi di filtrare)
  - adottato: su timeclock_events, absences, shifts: le tre tabelle diventano immutabili (trigger DB blocca fisicamente UPDATE/DELETE, non solo RLS che protegge solo l'accesso via API). Correzioni tramite tabella gemella (timeclock_anomalies, absences_anomalies, shifts_anomalies) con id, FK verso la riga originale, reported_by, note obbligatoria, created_at indipendente — anche le gemelle immutabili. Tabella gemella per tabella (non generica condivisa) per mantenere la FK reale
  - chiuso 2026-08-25: il Manager non vede né tocca mai un'assenza illness/injury, quindi non si pone il caso di una correzione da parte sua — resta sempre Admin

