# law

Diritto del lavoro italiano — note di riferimento. Solo fatti di legge, niente decisioni di prodotto (quelle restano in product/app.md, che rimanda qui).

## contratto_di_riferimento

- **corretto:** CCNL Fipe-Confcommercio (Pubblici Esercizi), rinnovato 5 giugno 2024, fonte primaria fipe.it
- **conferma_indipendente (2026-09-14):** Decreto direttoriale n. 63 del 10/07/2025, che attua l'art. 41 c.13 D.Lgs. 36/2023 (Codice Appalti), designa il CCNL Fipe-Confcommercio (codice CNEL H05Y) come "contratto di riferimento" per il settore Alloggio e Ristorazione ai fini del costo del lavoro — 804.596 lavoratori, 107.172 imprese applicanti. Fonte: CNEL, tabella "Individuazione del CCNL negli appalti pubblici" (cnel.it). Confermato anche da INPS tra i 10 CCNL più applicati (fonte: inps.it, allegato ddl 310/658)
- **da_non_usare:** contratto del 7 giugno 2023 (UAI/FAILM) — 'pirata' secondo Fipe, non il riferimento del settore
- **altro_contratto_pirata_individuato (2026-09-14):** durante la verifica trovato anche un CCNL "Turismo e Pubblici Esercizi" del 28/5/2014 firmato da Sistema Commercio e Impresa / FESICA CONFSAL — numerazione articoli completamente diversa da quella Fipe, scartato, mai usato in questo progetto

## orario_di_lavoro_riposi_e_massimali

**Problema:** quali riposi/massimali orari si applicano per validare turni e generatore automatico.

Legge:
- D.Lgs. 66/2003 art. 7 — riposo giornaliero minimo 11 ore consecutive ogni 24 ore
- D.Lgs. 66/2003 art. 9 — riposo settimanale minimo 24 ore consecutive ogni 7 giorni, da sommare al riposo giornaliero, di norma la domenica
- D.Lgs. 66/2003 art. 4 — orario settimanale medio massimo 48 ore comprensive di straordinario, come media su periodo di riferimento fissato dalla legge (di norma 4 mesi, estendibile da CCNL per ragioni tecnico/organizzative)
- CCNL Fipe-Confcommercio art. 111 c.1 — orario ordinario 40 ore settimanali
- CCNL Fipe-Confcommercio art. 117 c.4 — il tetto 48h settimanali compare nei programmi di distribuzione multiperiodale/flessibilità, superabile fino a un massimo di 20 settimane l'anno
- CCNL Fipe-Confcommercio art. 117 c.6 — il ciclo di compensazione per la flessibilità dura 12 mesi
- CCNL Fipe-Confcommercio art. 117 c.3 — preavviso per un nuovo programma di flessibilità/distribuzione multiperiodale: almeno 2 settimane
- CCNL Fipe-Confcommercio art. 115 c.1 — pausa minima nel turno spezzato: nessun minimo fissato a livello nazionale, delegato esplicitamente alla contrattazione territoriale integrativa — varia da zona a zona
- art. 1375 Codice Civile + D.Lgs. 81/2015 (clausole elastiche) — il datore può modificare unilateralmente la collocazione oraria per i full-time purché in buona fede; per i part-time serve consenso esplicito preventivo. Nessun meccanismo generale di silenzio-assenso previsto dal diritto italiano per i turni

**Soluzione:** nessuna distinzione di ruolo (cucina/sala) in nessuna fonte. Part-time: nessun taglio orario fisso di legge, va da 16-18h/settimana fino a sotto le 40h, liberamente negoziato (ricerca 2026-08-22, CCNL Pubblici Esercizi/Altalex).

Pending:
- deroga al riposo giornaliero (D.Lgs. 112/2008 conv. L. 133/2008) tramite CCNL o contrattazione territoriale/aziendale, con riposo compensativo equivalente — solo fonti secondarie, nessun testo primario del D.Lgs. 112/2008 consultato direttamente. Nessuna deroga di questo tipo risulta nel testo primario CCNL Fipe. Riverificare se mai rilevante per un cliente reale
- scartato: categoria 'lavoratori discontinui' collegata alle 48h — informazione errata trovata in una fonte secondaria

## clausole_elastiche_e_flessibili_nel_part_time

**Problema:** l'app deve gestire la revoca/gestione delle clausole elastiche nel part-time?

Legge:
- D.Lgs. 81/2015 art. 6 — base normativa delle clausole elastiche/flessibili
- CCNL Fipe-Confcommercio art. 82 c.3 — l'accordo del lavoratore alle clausole elastiche deve risultare da atto scritto; accordo verbale o tacito è nullo (verificato su testo ufficiale fipe.it, Titolo V)
- CCNL Fipe-Confcommercio art. 82 c.4 — preavviso minimo per esercitarla: 2 giorni (verificato su testo ufficiale fipe.it, Titolo V)
- CCNL Fipe-Confcommercio art. 82 c.5 — clausola flessibile = varia la collocazione oraria della prestazione; clausola elastica = aumenta la durata del lavoro, entro il limite massimo del 30% della prestazione annua concordata — solo per part-time, non esistono per il full-time (verificato su testo ufficiale fipe.it, Titolo V)
- non verificato su testo primario, probabile fonte secondaria (vedi Fonti sotto): forma scritta con motivi tecnici/organizzativi/produttivi/sostitutivi, nessun numero minimo di giorni fissato per pattuire una nuova clausola
- D.Lgs. 81/2015 (revoca del consenso) — revoca possibile solo per 4 motivi tassativi, nessun altro aggiungibile da contrattazione collettiva: (1) patologia oncologica propria/coniuge/figli/genitori, (2) convivenza con figli conviventi sotto 13 anni, (3) convivenza con familiare con disabilità grave (L.104), (4) essere studente

**Soluzione:** preavviso 2gg già rispecchiato in product/app.md -> proposta_e_accettazione_turni (banner Blocco 7.6). Collegamento prodotto: product/app.md -> disponibilita_dichiarata_dal_dipendente_calendario — deciso di non costruire una funzione strutturata per la revoca, resta gestione manuale di Admin fuori dall'app.

Pending:
- se la revoca tolga la clausola in modo permanente o solo per la durata della condizione che l'ha giustificata — non chiarito dalle fonti trovate. Verificare con consulente del lavoro se mai rilevante per un cliente reale, non inventare la risposta
- scartato: '5 giorni' di preavviso trovato in una fonte secondaria, non risulta nel testo primario art. 82 c.4 (che dice 2 giorni)

Fonti:
- https://www.commercialistatelematico.com/articoli/2026/04/clausole-elastiche-part-time.html
- https://avvocatoamati.it/part-time-e-clausole-elastiche-quando-il-lavoratore-puo-revocare-il-consenso/
- https://www.soluzionilavoro.it/2024/03/27/revoca-del-consenso-alle-clausole-elastiche-del-part-time/
- https://www.commercialistatelematico.com/articoli/2024/07/clausole-elastiche-per-part-time-come-gestirle-correttamente.html

## supplementare_vs_straordinario

**Problema:** come classificare le ore oltre il turno pianificato (serve per il popup Admin).

Legge:
- D.Lgs. 81/2015 artt. 4-12 (riscrive D.Lgs. 66/2003) — il supplementare esiste solo per chi ha ore contrattuali sotto le 40 settimanali (part-time): ore lavorate oltre il proprio contratto ma entro le 40h. Lo straordinario riguarda chiunque, part-time o full-time, per le ore oltre le 40h settimanali

**Soluzione:** un full-time (40h contrattuali) non ha mai supplementare, tutto ciò che sfora è già straordinario. Collegamento prodotto: product/app.md -> ore_supplementari_e_cambio_turno — classificazione automatica via weekly_contracted_hours.

Pending: nessuno.

## arrotondamento_e_tolleranza_sulla_timbratura

**Problema:** che soglia di tolleranza usare sull'orario di timbratura senza rischi legali.

Legge:
- Codice Civile, D.Lgs. 66/2003, CCNL Fipe-Confcommercio artt. 111-117 — nessuna fonte primaria trovata che fissi una soglia di arrotondamento/tolleranza in timbratura — cercato esplicitamente su fipe.it (rinnovato 5 giugno 2024), nessuna clausola in merito. È un'area lasciata alla prassi/regolamento aziendale, non alla legge

**Soluzione:** principio dalle fonti pratiche/HR consultate, coerente con art. 36 Costituzione (retribuzione proporzionata al lavoro prestato): un arrotondamento è ammissibile solo se non penalizza il lavoratore. Arrotondamento asimmetrico (non accreditare l'anticipo come supplementare ma scalare più del ritardo reale) sposta lavoro non pagato sul dipendente — rischio concreto (differenze retributive, ispezione INL). Arrotondamento simmetrico (stessa soglia sia su anticipo che ritardo) è il pattern comune nelle fonti pratiche (es. tolleranza 10min + arrotondamento 15min uguale nei due sensi), lecito perché non favorisce sistematicamente una parte. Nessun numero preciso (es. 15 minuti) imposto o vietato da nessuna fonte — è prassi, non legge. Decisione presa 2026-08-29 dal titolare senza consulenza legale professionale: soglia simmetrica ±15 minuti (product/app.md -> ore_supplementari_e_cambio_turno), basata su convergenza di più fonti indipendenti sul principio di simmetria, non su un numero di legge.

Pending:
- se emergono fonti primarie o giurisprudenza specifica in senso contrario alla soglia ±15min, va rivista

Fonti:
- https://www.businessonline.it/lavoro-diritti/timbratura-badge-in-ritardo-tolleranza-per-5-10-minuti-in-ritardo-o-piu_n65156.html
- https://www.bizneo.com/blog/it/arrotondamento-ore-lavoro/
- https://www.fabigvb.it/faq/-ce-tolleranza-sullorario-di-entrata

## permessi_retribuiti_rol_ex_festivita

**Problema:** che tipo di assenza è il ROL/ex festività e come lo tratta lo schema dati.

Legge:
- CCNL Fipe-Confcommercio art. 114 c.7 — unità di fruizione: mezza giornata o giornata intera, non a ore libere
- CCNL Fipe-Confcommercio art. 114 c.1 — monte ore di assenza retribuita, distinto da ferie (maturano comunque, anche durante malattia) e da malattia (richiede certificato medico). Il dipendente viene pagato, mantiene anzianità di servizio e contribuzione pensionistica figurativa
- CCNL Fipe-Confcommercio art. 114 c.4 (assunti dopo 1° gennaio 2018) — monte ore cresce con l'anzianità: anni 1-2 = 32 ore/anno, anno 3 = 68 ore/anno, anno 4 in poi (regime pieno) = 104 ore/anno. Chi era già assunto prima del 2018: 104 ore/anno da subito, senza gradini. Non varia in base al numero di dipendenti dell'azienda
- CCNL Fipe-Confcommercio art. 114 c.12 — scadenza di utilizzo: ore godute entro il 30 giugno dell'anno successivo a quando maturano; non godute entro settembre dell'anno successivo vengono monetizzate in busta paga. Part-time: monte ore riproporzionato in base al rapporto ore contrattuali settimanali / 40 ore full-time

**Soluzione:** nessuna formula di conversione giorno -> ore specificata dal CCNL (verificato due volte su fonte primaria fipe.it il 2026-08-25) — per questo l'app registra solo il fatto grezzo, non calcola monte ore (product/app.md -> permessi_retribuiti_rol_ex_festivita). Prima di vendere a un cliente reale: far rivedere da un consulente del lavoro la categorizzazione delle assenze, nessun controllo automatico sostituisce quella revisione.

Pending:
- scartato: 56-72 ore trovato in una prima ricerca poco accurata — apparteneva per errore al CCNL Commercio (contratto diverso), non applicabile qui

## infortunio_sul_lavoro_inail

**Problema:** come si distingue l'infortunio dalla malattia e cosa comporta economicamente.

Legge:
- CCNL Fipe-Confcommercio art. 191 c.1, D.P.R. 30 giugno 1965 n. 1124 — l'infortunio è coperto da INAIL (a differenza della malattia comune, coperta da INPS — artt. 187-190). Obbligo di notifica immediata da parte del lavoratore (art. 191 c.2) e di assicurazione INAIL del personale soggetto
- CCNL Fipe-Confcommercio art. 191 c.3-5 — trattamento economico (solo documentale, non calcolato dall'app): intera retribuzione il giorno dell'infortunio + 60% per i 3 giorni successivi (periodo di carenza), poi integrazione a carico del datore fino al 100% dal giorno dell'infortunio, quando INAIL corrisponde la propria indennità
- CCNL Fipe-Confcommercio artt. 194-196 — conservazione del posto (comporto) condivisa con la malattia: 180 giorni per anno solare (1 gennaio-31 dicembre), periodi multipli cumulabili

**Soluzione:** product/app.md -> infortunio_sul_lavoro_inail — l'app registra solo il fatto grezzo, nessun calcolo di percentuali o comporto lato app.

Pending: nessuno.

## terminologia_delle_assenze

**Problema:** qual è il termine legale corretto per un'assenza senza preavviso.

Legge:
- CCNL Fipe-Confcommercio art. 213 c.5 — il termine legale corretto è 'assenza ingiustificata', non 'arbitraria'

**Soluzione:** rinominata per errore in 'arbitraria' il 2026-08-25, corretta il 2026-08-27.

Pending: nessuno.

## privacy_dati_sanitari_malattia_infortunio

**Problema:** il Manager può vedere che un'assenza è malattia/infortunio?

Legge:
- Garante Privacy, Provvedimento n. 146 del 5 giugno 2019, punto 1.5.d — quando per ragioni organizzative si mettono a disposizione di soggetti diversi dall'interessato dati su presenze/assenze, il datore non deve esplicitare, nemmeno con sigle, la causale se rivela una categoria particolare di dato (es. malattia) — si può comunicare solo 'assente', non il motivo
- Garante Privacy, Provvedimento n. 146/2019, punto 1.5.c — l'accesso a documenti con categorie particolari di dati va limitato a uffici/strutture organizzative competenti e personale autorizzato

**Soluzione:** product/app.md -> visibilita_malattia_infortunio_ruolo_manager_privacy — Manager vede solo 'assente' per malattia/infortunio altrui.

Pending: nessuno.

## gdpr_base_legale_trattamento_e_conservazione_dati

**Problema:** su che base legale si trattano i dati dei dipendenti e per quanto tempo si conservano.

Legge:
- principio generale GDPR (rapporto di lavoro) — base legale: esecuzione del contratto di lavoro, mai il consenso — squilibrio di potere tra datore e dipendente rende il consenso giuridicamente debole come base
- Statuto dei Lavoratori (L. 300/1970) art. 4 — disciplina i controlli a distanza sui lavoratori
- Garante Privacy, provvedimento n. 350 dell'8 settembre 2016 (Libro Unico del Lavoro) — conservazione timbrature: almeno 5 anni
- normativa generale conservazione dati economici — buste paga e ore supplementari confermate: 10 anni dalla fine del rapporto di lavoro

**Soluzione:** valutato 2026-08-27 nel disegno del self-signup: art. 4 Statuto Lavoratori non impatta il disegno via codice locale. Collegamento prodotto: product/app.md -> conservazione_dati_gdpr per il meccanismo di non-cancellazione costruito su questi vincoli.

Pending: nessuno.

## controlli_a_distanza_gps_e_biometria_facciale

**Problema:** GPS/geolocalizzazione e riconoscimento facciale sono legali come rinforzo anti-frode alla timbratura (buddy punching)?

Legge:
- Statuto dei Lavoratori (L. 300/1970) art. 4 c.1 — impianti audiovisivi e altri strumenti da cui derivi anche la possibilità di controllo a distanza dell'attività dei lavoratori (inclusa geolocalizzazione) installabili solo previo accordo con RSU/RSA, o in mancanza previa autorizzazione della sede territoriale dell'Ispettorato Nazionale del Lavoro (INL)
- Statuto dei Lavoratori art. 4 c.2 — eccezione: non serve accordo/autorizzazione per strumenti di registrazione degli accessi e delle presenze (badge, orologio marcatempo) né per strumenti dati in dotazione al lavoratore per rendere la prestazione, se personalizzati (PC, telefono aziendale ecc.)
- Statuto dei Lavoratori art. 4 c.3 — anche per gli strumenti esenti dal c.2, i dati raccolti sono utilizzabili solo per finalità connesse al rapporto di lavoro e solo se il lavoratore è adeguatamente informato delle modalità d'uso e dei controlli — informativa obbligatoria in ogni caso
- Garante Privacy, provvedimenti 22 febbraio 2024 n. 9995680 e 27 marzo 2025 n. 10138981 — riconoscimento facciale per il controllo presenze dichiarato illecito in più occasioni: nessuna norma primaria autorizza il trattamento di dati biometrici a questo scopo, e il consenso del lavoratore non è base giuridica valida per lo squilibrio di potere del rapporto di lavoro. Sanzionate almeno 5 aziende nel 2024, una con 120.000€ di multa
- Garante Privacy, Verifica preliminare 8 settembre 2016 n. 5497522 — localizzazione tramite smartphone (via GPS O rete WiFi) per finalità di rilevazione presenze: stessa disciplina per entrambe le tecnologie. Conta lo scopo (sapere dove si trova il lavoratore), non lo strumento tecnico usato per scoprirlo — quindi anche un segnale WiFi o un indirizzo IP usato con lo stesso scopo ricade nella stessa categoria del GPS
- giurisprudenza sui 'controlli difensivi' (eccezione di origine giurisprudenziale, poi recepita nell'art. 4 c.1 dal 2015) — un controllo è ammesso senza accordo/autorizzazione SOLO se: (1) esiste già un sospetto concreto e fondato su una persona precisa, (2) il controllo è mirato a quella persona, non generalizzato su tutti, (3) è fatto dopo che il sospetto è nato (ex post), non in modo preventivo/continuativo, (4) non è invasivo. Non copre la costruzione ex novo di uno strumento che localizza tutti i dipendenti, anche se poi lo si consulta solo ogni tanto — la soglia della legge (c.1) è 'anche la possibilità' di controllo, non la frequenza con cui lo si usa in pratica
- Cassazione, ordinanza n. 28248 del 4 novembre 2024 (giurisprudenza costante sul punto) — farsi timbrare il cartellino/badge da un collega per simulare la propria presenza è condotta fraudolenta che giustifica il licenziamento per giusta causa, per lesione irrimediabile del vincolo fiduciario col datore di lavoro

**Soluzione:** QR dinamico + PIN restano nell'esenzione del c.2 (strumento di registrazione presenze), nessun accordo sindacale richiesto — ma serve comunque un'informativa chiara ai dipendenti (c.3), da verificare che esista/sia adeguata prima di un cliente reale. Qualunque segnale che riveli anche indirettamente, in modo impreciso o solo dopo molto tempo dove si trova il dipendente (GPS, WiFi rilevato, IP abbinato a un indirizzo noto del locale, ecc.) ricade comunque nel c.1: la legge blocca 'anche la possibilità' di controllo, non conta se il controllo è preciso, immediato o usato spesso. L'eccezione dei 'controlli difensivi' non è una scorciatoia per aggirare questo: si applica a dati già raccolti per un altro scopo legittimo e poi riesaminati dopo un sospetto concreto su una persona precisa — non autorizza a costruire apposta un rilevatore di posizione e usarlo raramente su tutti. Riconoscimento facciale escluso comunque, indipendentemente dall'art. 4, per il divieto specifico del Garante Privacy. Conclusione pratica: per il buddy punching (timbratura fatta da un collega al posto del titolare) non esiste una contromisura tecnica legale per una piccola impresa senza RSU/RSA — restano solo l'accettazione del rischio residuo (comune a qualunque sistema a badge, anche dei concorrenti) e il deterrente legale (licenziamento per giusta causa, giurisprudenza costante). Collegamento prodotto: product/app.md -> autenticazione_e_sicurezza_della_timbratura (no_gps) — la scelta già presa aveva motivazione UX, ora ha anche fondamento legale.

Pending:
- verificare che l'informativa ai dipendenti sulle modalità di timbratura (richiesta dal c.3) esista davvero e sia adeguata, prima di un cliente reale — non verificato in questa sessione

Fonti:
- https://www.agendadigitale.eu/sicurezza/privacy/tracciamento-gps-sul-lavoro-come-rispettare-statuto-dei-lavoratori-e-gdpr/
- https://quifinanza.it/lavoro/diritto-del-lavoro/riconoscimento-facciale-azienda-garante-maxi-sanzione/833398/
- https://www.federprivacy.org/informazione/garante-privacy/no-del-garante-privacy-al-riconoscimento-facciale-per-controllo-presenze-dei-lavoratori
- https://www.garanteprivacy.it/home/docweb/-/docweb-display/docweb/9995680
- https://www.garanteprivacy.it/home/docweb/-/docweb-display/docweb/10138981
- https://www.garanteprivacy.it/home/docweb/-/docweb-display/docweb/5497522
- https://www.mysolution.it/lavoro/approfondimenti/commenti/2024/12/legittimo-il-licenziamento-del-dipendente-che-fa-timbrare-il-suo-cartellino-al-collega/
