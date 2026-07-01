# OSTA · أُسطى

Single Flutter app (Android + iOS) hosting **every role flow** — customer &
business now, mechanic/tow later — in **one** app target. No monorepo, no Melos.
Feature-first `lib/`, strict shared lints, and a CI pipeline that gates every PR.

## Getting started

```bash
git clone https://github.com/YoussefSalem582/Osta-App.git
cd Osta-App                        # working dir: osta_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # freezed / injectable / json
flutter run --dart-define=BASE_URL=https://api.osta.dev/api/v1 --dart-define=FLAVOR=dev
```

The app boots into a splash screen, then the first-run **role selection**.
Generated code (`*.g.dart`, `*.freezed.dart`, `*.config.dart`, `lib/core/l10n/`)
is git-ignored — run `build_runner` after a fresh clone. Localizations
(`flutter gen-l10n`) are generated automatically on `flutter run`/`build`.

## Flavors / environment

Configuration is compile-time via `--dart-define` (no secrets in the repo):

| Var        | dev (default)                     | staging                                 | prod                              |
| ---------- | --------------------------------- | --------------------------------------- | --------------------------------- |
| `BASE_URL` | `https://api.osta.dev/api/v1`     | `https://api.staging.osta.dev/api/v1`   | `https://api.osta.sa/api/v1`      |
| `FLAVOR`   | `dev`                             | `staging`                               | `prod`                            |

```bash
flutter run --dart-define=BASE_URL=<url> --dart-define=FLAVOR=<dev|staging|prod>
```

## Project structure

```
lib/
  main.dart            # boot: DI init → runApp(OstaApp)
  app.dart             # MaterialApp.router + theme + l10n
  core/                # cross-cutting foundation
    config/            # AppConfig, AppFlavor (--dart-define)
    network/           # Dio client (retry + redacted logger)
    auth/              # secure token storage
    router/            # go_router (splash → role)
    theme/             # Material 3 light/dark
    l10n/              # generated AppLocalizations (en, ar — RTL)
    error/             # Failure + fpdart Result<T>
    di/                # get_it + injectable
  features/            # one folder per area, each split data/ domain/ presentation/
    splash/  role/  auth/  customer/  business/  shop/  notifications/
  shared/              # reusable widgets + extensions
```

## Quality gates

`flutter analyze` runs under **very_good_analysis** (strict, shared app-wide via
root `analysis_options.yaml`). CI (`.github/workflows/ci.yml`) runs on every PR:

1. `dart format` (tracked files) → `flutter analyze` → `flutter test`
2. build APK (Android)
3. build iOS (`--no-codesign`)

A red stage fails the PR.

## Branch & PR conventions

- Branch off `main`: `feat/<issue>-<slug>` (e.g. `feat/28-app-scaffolding-ci`).
- PR **base is `main`**; keep CI green.
- PR description in **Arabic + English**; reference the issue (`Closes #<n>`).
