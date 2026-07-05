# /new-screen

Add one page + its BLoC to an **existing** feature. Use this (not `/add-feature`) when the feature folder, datasource, and repository already exist and you only need another screen with its own state. For a whole new feature slice (data/domain/presentation + repo + DI graph) use [`/add-feature`](add-feature.md).

The osta stack is deliberately plain Dart: errors are a sealed `Failure` (`lib/core/error/failure.dart`) **thrown** and caught with `try`/`catch` — NO `Either`/`Result<T>`/`.fold()`. Models are `Equatable` + hand-written `fromJson`/`toJson`. DI is hand-registered `getIt` lines — NO injectable/build_runner. There is NO offline layer. Deferred tooling lives in [`docs/ROADMAP.md`](../../docs/ROADMAP.md).

## Before you build

Read the feature's epic + doc in [`osta_readme_files/features/`](../../osta_readme_files/features/README.md) so the screen matches specified scope. Pick `<feature>` (the existing folder, e.g. `customer/home`), `<name>` (snake_case screen, e.g. `booking_detail`), and `<Name>` (PascalCase prefix, e.g. `BookingDetail`). Branch `feat/<issue>-<slug>` off `main`.

## Steps

1. **Bloc events** — `lib/features/<feature>/presentation/bloc/<name>_event.dart`: base `<Name>Event extends Equatable`; one event per user action (e.g. `<Name>LoadRequested`). Override `props`.
2. **Bloc states** — `.../bloc/<name>_state.dart`: `<Name>Initial`/`<Name>Loading`/`<Name>Loaded(data)`/`<Name>Error(Failure)`, all `Equatable`.
3. **Bloc** — `.../bloc/<name>_bloc.dart`: `extends Bloc<<Name>Event, <Name>State>`. Each handler emits `Loading`, calls the existing use case / repository inside `try`/`catch`, emits `Loaded` on success and `Error(f)` `on Failure catch (f)`. No `.fold()`. Reuse the feature's existing repository — do not add a new datasource here.
4. **Page** — `lib/features/<feature>/presentation/<name>_page.dart`: `class <Name>Page extends StatelessWidget` with `static const path = '/<name>';`. Wrap the body in `BlocProvider(create: (_) => getIt<<Name>Bloc>()..add(const <Name>LoadRequested()))` and a `BlocBuilder`/`BlocConsumer`. (Pages live directly under `presentation/`, not `presentation/pages/` — match `role_selection_page.dart`.)
5. **Compose UI from shared** — reuse `lib/shared/ui/`: `AppButton`, `AppTopBar`, `AppCard`, `AppTextField`, `AppBottomSheet`, and `LoadingState`/`ErrorState`/`EmptyState` (status_states.dart) for the three bloc states. Tokens only: `AppSpacing`/`AppRadii`, `context.appColors`, `Theme.of(context).textTheme.*` — no raw colors/spacing, no `AppTextStyles`. RTL-safe: `EdgeInsetsDirectional`/`start`/`end`. Formatters `EgpFormatter`/`NumberFormatter` for money/numbers.
6. **Register the bloc** — in `configureDependencies()` (`lib/core/di/injection.dart`): add `..registerFactory<<Name>Bloc>(() => <Name>Bloc(getIt()))` (blocs are factories, not singletons). No annotations, no `injection.config.dart`.
7. **Route** — in `lib/core/router/app_router.dart` add a `GoRoute(path: <Name>Page.path, builder: (context, state) => const <Name>Page())` to the `routes` list. Use the page's `static const path`; do not invent a `RouteNames` class.
8. **l10n** — add every user-facing string to **both** `lib/l10n/app_en.arb` (template) and `lib/l10n/app_ar.arb`, then run `flutter gen-l10n`. Access via `context.l10n.<key>`. Never edit generated l10n in `lib/core/l10n/`.

## Checklist

- [ ] Bloc uses `try`/`catch` + `on Failure catch (f)` — no `Either`/`.fold()`.
- [ ] Bloc registered with `registerFactory` (not `registerLazySingleton`).
- [ ] Page has `static const path` and the route is added to `app_router.dart`.
- [ ] No new datasource/repository invented — the existing feature repo is reused.
- [ ] UI built from `lib/shared/ui/` + tokens; RTL-safe; the three bloc states render loading/error/empty.
- [ ] Strings in both ARB files; `flutter gen-l10n` run; accessed via `context.l10n`.
- [ ] `dart format .`, `flutter analyze` clean, `flutter test` green. No `build_runner`.
- [ ] Docs updated: `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, `osta_readme_files/CURRENT_STATUS.md`.
- [ ] Branch `feat/<issue>-<slug>`, PR base `main`, bilingual (AR+EN) description, conventional commits, no AI co-author trailer.
