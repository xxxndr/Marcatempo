# architecture

## Decisioni prese (2026-09-17)

- State management + DI: Riverpod (i provider Riverpod fanno anche da DI, nessuna libreria DI separata)
- Organizzazione cartelle: feature-first, non layer-first
- Pattern per feature: MVVM-lite — screen (widget) + notifier Riverpod (stato) + repository (accesso Supabase); niente Clean Architecture a 3 layer (data/domain/presentation), troppa cerimonia per la taglia di questa app
- Le pagine esistenti (oggi flat in lib/) vengono migrate nella nuova struttura di cartelle prima di iniziare il blocco 4 — fatto. Adozione del pattern repository/notifier per feature: stato in dev/refactor.md -> R6

## Esempio di struttura (tree)

lib/
├── core/
│   ├── theme_controller.dart
│   └── app_form_scaffold.dart
├── features/
│   ├── employees/
│   │   ├── employees_page.dart
│   │   ├── employees_notifier.dart
│   │   └── employees_repository.dart
│   └── shifts/
│       ├── shifts_grid_page.dart
│       ├── shift_block.dart
│       ├── shifts_notifier.dart
│       ├── shift_time_utils.dart
│       └── shifts_repository.dart
└── main.dart
