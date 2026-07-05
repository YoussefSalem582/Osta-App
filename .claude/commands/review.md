# Review Diff Against OSTA Conventions

Audit the current uncommitted diff (`git diff` + staged + new files) against the OSTA conventions in `AGENTS.md`. Report findings as a checklist — one line each, `[ ]` for a violation, `[x]` for a clause that passes. Group by area, cite `file:line`. If the diff is empty, say so and stop.

Reference `osta_readme_files/reference/COMMON_PITFALLS.md` — most findings map to a pitfall there; link the relevant one.

## Steps

1. Run `git diff HEAD` (and `git status` for untracked files) to get the full changeset. Read every changed `.dart` / `.arb` file.
2. Walk each check below against the added/changed lines only.
3. Emit the checklist. End with a one-line verdict: `PASS` (no violations) or `N violation(s) — fix before commit`.

## Checks

- [ ] **Design tokens** — no raw colors (`Color(0x…)`, `Colors.*`) or raw spacing/radius doubles in widgets. Use `context.appColors`, `AppSpacing` (xs4 sm8 md16 lg24 xl32), `AppRadii` (sm8 md12 lg16 pill999), `AppElevation`. Text via `Theme.of(context).textTheme.*` — there is no `AppTextStyles`.
- [ ] **l10n** — no hardcoded user-facing strings. Every string is `context.l10n.<key>`, added to BOTH `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`, and `flutter gen-l10n` re-run. Never edit generated `lib/core/l10n/`.
- [ ] **Tokens storage** — access/refresh tokens go through `TokenStorage` (flutter_secure_storage). No `SharedPreferences` for tokens.
- [ ] **ApiClient** — every HTTP call goes through `ApiClient`. No raw `Dio`/`dio.get`/`dio.post` in features. Errors surface as typed `ApiException` from the network layer.
- [ ] **Errors** — repositories/blocs throw & catch a `sealed Failure` (`NetworkFailure`/`ServerFailure`/`UnknownFailure`) with plain `try`/`catch`. NO `Either`, NO `Result<T>`, NO `.fold()`, NO `fpdart`.
- [ ] **Plain Dart / no codegen** — no `freezed`, `@freezed`, `json_serializable`, `@JsonSerializable`, `injectable`, `build_runner`, or `part '*.g.dart'`/`part '*.freezed.dart'`. Models are `class X extends Equatable` with hand-written `fromJson`/`toJson`/`props`. (Any codegen belongs to a `docs/ROADMAP.md` phase only.)
- [ ] **Manual DI** — a new service/repo/bloc adds a hand-written line in `configureDependencies()` (`lib/core/di/injection.dart`): `registerLazySingleton` for singletons, `registerFactory` for BLoCs. No annotations, no `injection.config.dart`.
- [ ] **Routing** — new routes are a `static const path` on the page widget, wired in `lib/core/router/app_router.dart`. No `RouteNames` class, no `lib/config/` dir.
- [ ] **Config** — one `BASE_URL` via `AppConfig` (`--dart-define`). No `AppFlavor`, no `FLAVOR`, no flavors.
- [ ] **RTL-safe** — directional layout uses `EdgeInsetsDirectional` and `start`/`end`, not `left`/`right`. Arabic is the default locale.
- [ ] **Shared UI reused** — reuse `lib/shared/ui/` (`AppButton`, `AppTopBar`, `AppBottomNavBar`, `AppCard`, `AppTextField`, `AppBottomSheet`, `EmptyState`/`ErrorState`/`LoadingState`) instead of re-rolling. Numbers/currency via `EgpFormatter`/`NumberFormatter`.
- [ ] **Docs updated** — a meaningful change updates `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, and `osta_readme_files/CURRENT_STATUS.md`.
- [ ] **Scope** — for a stubbed feature, the change matches its GitHub epic + `osta_readme_files/features/` doc; no invented scope.

## Notes

- Findings only — do not edit files. Suggest the fix inline where it fits on the line.
- If unsure whether a value is a token violation, flag it — a false positive is cheap, a raw hex in a PR is not.
