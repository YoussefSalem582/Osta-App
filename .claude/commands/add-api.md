# /add-api

Wire a backend endpoint end-to-end through `ApiClient` in plain Dart — path constant → typed call → hand-written model → repository (maps `ApiException` → `Failure`) → use case → bloc → manual `get_it`. No codegen, no `Either`/`Result`/`.fold()`, no offline queue.

This command is an alias of the **add-api** skill. Follow it in full: [`.agents/skills/add-api/SKILL.md`](../../.agents/skills/add-api/SKILL.md). Deep guide: [`osta_readme_files/guides/04_how_to_add_new_api.md`](../../osta_readme_files/guides/04_how_to_add_new_api.md).

## Steps

1. **Path constant** — add to `lib/core/network/api_endpoints.dart` (`static const` for fixed paths, a helper method for `{id}` routes). Path only; base URL comes from `AppConfig.baseUrl`.
2. **Model** — plain `class X extends Equatable` + hand-written `fromJson`/`toJson`/`props`; map snake_case keys explicitly. No freezed/json_serializable/`*.g.dart`. Pattern: `lib/features/auth/data/models/auth_token_model.dart`.
3. **Data source** — call `ApiClient.get/post/put/delete<T>(path, parse:, query:, body:, authenticated:)`; read `res.data` (and `res.meta` for pagination). `authenticated: false` only for public routes. Never touch Dio directly.
4. **Repository** — `try`/catch the typed `ApiException`, throw a `Failure` mapped by subtype (`NetworkFailure`/`ServerFailure`/`UnknownFailure`). Form routes: let `ValidationException` through for `.fieldErrors`. No `Either`/`Result`/`.fold()`.
5. **Use case** — thin callable delegating to the repo.
6. **Bloc** — `try`/`catch (Failure)`; emit success/error. Login gotcha: bad credentials come back **422 `ValidationException`**, not 401 — do not special-case 401.
7. **Register** — one hand-written `registerLazySingleton` per collaborator in `configureDependencies()` (`lib/core/di/injection.dart`); blocs via `registerFactory`. No injectable/build_runner.
8. **Verify** — `dart format .`, `flutter analyze`, `flutter test`; add a test mapping a mocked envelope (see `test/core/network/api_client_test.dart`). Run `flutter gen-l10n` only if ARB files changed.
9. **Docs** — update `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, `osta_readme_files/CURRENT_STATUS.md`.
