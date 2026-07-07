---
description: "What to edit, what is off-limits, and the approved commands"
globs: "lib/**/*.dart"
alwaysApply: false
---

# Project Scope & Approved Commands

Canonical conventions live in [`../../AGENTS.md`](../../AGENTS.md) — read it first. This rule covers only scope boundaries and the command allowlist.

## Scope

- Edit only inside the `osta_app` repo. Do not touch files outside it.
- Read before edit — always.
- One task at a time; finish it before starting the next.
- After a meaningful change, update `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, and `osta_readme_files/CURRENT_STATUS.md`.

## Approved commands (no permission needed)

| Command | Purpose |
|---|---|
| `flutter pub get` | Resolve dependencies |
| `flutter gen-l10n` | Regenerate `lib/core/l10n/` from ARB files |
| `flutter analyze` | Static analysis (`very_good_analysis`) |
| `flutter test` | Run the test suite |
| `dart format .` | Format |

**No `build_runner`.** l10n is the only generated code; there is no `freezed`/`json_serializable`/`injectable` codegen step — do not add or run one.

Run the app: `flutter run --dart-define=BASE_URL=https://api.osta.dev/api/v1` (single `BASE_URL`, no `--flavor`).

## Needs explicit permission — ask first

- **`git push`** and any remote git op (PR create, force-push).
- **Dependency changes** — adding/removing/bumping anything in `pubspec.yaml`.
- **`flutter build`** (apk/appbundle/ios/etc.).
- Interactive git (`git rebase -i`, `git add -i`) is unavailable — pre-fill all args.
- No AI attribution / co-author trailers in commits.

## Plain-Dart, no-codegen stance

The stack is deliberately plain Dart so a team new to Flutter stays productive:

- Errors: `sealed class Failure` thrown + plain `try`/`catch`. No `fpdart`, `Either`, `Result<T>`, `.fold()`.
- Models: `class X extends Equatable` with hand-written `fromJson`/`toJson`/`props`. No `@freezed`, no `@JsonSerializable`, no `part '*.g.dart'`.
- DI: manual `get_it` in `lib/core/di/injection.dart` — one hand-written `registerLazySingleton` line per dep. No `injectable`, no `injection.config.dart`.

Advanced tooling is **deferred, not rejected** — see the phased plan in [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md). Do not reintroduce codegen without following a ROADMAP phase.
