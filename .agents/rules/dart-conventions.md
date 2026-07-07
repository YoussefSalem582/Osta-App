---
description: "Naming, plain-Dart (no codegen), formatting, lints"
globs: "lib/**/*.dart"
alwaysApply: false
---

# Dart Conventions

Plain, readable Dart for a team new to Flutter. Advanced tooling (codegen,
`fpdart`) is **deferred, not rejected** — see [`docs/ROADMAP.md`](../../docs/ROADMAP.md).
Canonical conventions: [`AGENTS.md`](../../AGENTS.md).

## Naming

| Thing | Convention | Example |
|---|---|---|
| Files & dirs | `snake_case` | `auth_token_model.dart`, `api_client.dart` |
| Classes / enums / typedefs | `PascalCase` | `AuthTokenModel`, `ApiClient` |
| Shared UI widgets | `App`-prefixed `PascalCase` | `AppButton`, `AppTopBar`, `AppCard` |
| Variables / methods / params | `camelCase` | `accessToken`, `configureDependencies` |
| Private members | leading `_` | `_dio`, `_parseEnvelope` |
| Constants | `camelCase` (lowerCamel) | `baseUrl`, `path` |
| Route paths | `static const path` on the page widget | `SplashPage.path` |

## Plain-Dart rules (no codegen)

l10n is the **only** generated code (`flutter gen-l10n` → `lib/core/l10n/`, never
hand-edited). Everything else is hand-written.

- **Models** — `class X extends Equatable` with hand-written `factory fromJson`,
  `toJson`, and `props`. See `lib/features/auth/data/models/auth_token_model.dart`.
  - No `freezed`, `json_serializable`, `@JsonSerializable`, `@freezed`, or
    `part '*.g.dart'` / `part '*.freezed.dart'`.
- **DI** — manual `get_it`, registered by hand in `configureDependencies()`
  (`lib/core/di/injection.dart`, global `getIt`). A new dependency is one line:
  `getIt.registerLazySingleton<Foo>(() => Foo(getIt()))`; BLoCs use
  `registerFactory`.
  - No `injectable`, `injection.config.dart`, or `build_runner`.
- **Errors** — sealed `Failure` (`lib/core/error/failure.dart`:
  `NetworkFailure` / `ServerFailure` / `UnknownFailure`) **thrown** and caught
  with plain `try`/`catch`. The network layer throws typed `ApiException`s;
  repositories catch and convert to a `Failure`.
  - No `fpdart`, `Either`, `Result<T>`, or `.fold()`.

## Formatting & lints

- Lints: [`very_good_analysis`](../../analysis_options.yaml) (strict), applied
  app-wide. `lib/core/l10n/**` is excluded; `public_member_api_docs` is off.
- Run `dart format .` before every commit.
- CI gate (single "format · analyze · test" job) runs:
  `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`.
  A format diff or analyzer warning fails the build.
