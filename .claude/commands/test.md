# Write tests

Write unit/widget/golden tests for existing OSTA code — plain Dart, no codegen.
Stack: `flutter_test` + `http_mock_adapter` + hand fakes. NO mockito, NO mocktail, NO `build_runner`.

Reference: `osta_readme_files/guides/10_testing.md`. Existing suite lives in `test/`.

## Steps

1. **Read first.** Read the code under test and the closest existing test as a template:
   - repo/network → `test/core/network/api_client_test.dart`
   - bloc/cubit → `test/core/theme/theme_mode_controller_test.dart`
   - widget/golden → `test/shared/ui/components_test.dart`, `test/shared/ui/navigation_test.dart`
   Reuse the shared helpers in `test/core/network/fakes.dart` (`FakeTokenStorage`, `ScriptedAdapter`, `jsonResponse`, `tokenEnvelope`) — do not re-roll them.

2. **Mirror the source layout.** Test path mirrors `lib/` (e.g. `lib/features/x/data/x_repository.dart` → `test/features/x/data/x_repository_test.dart`). File ends `_test.dart`.

3. **Repositories** — feed Dio through `DioAdapter` (`http_mock_adapter`) or `ScriptedAdapter`. Assert:
   - success envelope `{success, data, meta}` → parsed model + `PaginationMeta`.
   - each error envelope `{success:false, error:{code,message,details}}` maps to the right `ApiException` (Validation 422 + `fieldErrors`, Unauthenticated 401, Forbidden 403, NotFound 404, RateLimit 429, Server 5xx) and the repo converts/rethrows it as a sealed `Failure` (`NetworkFailure`/`ServerFailure`/`UnknownFailure`). Bad login is **422, not 401**.
   - transport error → `NetworkException` → `NetworkFailure`.

4. **BLoCs/Cubits** — the repo **throws** a `Failure`; the bloc catches it with plain `try`/`catch` and emits an error state. Assert the state sequence with `emitsInOrder` on `bloc.stream` (no `bloc_test`). NO `.fold()`, NO `Either`, NO `Result<T>`.

5. **Widgets/goldens** — pump inside `MaterialApp` with `AppTheme.light`/`AppTheme.dark` and `localizationsDelegates: AppLocalizations.localizationsDelegates`. Cover **light/dark × RTL/LTR** (wrap in `Directionality` / `Locale('ar')` vs `Locale('en')`). Goldens go in the test dir; regenerate intentional changes with `flutter test --update-goldens`.

6. **Rules** — no hardcoded user-facing strings (assert via `context.l10n` keys); tokens via `AppSpacing`/`AppRadii`/`context.appColors`; never touch generated `lib/core/l10n/`.

7. **Run** — no codegen step; `flutter test` picks up l10n automatically:
   ```bash
   flutter test path/to/new_test.dart   # the file you wrote
   flutter test                         # full suite before finishing
   ```

8. **After green** — update `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, and `osta_readme_files/CURRENT_STATUS.md` (bump the test count in `guides/10_testing.md` if files/cases changed).
