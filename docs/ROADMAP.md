# Architecture Roadmap — deferred "advanced" tooling

The Osta codebase was intentionally simplified so a team **new to Flutter** can
be productive in plain, readable Dart. Several advanced tools and patterns were
**deferred, not rejected** — this document records what was removed, *why*, and a
phased plan to reintroduce each piece once the team is comfortable.

Guiding rule: **reintroduce one phase at a time**, land it green in CI, and give
the team time to absorb it before starting the next.

## What we kept

These stay because they're standard and worth learning early:

- **State management** — `bloc` / `flutter_bloc` (e.g. `ThemeModeController` Cubit).
- **Routing** — `go_router` (declarative routes in `lib/core/router/app_router.dart`).
- **DI container** — `get_it`, but with **manual** registration in
  `lib/core/di/injection.dart` (no annotations/codegen).
- **Networking** — `dio` + `dio_smart_retry` + interceptors, secure token storage.
- **Localization** — `flutter_localizations` + `intl` (`gen-l10n`), Arabic + English.
- **Strict lints** — `very_good_analysis`.

## What we deferred

| Area | Removed | Replaced with (today) |
| --- | --- | --- |
| Model codegen | `freezed`, `json_serializable`, `build_runner` | plain `Equatable` classes, hand-written `fromJson`/`toJson` |
| DI codegen | `injectable`, `injectable_generator` | manual `get_it` registration |
| Functional errors | `fpdart` (`Either`/`Result<T>`) | `sealed class Failure` + plain `try`/`catch` |
| Build flavors | `AppFlavor` enum, `FLAVOR` dart-define | single `BASE_URL` in `AppConfig` |
| CI matrix | Android APK + iOS build jobs | one analyze + test job |
| Dev tooling | `/gallery` component gallery route/page | (removed) |

## Phased reintroduction plan

### Phase 1 — JSON model codegen (`json_serializable`)
- **When:** the team is comfortable reading/writing models and JSON mapping grows tedious/error-prone.
- **Add deps:** `json_annotation`, dev: `json_serializable`, `build_runner`.
- **Restore:** re-add `.gitignore` / `analysis_options.yaml` excludes for `*.g.dart`;
  annotate models with `@JsonSerializable()` + `part '*.g.dart'`; add a
  `dart run build_runner build` step back to CI and the README quick-start.
- **Files:** `lib/features/**/data/models/*.dart`, `lib/core/network/pagination_meta.dart`.

### Phase 2 — Immutable models with `freezed`
- **When:** the team wants copyWith/unions/exhaustive pattern-matching and is fluent with `part` files + codegen from Phase 1.
- **Add deps:** `freezed_annotation`, dev: `freezed`. Restore `*.freezed.dart` excludes.
- **Convert** the `Equatable` models to `@freezed` classes.

### Phase 3 — DI codegen with `injectable`
- **When:** manual registration in `injection.dart` becomes long/repetitive.
- **Add deps:** `injectable`, dev: `injectable_generator`. Restore `*.config.dart` excludes.
- **Restore:** `@InjectableInit()` in `injection.dart` + `getIt.init()`; annotate
  services (`@lazySingleton`, `@module`, `@preResolve`, `@disposeMethod`).
  `buildAppDio()` becomes a `@module` provider again.

### Phase 4 — Build flavors + platform CI
- **When:** staging/prod environments and store builds are needed.
- **Restore:** an `AppFlavor` enum + `FLAVOR` dart-define in `AppConfig`; the
  dev/staging/prod BASE_URL matrix in the README; the `build-android` (APK) and
  `build-ios` (`--no-codesign`) jobs in `.github/workflows/ci.yml`.

### Phase 5 — Functional error handling (`fpdart`)
- **When:** the team prefers explicit `Result` returns over thrown exceptions.
- **Add dep:** `fpdart`. Reintroduce `typedef Result<T> = Either<Failure, T>` in
  `lib/core/error/failure.dart` and thread it through repositories/use-cases.
- **Note:** the lowest-priority phase — plain `try`/`catch` + `sealed Failure`
  is perfectly serviceable; adopt only if the team wants the functional style.

## How to reintroduce a phase (checklist)

1. Add the packages to `pubspec.yaml`, `flutter pub get`.
2. Restore any `.gitignore` / `analysis_options.yaml` excludes for generated files.
3. Apply the annotations/patterns to the target files.
4. If codegen: add the `build_runner`/generation step back to CI and the README.
5. Run `flutter analyze` + `flutter test`; land it green before the next phase.
