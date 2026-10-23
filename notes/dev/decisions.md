# decisions

Problemi risolti, decisioni e test su tooling/infrastruttura — non prodotto (product/app.md), non ambiente stabile (dev/environment.md).

## cambio_tooling_android_sdk (2026-08-19)

- problema: sdkmanager nuovo non stampa il messaggio che Flutter cerca per validare le licenze
- fix: `echo "All SDK package licenses accepted."` aggiunto in `~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager`
- rischio: reinstall/update SDK può cancellare il fix

## nuova_api_edge_functions_supabase (2026-08-25)

`withSupabase` (npm:@supabase/server) sostituisce `Deno.serve`+service_role_key. `auth:'user'` da ctx.supabase (RLS)+ctx.user. `auth:'secret'` da ctx.supabaseAdmin (no RLS, server-to-server). Admin+azione elevata: check ruolo via ctx.supabase, poi client admin separato con SUPABASE_SECRET_KEYS (non il SERVICE_ROLE_KEY legacy).

## edge_function_locali_impossibili (2026-08-28)

- problema: Podman rootless non legge i file locali (permessi UID), edge function in locale impossibili, bug mai risolto upstream (supabase/cli#4190, #3099)
- decisione: DB Supabase cloud di test usato anche per edge function, svuotato prima del lancio vero

## graphify_gemini (2026-08-27)

- fatto: graphify extract richiede GEMINI_API_KEY gratuita (aistudio.google.com/apikey), non l'abbonamento Claude Pro
- fix: pacchetto openai mancante, risolto con `pipx inject graphifyy openai`. Modello default spesso in quota, risolto con `--model gemini-3.5-flash-lite`

## estrazione_semantica_backend_2026-09 (2026-09-02)

- esito: gemini-3.5-flash-lite scartato (collassa ogni file a 1 nodo, anche con istruzione esplicita anti-collasso). Groq scartato (TPM 8000 troppo basso, richieste reali 19-23k). gemini-3-flash-preview con `--token-budget 1500-3000` (forza slicing dei file grandi) funziona: 60-100% della granularità dell'estrazione manuale Claude. Quota RPD per-progetto non per-account, reset giornaliero a mezzanotte Pacifico (ai.google.dev/gemini-api/docs/rate-limits)
- decisione finale: Gemini abbandonato del tutto, stesso giorno: oltre alla quota RPD (20/giorno) esiste un limite RPM (5 richieste/minuto sul modello grande) che fa fallire i chunk anche a quota giornaliera intatta — troppo fragile per uso pratico. Estrazione semantica ora sempre manuale via Claude (sotto-istanze Agent), a consumo di token, su richiesta esplicita — non più automatizzata
- aggiornamento (2026-09-14): trovato un backend esterno che funziona bene, supera la decisione precedente — Cerebras, modello `gpt-oss-120b` via endpoint OpenAI-compatibile (`OPENAI_BASE_URL=https://api.cerebras.ai/v1`). A differenza di gemini-3.5-flash-lite non collassa i file in un unico cluster (verificato su un'estrazione reale di notes/, community distinte). Pipeline completa via CLI, senza consumare token Claude: `graphify extract [input] --backend openai --token-budget 4000 --max-concurrency 1 --out /tmp/[output]`, poi `graphify cluster-only /tmp/[output] --backend openai --model gpt-oss-120b` (fa anche l'etichettatura dei cluster, non solo l'estrazione) — poi correzione source_file, backup, `graphify merge-graphs` nel grafo principale, verifica con `graphify query`, pulizia. Limite noto: la API key Cerebras attuale ha scadenza breve. Aperto: trovare in futuro un provider gratuito con modello non piccolo per uso continuativo

## cifratura_database_supabase (2026-08-30)

Postgres Supabase: AES-256 a riposo sempre attivo, TLS in transito, backup cifrati (supabase.com/security).

## timezone_database_postgres_utc (2026-09-11)

- verificato: `ALTER DATABASE postgres SET timezone TO 'Europe/Rome';` viene accettato senza errore ma non ha effetto reale sulle connessioni successive — comportamento noto, segnalato anche su GitHub supabase/supabase#176
- Supabase tiene UTC di default e lo raccomanda esplicitamente anche per utenti in altri fusi (docs.supabase.com/guides/database/managing-timezones) — best practice standard Postgres: storage sempre UTC, conversione lato applicazione
- decisione: nessun tentativo di cambiare il fuso a livello di database. Conversione a Europe/Rome resta solo lato Flutter (vedi product/app.md -> turni_notturni_e_ora_legale)

## errore_user_banned_non_popolato (2026-09-12)

- problema: su alcune versioni di Supabase Auth il login di un utente bannato non restituisce il codice `user_banned` documentato, ma `AuthException(message: "Invalid login credentials", errorCode: null)` — impossibile distinguerlo da una password sbagliata (github.com/supabase/auth/issues/1745)
- verificato in produzione il 2026-09-12: qui il messaggio arriva come "user is banned", quindi il caso è riconoscibile
- fix in login_page.dart: controllo su `e.code == 'user_banned'` con il testo del messaggio come fallback, così funziona in entrambi gli scenari

## backup_automatici_del_database

- piano free Supabase non include backup automatici
- GitHub Actions gratuito, schedulato ogni notte a fine giornata lavorativa, dump via CLI Supabase
- ogni esecuzione salva un nuovo file con data nel nome (es. backup_2026-08-18.sql), mai sovrascrive il precedente
- rotazione: mantenuti solo gli ultimi 5 file, il più vecchio eliminato ad ogni nuova esecuzione
- il backup è rete di sicurezza per disastri, non l'unico modo di consultare lo storico: il DB live contiene tutti i dati storici, la rotazione a 5 non riduce la storia consultabile in app

## continuita_operativa_supabase_free_tier

Il piano free mette in pausa un progetto dopo 7gg senza richieste al DB, serve riattivazione manuale. Il backup notturno (query ogni notte) tiene automaticamente attivo il progetto, senza bisogno di altro.

Riattivazione: dashboard Supabase -> "Resume project", disponibile fino al 16 ottobre 2027 (confermato in-app il 2026-09-11 sul progetto marcatempo). Dopo quella data il progetto pausato non è più riattivabile, ma i dati restano scaricabili (backup + storage objects). Nessuna perdita di dati durante la pausa.

## capacita_piano_gratuito_prova_10_20_dipendenti

- metodo: numeri verificati su supabase.com/pricing il 2026-08-19, non a sensazione
- storage: 500MB inclusi — dati di 10-20 dipendenti/turni/timbrature per una settimana pesano pochi MB
- connessioni: fino a 200 concorrenti — con timbrature a orari sparsi, le connessioni realmente simultanee restano a una cifra
- autenticazione_mau: 50.000 utenti attivi/mese inclusi — 10-20 dipendenti sono una frazione trascurabile
- edge_functions: 500.000 invocazioni/mese incluse (risorsa separata dalla RAM del DB). Ipotesi più pesante (QR ogni minuto, 16h/giorno, 30gg) ≈ 28.800 invocazioni/mese solo per la rotazione QR — sommato alle timbrature reali resta ordini di grandezza sotto il limite
- conclusione: nessun limite del piano Free (RAM, storage, connessioni, utenti, edge function) viene avvicinato da una prova 10-20 dipendenti/una settimana. Se l'app cresce su molti locali, l'upgrade compute è un cambio da dashboard (pochi minuti downtime), non una modifica di codice
