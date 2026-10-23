# refactor

Debito tecnico da rientrare. Formato roadmap.md: `n [OK]/[] ore testo`. Test in notes/test/tests.md.

- R1 [OK] 1.5h Indici assenti su tutto lo schema: servono su client_id e su employee_id di ogni tabella figlia. Fatto 2026-09-13 (migration fk_indexes, 17 indici su tutte le FK, verificato su pg_indexes)
- R2 [OK] 1h Policy RLS: `(select current_employee_role())` invece della chiamata nuda — calcolo una volta per query invece che per riga. Vale anche per absences_grid. Fatto 2026-09-12 (migration rls_initplan_wrap, wrappate anche current_employee_client_id e auth.uid), verificato con EXPLAIN: InitPlan su employees e absences_grid
- R3 [] 0h Deciso: Drift (SQLite tipizzato) al posto dei file JSON — dato e coda di sync in una sola transazione, query come stream
- R4 [] 0h Riscrivere ROADMAP 8.1/8.2/12.2/12.3 su Drift, ore rialzate (generazione codice da studiare)
- R5 [OK] 2h Scheletro form duplicato in 5 pagine -> widget condiviso (= ROADMAP 3.11). Fatto 2026-09-17 (lib/core/app_form_scaffold.dart)
- R6 [OK] 0h Deciso 2026-09-17 (notes/dev/architecture.md): Riverpod, feature-first, MVVM-lite. Primo caso reale fatto (employees_repository come Provider). Notifier/ViewModel per schermata ancora da fare quando lo stato attraversa più widget (griglia del Blocco 4)
- R7 [] 1.5h Input edge function validati a mano -> schema Zod + safeParse su tutte e quattro
- R8 [] 0.2h set-employee-active sul cloud ha ancora i commenti rimossi in locale: ridistribuire con --use-api
- R9 [OK] 0h share_plus (Blocco 3.8) applicava il vecchio Kotlin Gradle Plugin (KGP). Fatto 2026-09-19: aggiornato a share_plus 13.3.0 (supporto Built-in Kotlin), nessun breaking change nell'API pubblica, build pulita e pulsante condividi testato funzionante
- R10 [] 0h Cache in-memory dei mesi già letti nel Notifier turni (Blocco 4), per evitare di rifare la query tornando su un mese già visto — da valutare se serve davvero una volta in uso reale, non requisito del checkpoint 4.1

Fonti: indici/RLS supabase.com/docs/guides/troubleshooting/rls-performance-and-best-practices-Z5Jjwv · Drift flutterstudio.dev/blog/offline-first-flutter-drift.html · Zod gosign.de/en/magazine/supabase-edge-functions-secure · stato dev.to/ishaquehassan
