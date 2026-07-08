# /add-feature

Scaffold a Clean Architecture feature (all three layers + manual DI + route + l10n) following osta conventions. This command is an alias of the project skill **add-feature** — the authoritative steps live in [`.agents/skills/add-feature/SKILL.md`](../../.agents/skills/add-feature/SKILL.md) and the canonical guide [`osta_readme_files/guides/03_how_to_add_new_feature.md`](../../osta_readme_files/guides/03_how_to_add_new_feature.md). Read both before scaffolding.

The osta stack is deliberately plain Dart: errors are a sealed `Failure` **thrown** and caught with `try`/`catch` (NO `Either`/`Result<T>`/`.fold()`); models are `Equatable` + hand-written `fromJson`/`toJson` (NO freezed/json_serializable/`part '*.g.dart'`); DI is hand-registered `getIt` lines (NO injectable/build_runner). There is NO offline layer. Deferred tooling lives in [`docs/ROADMAP.md`](../../docs/ROADMAP.md).

## Before you scaffold

Read the matching GitHub epic + its feature doc in [`osta_readme_files/features/`](../../osta_readme_files/features/README.md) — most features are stubs specified by open epics; do not invent scope. Branch `feat/<issue>-<slug>` off `develop`. Use `<name>` for the snake_case folder, `<Name>` for the PascalCase type prefix.

## The 13 steps

1. **Folder tree** — `lib/features/<name>/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}`.
2. **Domain entity** — `domain/entities/<name>.dart`: plain `class <Name> extends Equatable`; no Flutter imports, no `fromJson`; `final` fields, override `props`.
3. **Repository contract** — `domain/repositories/<name>_repository.dart`: `abstract class <Name>Repository`; methods return the entity directly and **throw** a `Failure` (`lib/core/error/failure.dart`) on error. No `Either`, no `Result<T>`.
4. **Use cases** — `domain/usecases/<verb>_<name>.dart`: one class per action; constructor takes the repo, `call()` delegates.
5. **Data model** — `data/models/<name>_model.dart`: `extends Equatable` with hand-written `fromJson` (snake_case → camelCase by hand), `toJson`, `toEntity()`, `props`. No codegen annotations, no `part '*.g.dart'`. Live example: `lib/features/auth/data/models/auth_token_model.dart`.
6. **Remote datasource** — `data/datasources/<name>_remote_datasource.dart`: call `ApiClient` (`get/post/put/delete<T>(path, parse:, query:/body:)` → `ApiResult<T>`); never touch `Dio`. Add each path as a `static const` in `lib/core/network/api_endpoints.dart` (create the file if absent). See [`04_how_to_add_new_api.md`](../../osta_readme_files/guides/04_how_to_add_new_api.md).
7. **Repository impl** — `data/repositories/<name>_repository_impl.dart`: wrap datasource calls in `try`/`catch`, convert the typed `ApiException` to a `Failure` via `e.toFailure()`, map models to entities.
8. **Bloc events** — `presentation/bloc/<name>_event.dart`: `sealed`/base `<Name>Event extends Equatable`; one event per user action (e.g. `<Name>LoadRequested`).
9. **Bloc states** — `presentation/bloc/<name>_state.dart`: `<Name>Initial`/`<Name>Loading`/`<Name>Loaded(data)`/`<Name>Error(Failure)`, all `Equatable`.
10. **Bloc** — `presentation/bloc/<name>_bloc.dart`: `extends Bloc<<Name>Event, <Name>State>`; each handler emits `Loading`, calls the use case in `try`/`catch`, emits `Loaded` on success and `Error(f)` `on Failure catch (f)`. No `.fold()`.
11. **Pages & widgets** — `presentation/pages/`, `presentation/widgets/`: reuse `lib/shared/ui/` (`AppButton`, `AppCard`, `AppTextField`, `AppTopBar`, `EmptyState`/`ErrorState`/`LoadingState`, …). Design tokens only: `AppSpacing`/`AppRadii`, `context.appColors`, `Theme.of(context).textTheme.*` — no raw colors/spacing, no `AppTextStyles`. RTL-safe (`EdgeInsetsDirectional`/`start`/`end`). Page exposes `static const path`.
12. **Manual DI** — in `configureDependencies()` (`lib/core/di/injection.dart`): `registerLazySingleton` for datasource, repository, and each use case; `registerFactory` for the bloc. No annotations, no `injection.config.dart`.
13. **Route + l10n** — add the route in `lib/core/router/app_router.dart` using the page's `static const path`. Add every user-facing string to **both** `lib/l10n/app_en.arb` (template) and `lib/l10n/app_ar.arb`, then run `flutter gen-l10n`; access via `context.l10n.<key>`. Never edit generated l10n in `lib/core/l10n/`.

## Finish

- Run `dart format .`, `flutter analyze` (clean), `flutter test` (green). No `build_runner`.
- Update docs: `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, `osta_readme_files/CURRENT_STATUS.md` (and the feature doc).
- Branch `feat/<issue>-<slug>` (hand-written kebab-case — never a tool-generated name like `claude/...`; rename with `git branch -m` first), PR base `develop` (`main` is release-only, reached via a `develop → main` release PR + tag), bilingual (AR+EN) description, conventional commits, no AI co-author trailer.
