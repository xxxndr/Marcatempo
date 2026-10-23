# study

- delega: la regola esiste già altrove (notes, legge, decisione già presa)
- studio: la sto decidendo io ora (sicurezza, soglie, casi limite)
- ambito: solo attività `fatto:false`, indifferente frontend/backend
- convenzione: id senza punto = blocco intero

## Delega a Claude

- **5** — apre un picker esistente, nessuna regola nuova
- **6.1** — setup plugin da documentazione ufficiale
- **6.3** — mostra un dato che arriva già pronto da 6.2
- **6.4** — regola già fissata: default attivo, opt-out
- **7.1** — i tre valori sono già nominati nel testo del blocco
- **7.2** — bottone che chiama una funzione già scritta in 7.1
- **7.3** — lista che mostra righe già esistenti
- **7.4** — campo obbligatorio, nessuna regola nuova
- **7.5** — riusa l'infrastruttura notifiche del blocco 6
- **9.1** — permessi Manager (turni sì, PDF/dati economici no) già decisi in product/app.md -> ruolo_manager_intermedio, qui solo implementazione
- **9.2** — gate di revisione Manager->Admin già deciso in product/app.md -> ruolo_manager_intermedio (gate_condivisione)
- **9.3** — riusa la stessa griglia di 4.2
- **9.4** — riusa il pattern notifica già costruito in 7.5
- **11.2** — mostra un QR già generato da 11.1
- **12.1** — wrapper sul plugin di scansione, la logica è in 12.2
- **12.4** — messaggio dopo che 12.2/12.3 hanno già lavorato
- **15.1** — cosa conta come ore oltre il turno già deciso in product/app.md -> ore_supplementari_e_cambio_turno (franchigia simmetrica ±15min, oltre = intera differenza)
- **15.3** — due bottoni su un dato già classificato da 15.1/15.4
- **15.5** — stesso canale notifica già esistente, sola lettura
- **16** — conta righe già presenti da 7 e 14, nessuna regola nuova
- **18.2** — form email con autocomplete
- **18.3** — stesso PDF di 18.1, solo un altro trigger di invio
- **18.4** — stesso trigger GDPR già usato in 1.3, su un'altra tabella
- **20.2** — checklist e comando di build

## Studio

- **4.1t** — test su device del primo Notifier Riverpod del progetto (shifts_notifier), verifica reale del pattern studiato in 4.1
- **4.2** — prima gesture dell'app (Draggable/GestureDetector per trascinare/allungare il blocco turno), studiata da Andrea; se rallenta troppo, delega a Claude in corsa
- **6.2** — come collegare webhook, edge function e FCM: da progettare, nessun pattern webhook/trigger costruito finora nel progetto
- **7.6** — test scenari completi del ciclo Condividi/Accetta/Modifica: non testo statico, richiede giudizio su cosa è uno stato corretto; occasione per un primo test automatico vero (flutter test/pgTAP, vedi test/tests.md) invece di sola verifica manuale
- **9.5** — test di interazione tra ruoli
- **13** — deve dare lo stesso risultato del QR senza falsi allarmi: da capire bene
- **14** — quando un ritardo è un ritardo: soglie da definire, verificare prima se riusare la franchigia ±15min già decisa per 15.1 o se serve una soglia distinta
- **15.2** — come si riconosce un cambio turno: il confronto base è deciso (product/app.md -> ore_supplementari_e_cambio_turno), restano da decidere i casi limite (nessuno pianificato, turni sovrapposti)
- **17** — aggregazione ore che alimenta l'export paghe
- **19** — GitHub Actions/secrets: rischio basso, buon terreno per imparare devops
- **20.1** — confronto soglie codice vs legal/law.md: audit di coerenza, serve attenzione non un comando meccanico

## Non delegare mai

Anche a stack consolidato, controllo pieno sempre — qui il rischio è dati persi/frode/legale, non risparmio di studio.

- **8** — conflitto tra risposta offline e proposta rifatta: si perdono dati del dipendente se sbagliato
- **10** — algoritmo con vincoli legali (riposo minimo, ore contrattuali)
- **11.1** — anti-replay del QR: è la sicurezza anti-frode della timbratura
- **12.2** — scrittura offline della timbratura: prova di presenza
- **12.3** — sync della timbratura: stesso rischio di 12.2
- **15.4** — classificazione legale supplementare/straordinario, vedi CLAUDE.md: mai inventare dati di diritto del lavoro
- **18.1** — cifre del PDF paghe: il blocco stesso lo segna alta criticità

## Fuori asse

- **20.3** — beta reale sul campo: presenza fisica, non è studio di codice

Fonti: Riverpod flutterstudio.dev/blog/bloc-vs-riverpod.html · gesture Flutter docs.flutter.dev/ui/interactivity/gestures · pgTAP pgtap.org · Zod zod.dev · offline-first hasura.io/blog/design-guide-to-offline-first-apps · RLS multitenancy crunchydata.com/blog/row-level-security-for-tenants-in-postgres · anti-replay QR oloid.com/blog/qr-code-authentication · FCM firebase.google.com/docs/cloud-messaging · PDF server-side dev.to/christianca/what-tools-do-you-use-for-server-side-pdf-generation-31mb · CI/CD roadmap.sh/backend/developer-skills · competenze dev IT 2026 (git/testing/CI-CD/devops già coperti da Blocco 19 e 7.6) glassdoor.com/Job/bologna-developer-jobs-SRCH_IL.0,7_IC2815484_KO8,17.htm
