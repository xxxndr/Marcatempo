# marketing

Marketing e strategia di vendita. Unico file pricing/commerciale, decisioni tecniche in product/app.md.

## origine_revisione_2026-08-22

Stima iniziale a pagamento unico (cifra alta per ~200+ ore) non regge il mercato reale — segnale: Nicolò Terzi (fratello di Thomas Terzi, il barista per cui era nata l'idea poi accantonata perché risolta con hardware economico) riferisce un amico barista che paga poco più di 1000€ per un'app desktop timbratura+turni. Conclusione: pagamento unico enorme early-stage non realistico per bar/ristorante singolo: meglio abbonamento.

## concorrenti_italia_2026-08-22

- NoBadge: da 4,20€/utente/mese, abbonamento per dipendente, verticale ristorazione/bar, no setup/hardware — nobadge.it/settori-ristorazione
- Skello: da 5€/dipendente/mese, verticale HoReCa, conformità CCNL Pubblici Esercizi, ROI dichiarato 4-6 mesi — skello.io/it/blog/gestione-turni-ristorante-il-software-per-hotel-bar-e-ristoranti
- Fluida (Zucchetti): da 1€/dipendente/mese (base, 1 modulo), sale con moduli, generalista HR non verticale — fluida.io/blog/migliori-software-hr-ristorazione
- Dipendenti in Cloud: ~0,40€/dipendente/mese + quota fissa (es. 150 dip. ≈87,50€/mese), pensato per medio-grandi, poco adatto a 5-10 dipendenti — dipendentincloud.it/costo
- TimbraApp: attivazione 149€ poi pay-as-you-go, non verticale — timbraapp.it

**Nota target:** per 5-10 dipendenti questi prezzi per-dipendente portano comunque a 25-50€/mese totali — per questo scartato lo schema 'a testa'. Il dato di Nicolò (>1000€ una tantum) è probabile anomalia locale.

## decisioni_pricing

- **modello:** abbonamento fisso per locale, non per dipendente (2026-08-22) — lo schema per-dipendente maschera un costo reale comunque di 25-50€/mese; per un titolare singolo (non HR manager) un prezzo fisso è più onesto e semplice
- **fasce (2026-08-25):** Anna/Botanica Lab (cliente fondatrice, ex datrice di lavoro dell'utente): 25€/mese, trattamento di riguardo, tolta dicitura 'a vita'. Clienti successivi: 30€/mese. Stesse condizioni per entrambe: mensile libero o annuale -15% vincolo 12 mesi
- **motivo differenza 5€:** piano free Supabase copre un solo cliente oltre la demo; con più clienti serve Pro Plan ($25/mese ≈23€, costo fisso condiviso non per cliente — nocode.mba/articles/supabase-pricing). Anna+un altro = 55€/mese > 23€ di costo: margine già con pochi clienti, oltre il secondo è quasi tutto margine
- **attivazione:** nessuna, inclusa nella mensilità
- **sconto annuale:** 15% (prassi SaaS italiana 2026-08-25, range mercato 15-40%), vincolo 12 mesi con penale su disdetta anticipata (metà mensilità rimanenti o differenza scontato/pieno) — stesso schema di NoBadge, unico concorrente che lo dichiara esplicitamente. Mensile: disdetta libera, nessuna penale. Anna: 255€/anno invece di 300€; altri: 306€/anno invece di 360€
- **demo:** 1 settimana gratuita, 10-20 dipendenti — validata contro i limiti Supabase free, vedi product/app.md -> capacita_piano_gratuito_prova_10_20_dipendenti
- **posizionamento:** target primario bar/ristoranti 10-20 dipendenti; esteso a qualunque attività a turni (es. negozi), ambizione non garantita fino a ~50 dipendenti (piccola non media impresa); enterprise 100+ resta a Zucchetti/Fluida
- **ripagare sviluppo:** ~267.8 ore (notes/roadmap.md) non recuperate da un cliente solo come nel vecchio canone unico — ammortizzate su più locali nel tempo, normale per un SaaS

## punti_ancora_da_definire

Chiusi (2026-08-25):
- durata abbonamento: mensile libero o annuale -15% vincolo 12 mesi
- acquisto una tantum come alternativa: nessun concorrente diretto lo offre (Zucchetti unica eccezione, enterprise) — abbandonato

Aperti:
- partita IVA: abbonamento = pagamento regolare, non più occasionale; utente oggi senza P.IVA lavora a prestazione occasionale. Da verificare regime (forfettario probabile) e soglia che fa scattare l'obbligo — non ancora ricercato
- leve di prezzo alternative oltre sconto annuale (es. differenziazione per funzionalità incluse) — solo idea, nessuna decisione

**Metodo:** ricerca fonti ufficiali incrociate prima di decidere, stesso metodo di product/app.md per i temi legali.

## app_cassa_scartata_2026-08-30

Idea: app separata registrazione cassa (stesso stack/target), modulo aggiuntivo. Scartata: (1) sondaggio informale — chi ha hardware di cassa usa quasi sempre il software della stessa azienda venditrice, poco spazio per software indipendente; (2) un'app di cassa deve trasmettere corrispettivi giornalieri all'Agenzia delle Entrate, il developer non certifica da solo — via realistica: integrazione API con fornitore accreditato (es. A-Cube), via alternativa (certificazione 'registratore telematico software', specifiche v11.2 aprile 2026) nuova/pesante/nessuno certificato con successo ad oggi.
