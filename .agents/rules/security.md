---
description: "Tokens, secrets, dart-define, logging redaction"
globs: "lib/**/*.dart"
alwaysApply: false
---

# Security Rules

Trust boundaries are the network layer (`lib/core/network/`), token storage
(`lib/core/auth/token_storage.dart`), and runtime config
(`lib/core/config/app_config.dart`). Everything below is enforceable at review
time. Canonical conventions: [`../../AGENTS.md`](../../AGENTS.md).

## Secrets & runtime config

- **No hardcoded URLs, tokens, or keys** anywhere in `lib/**`. Base URL comes
  from `--dart-define=BASE_URL` read once by `AppConfig`
  (`String.fromEnvironment('BASE_URL', …)`).
- **No `.env`, no flavors, no `FLAVOR`** — a single `BASE_URL` dart-define is
  the only runtime input. Multi-flavor is deferred ([`../../docs/ROADMAP.md`](../../docs/ROADMAP.md) Phase 4).
- Read config **only** through `getIt<AppConfig>()`, never
  `String.fromEnvironment` scattered in feature code.

| Config | Source | Never |
|--------|--------|-------|
| Base URL | `--dart-define=BASE_URL` → `AppConfig.baseUrl` | literal in code, `.env` |
| Build variant | none (single build) | `AppFlavor`, `FLAVOR` |

## Auth tokens

- Store the Sanctum token pair **only** in `TokenStorage`
  (`flutter_secure_storage`), keys `access_token` / `refresh_token`.
- **Never** put tokens in `SharedPreferences` (that is for non-secret prefs
  like `theme_mode` only).
- Never read/write secure-storage keys directly — go through `TokenStorage`
  (`readAccessToken` / `readRefreshToken` / `writeTokens` / `clear`).
- Token lifecycle is owned by the network layer:
  - `AuthInterceptor` attaches the bearer token and does **401
    refresh-retry-once** (queued).
  - On refresh failure it fires `AuthEvents.onSessionExpired` — the app
    reacts (logout/route to auth); do not swallow it.

## Logging redaction

- The shared logger is `PrettyDioLogger`, added once in `buildAppDio`
  (`lib/core/network/dio_client.dart`).
- **Auth headers and request/response bodies must never be logged.** Rely on
  the redacted config: header logging is off (defaults) and
  `responseBody: false`. Do **not** flip on `requestHeader`,
  `requestBody`, `responseHeader`, or `responseBody`.
- Do not add ad-hoc `print`/`debugPrint` of tokens, `Authorization` headers,
  or full payloads in interceptors or repositories.

## Payments

- Payments use **Paymob hosted checkout in a WebView** — the app never
  collects, stores, or transmits raw card data. No PAN/CVV fields in Flutter.

## Generated & upcoming secrets

- Generated l10n (`lib/core/l10n/`) is **git-ignored** — regenerate with
  `flutter gen-l10n`, never commit or hand-edit it.
- Upcoming secrets (Google Maps API key, Firebase config) are **platform-native**
  (`android/`, `ios/` config files) — they are **not** Dart `--dart-define`s
  and do not belong in `lib/**`.
