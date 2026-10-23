# environment

Tooling della macchina locale, dati stabili. I problemi risolti e le decisioni di tooling stanno in dev/decisions.md.

## Macchina

- **OS**: Fedora Linux 44 Workstation, kernel 7.1.8-200.fc44.x86_64
- **Editor**: VS Code
- **Flutter**: 3.47.0 stable, in `~/flutter`, in PATH
- **Android Studio**: Quail 3 | 2026.1.3 Patch 1, in `~/android-studio`
- **Android SDK**: `~/Android/Sdk`
- **KVM**: attivo (`emulator -accel-check`)

## Device di test

Samsung Galaxy A55 SM-A556B, Android 16 API 36 One UI 8.5, kernel 6.1.157-android14-11. Debug USB autorizzato in modo permanente.

## Comandi Flutter

- `adb devices` — elenca i device collegati, sempre prima di lanciare l'app (preferito a `flutter devices`, lista troppo lunga)
- `flutter run -d <id del device>` — mai `flutter run` secco: il device va scelto esplicitamente sull'id restituito dal comando sopra

## Comandi Supabase

- `supabase start` — avvia lo stack locale
- `supabase db reset` — ricrea il DB da zero, unico modo per applicare modifiche a migration esistenti
- `supabase migration up` — applica solo le migration nuove, non tocca seed.sql
- `supabase functions deploy <nome> --use-api` — sempre con `--use-api`: il bundling locale non è supportato con Podman
