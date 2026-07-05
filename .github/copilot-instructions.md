# Copilot Instructions — Shim / طبقة تعليمات Copilot

> **Canonical conventions live in [`../AGENTS.md`](../AGENTS.md).**
> Read that file first for project overview, architecture, design tokens, state management, API integration, security, naming, mandatory documentation, and skills. This file contains **only Copilot-specific runtime guidance**.
>
> ‏الاصطلاحات الأساسية في [`../AGENTS.md`](../AGENTS.md) — اقرأه أولًا. هذا الملفّ يحوي فقط إرشادات خاصة بـ Copilot.

## Project scope / نطاق المشروع

- Modify files **only** inside this repo (`osta_app`).

## Copilot-specific behavior / سلوك خاص بـ Copilot

### Inline completion

- **Never invent** a `Color(0xFF…)`, raw `EdgeInsets.all(N)`, `BorderRadius.circular(N)`, hardcoded route string, or hardcoded API path. Reach for `context.appColors` / `Theme.of(context).colorScheme`, `AppSpacing`, `AppRadii`, `Theme.of(context).textTheme`, a page's `static const path`, and (once created) `ApiEndpoints` constants.
- **Never** suggest user-facing string literals. Suggest `context.l10n.<key>` and assume the key exists in both `app_en.arb` and `app_ar.arb`.
- **Never** suggest `SharedPreferences` for tokens — always `TokenStorage` (`flutter_secure_storage`).
- Respect the three-layer split (`data/` → `domain/` ← `presentation/`). Don't complete a Flutter import inside a `domain/` file; don't complete `fromJson`/`toJson` inside `domain/entities/`.
- **Errors**: complete `try`/`catch` around a repository/use-case call and a sealed `Failure`. **Never** suggest `Either`, `Result<T>`, or `.fold()` — fpdart is not used.
- **Models**: complete a plain `class X extends Equatable` with hand-written `fromJson`/`toJson`/`props`. **Never** suggest `@freezed`, `@JsonSerializable`, or `part '*.g.dart';` — there is no codegen.

### Copilot Chat conventions

- For "explain"/"fix": prefer reading the relevant ADR in `osta_readme_files/decisions/` or the matching guide in `osta_readme_files/guides/` first — they capture rationale training data lacks.
- For "write a test": use `flutter_test` + `http_mock_adapter` / hand-written fakes (`test/core/network/fakes.dart`). No `mockito`, no `build_runner`.
- For "add an endpoint"/"add a feature": defer to the project-tuned skills in `.agents/skills/` (`add-api`, `add-feature`, `add-language`).

### Comment-trigger generation

When generating from a TODO / `//` comment:

- A new BLoC uses the event/state pattern from the canonical doc § State Management.
- A new repository method **throws** a `Failure` (caught by the bloc via `try`/`catch`) — it does not return `Either`.
- A new DI dependency adds a hand-written `getIt.registerLazySingleton(...)` line in `core/di/injection.dart`.
- A new screen adds a route in `core/router/app_router.dart` (path as a page `static const`).

### Shell

- macOS / zsh. Suggest Unix syntax; quote paths under `/Volumes/...`.

### Git commits

- Never suggest `Co-authored-by:` trailers or tool attribution (`Made-with:`) for any AI agent.

## Where to look / أين تبحث

| Need | Location |
|------|----------|
| Project conventions, tokens, BLoC, API flow | [`../AGENTS.md`](../AGENTS.md) |
| Deferred tooling & phased plan | [`../docs/ROADMAP.md`](../docs/ROADMAP.md) |
| Skills | [`../.agents/skills/`](../.agents/skills/) |
| Onboarding & doc-map | [`../osta_readme_files/INDEX.md`](../osta_readme_files/INDEX.md) |
| Common pitfalls | [`../osta_readme_files/reference/COMMON_PITFALLS.md`](../osta_readme_files/reference/COMMON_PITFALLS.md) |
| Troubleshooting | [`../osta_readme_files/reference/TROUBLESHOOTING.md`](../osta_readme_files/reference/TROUBLESHOOTING.md) |
