---
name: add-feature
description: Scaffold a Clean Architecture feature (domain, data, presentation) with manual DI, routing, and translations. Use when creating a new feature module.
---

# Add a Feature

Scaffold a three-layer Clean Architecture module (`domain` / `data` / `presentation`) in **plain, readable Dart** — no code generation. Wire it up with manual `get_it` DI, a `go_router` route, and bilingual ARB strings. Canonical guide: [`03_how_to_add_new_feature.md`](../../../osta_readme_files/guides/03_how_to_add_new_feature.md).

The osta stack is deliberately plain: errors are a sealed `Failure` **thrown** and caught with `try`/`catch` (NO `Either`/`Result<T>`/`.fold()`); models are `Equatable` + hand-written `fromJson`/`toJson` (NO freezed/json_serializable/`part '*.g.dart'`); DI is hand-registered `getIt` lines (NO injectable/build_runner). There is NO offline layer. Deferred tooling lives in [`docs/ROADMAP.md`](../../../docs/ROADMAP.md).

## When to Use

- Filling in a stub feature folder (`lib/features/customer|business|shop|notifications|auth/*`) or creating a new one.
- The user asks to build a screen/flow backed by an API following osta conventions.
- **First** read the matching GitHub epic + its feature doc in [`osta_readme_files/features/`](../../../osta_readme_files/features/README.md) — most features are stubs specified by open epics; do not invent scope. Branch `feat/<issue>-<slug>` off `main`.

## Instructions

Use `<name>` for the feature (snake_case folder), `<Name>` for the PascalCase type prefix.

1. **Folder tree.** Create:
   ```
   lib/features/<name>/
     data/{datasources,models,repositories}/
     domain/{entities,repositories,usecases}/
     presentation/{bloc,pages,widgets}/
   ```

2. **Domain entity** — `domain/entities/<name>.dart`. Plain `class <Name> extends Equatable`; NO Flutter imports, NO `fromJson` (entities are pure). Fields `final`, override `props`.

3. **Repository contract** — `domain/repositories/<name>_repository.dart`. `abstract class <Name>Repository` whose methods **return the entity directly and throw a `Failure` on error** (`lib/core/error/failure.dart`: `NetworkFailure`/`ServerFailure`/`UnknownFailure`). NO `Either`, NO `Result<T>`.

4. **Use cases** — `domain/usecases/<verb>_<name>.dart`. One class per action; constructor takes the repo, `call()` delegates:
   ```dart
   class Get<Name>s {
     Get<Name>s(this._repo);
     final <Name>Repository _repo;
     Future<List<<Name>>> call() => _repo.get<Name>s();
   }
   ```

5. **Data model** — `data/models/<name>_model.dart`. `class <Name>Model extends Equatable` with hand-written `factory fromJson` (map snake_case JSON keys to camelCase by hand), `toJson`, `toEntity()`, and `props`. NO `@JsonSerializable`, NO `part '*.g.dart'`. Live example: `lib/features/auth/data/models/auth_token_model.dart`.

6. **Remote datasource** — `data/datasources/<name>_remote_datasource.dart`. Call `ApiClient` (`get/post/put/delete<T>(path, parse: ..., query:/body: ...)` → `ApiResult<T>`); never touch `Dio` directly. Add each path as a `static const` to `lib/core/network/api_endpoints.dart` — **create that file if it does not exist yet** (plain `abstract final class ApiEndpoints { static const ... }`). See [`04_how_to_add_new_api.md`](../../../osta_readme_files/guides/04_how_to_add_new_api.md).

7. **Repository impl** — `data/repositories/<name>_repository_impl.dart`. Implements the contract; wrap datasource calls in `try`/`catch` and convert the typed `ApiException` to a `Failure` via `e.toFailure()`, then map models to entities:
   ```dart
   @override
   Future<List<<Name>>> get<Name>s() async {
     try {
       final res = await _ds.get<Name>s();
       return res.map((m) => m.toEntity()).toList();
     } on ApiException catch (e) {
       throw e.toFailure();
     }
   }
   ```

8. **Bloc events** — `presentation/bloc/<name>_event.dart`. `sealed`/base `<Name>Event extends Equatable`; one event per user action (e.g. `<Name>LoadRequested`).

9. **Bloc states** — `presentation/bloc/<name>_state.dart`. `<Name>Initial` / `<Name>Loading` / `<Name>Loaded(data)` / `<Name>Error(Failure)`, all `Equatable`.

10. **Bloc** — `presentation/bloc/<name>_bloc.dart`. `extends Bloc<<Name>Event, <Name>State>`; each handler emits `Loading`, calls the use case inside `try`/`catch`, emits `Loaded` on success and `Error(f)` `on Failure catch (f)`. NO `.fold()`.

11. **Pages & widgets** — `presentation/pages/`, `presentation/widgets/`. Reuse `lib/shared/ui/` (`AppButton`, `AppCard`, `AppTextField`, `AppTopBar`, `EmptyState`/`ErrorState`/`LoadingState`, …). Use design tokens only: `AppSpacing`/`AppRadii`, `context.appColors`, `Theme.of(context).textTheme.*` — never raw colors/spacing and no `AppTextStyles` class. RTL-safe (`EdgeInsetsDirectional`/`start`/`end`). The page exposes `static const path`.

12. **Manual DI** — in `configureDependencies()` (`lib/core/di/injection.dart`), add hand-written lines: `registerLazySingleton` for datasource, repository, and each use case; `registerFactory` for the bloc:
    ```dart
    getIt
      ..registerLazySingleton<<Name>RemoteDataSource>(() => <Name>RemoteDataSource(getIt()))
      ..registerLazySingleton<<Name>Repository>(() => <Name>RepositoryImpl(getIt()))
      ..registerFactory<<Name>Bloc>(() => <Name>Bloc(Get<Name>s(getIt())));
    ```
    NO annotations, NO `injection.config.dart`.

13. **Route + l10n.** Add the route in `lib/core/router/app_router.dart` using the page's `static const path`. Add every user-facing string to **both** `lib/l10n/app_en.arb` (template) and `lib/l10n/app_ar.arb`, then run `flutter gen-l10n`; access via `context.l10n.<key>`. Never edit generated l10n in `lib/core/l10n/`. See [`05_how_to_add_new_language.md`](../../../osta_readme_files/guides/05_how_to_add_new_language.md).

## Post-Completion Checklist

- [ ] Folder tree matches step 1 (`data`/`domain`/`presentation` with the three sub-dirs each).
- [ ] Entity is pure Dart `Equatable` (no Flutter, no `fromJson`); repo contract returns entities and throws `Failure` (no `Either`/`Result`).
- [ ] Model has hand-written `fromJson`/`toJson`/`toEntity`/`props`; no codegen annotations, no `part '*.g.dart'`.
- [ ] Datasource goes through `ApiClient` (not `Dio`); every path added to `lib/core/network/api_endpoints.dart`.
- [ ] Repo impl uses `try`/`catch` + `e.toFailure()`; bloc emits `Initial`/`Loading`/`Loaded`/`Error` with no `.fold()`.
- [ ] UI uses `lib/shared/ui/` components + design tokens (`AppSpacing`/`AppRadii`/`context.appColors`/`textTheme`), RTL-safe; page has `static const path`.
- [ ] DI: hand-written `registerLazySingleton` (data/repo/usecases) + `registerFactory` (bloc) in `configureDependencies()`.
- [ ] Route added in `app_router.dart`; strings in **both** ARB files; `flutter gen-l10n` run.
- [ ] `dart format .`, `flutter analyze` (clean), `flutter test` (green). No `build_runner`.
- [ ] Docs updated: `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, `osta_readme_files/CURRENT_STATUS.md` (and the feature doc).
- [ ] Branch `feat/<issue>-<slug>` (hand-written kebab-case — never a tool-generated name like `cursor/...` or `claude/...`; rename with `git branch -m` first), PR base `main`, bilingual (AR+EN) description, conventional commits, no AI co-author trailer.
