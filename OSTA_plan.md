# OSTA_plan.md — Master Build Instructions for AI Agents

> **You are an AI coding agent continuing an existing Flutter repository — NOT building an app from scratch.**
> This document, together with [`AGENTS.md`](AGENTS.md), is your standing instruction set for delivering the
> remaining OSTA epics (tracker [#61](https://github.com/YoussefSalem582/Osta-App/issues/61)).
> The M0 foundation is already built, tested, and merged. Your job is to ship the feature surface on top of it —
> milestone by milestone, epic by epic — while keeping `main` releasable at every merge.

---

## §0 How to use this document

Read in this order before writing any code:

| # | Read | Why |
|---|------|-----|
| 1 | [`AGENTS.md`](AGENTS.md) | Canonical project conventions (architecture, tokens, API, DI, l10n, security, git) |
| 2 | **This document** | The build mission, the 11 non-negotiable mandates, the 4 amendments, and the execution order |
| 3 | The GitHub epic you are building | Scope, screens, flows, acceptance criteria, endpoints |
| 4 | Its feature doc in [`osta_readme_files/features/`](osta_readme_files/features/README.md) | Repo-side spec, mockups, endpoint tables, corrections to the epic |
| 5 | [`osta_readme_files/reference/DELIVERY_PLAN.md`](osta_readme_files/reference/DELIVERY_PLAN.md) | Milestones, owners, backend mirror, build order |

**This document AMENDS the repo canon in exactly four areas** (they implement the owner's standing mandates and
supersede anything older, including `AGENTS.md`, on these four points only):

1. **Logging** → the `talker` family replaces `pretty_dio_logger` (§9).
2. **Loading states** → `skeletonizer` everywhere; epic mentions of `shimmer` are overridden (§10).
3. **Offline-first architecture** → a new `lib/core/offline/` module and per-feature offline policies (§7).
4. **Releases & tags** → a SemVer tag + release convention that did not previously exist (§13).

Outside those four areas, if this document and `AGENTS.md` ever disagree, **`AGENTS.md` wins** — and you should
flag the discrepancy in your PR description.

**Progress tracking:** the live zero-to-production checklist is [`OSTA_TODO.md`](OSTA_TODO.md) — tick items
there as work merges; this document stays the rulebook.

---

## §1 Identity & mission

**OSTA (أُسطى)** is an Egyptian car-services marketplace. Customers discover service centers on a map, book
slots, pay via Paymob (wallets/InstaPay) or cash at the center, manage their garage, and shop a two-sided parts
marketplace. Businesses self-onboard (open registration, no verification), manage bookings/catalog/team, and get
a realtime dashboard.

- **One Flutter app** (`osta`, Dart SDK `^3.12.1`, CI pins Flutter 3.44.1) hosts every role: CUSTOMER +
  BUSINESS shells are active now; SOLO-MECHANIC + TOW-TRUCK are Phase-2 **"coming soon"** tiles on a shared
  provider shell. No monorepo, no Melos, no guest mode.
- **Arabic-first, RTL-first.** English is the secondary locale. Currency is **EGP**; phones are Egyptian
  (`+20`); money and digits go through the shared formatters.
- **Backend**: Laravel 12 at `/api/v1` — MVP feature-complete except M3.5 payments. Sanctum dual-token auth,
  `ApiResponse` envelope, Reverb websockets, FCM push, Paymob hosted checkout.

**Current state (do not rebuild — see §4):** M0 foundation is done and green (~32 tests): networking,
design system, theming, manual DI, router, l10n scaffolding, 8 shared UI components. Only `/splash` and
`/role` screens exist; every feature folder is an empty `data/domain/presentation` stub.

**Mission:** deliver the 31 open epics in tracker [#61](https://github.com/YoussefSalem582/Osta-App/issues/61)
in milestone order (§14), one epic per branch, small reviewed commits, cutting a tagged release at each
milestone boundary — with `main` always releasable.

---

## §2 Non-negotiable ground rules

These 11 mandates come directly from the project owner. Every PR is checked against them.

| # | Mandate (MUST) | Detail |
|---|----------------|--------|
| 1 | **Clean Architecture + BLoC** for every feature | §5 |
| 2 | **Dark and light theme** — every screen correct in both | §8.1 |
| 3 | **Responsive design** — adapts across compact/medium/expanded widths | §8.2 |
| 4 | **Localization** — ar (default, RTL) + en, zero hardcoded strings | §8.4 |
| 5 | **Screen animations and screen transitions** on every navigation and state change | §8.3 |
| 6 | **Reusable widgets + centralized resources** — colors, fonts, images, icons, text all live in one updatable place each | §6 |
| 7 | **`talker`** for logging and diagnostics (network, bloc, routes, errors) | §9 |
| 8 | **`skeletonizer`** for every loading state | §10 |
| 9 | **Document everything** — dartdoc + the four mandatory docs on every change | §12 |
| 10 | **Offline-first architecture** — local DB is the source of truth for reads; writes queue when safe | §7 |
| 11 | **Clean git graph** — feature branches, small commits, releases and tags | §13 |

And the hard **NEVER** list (violations block merge):

- **NEVER** add codegen: `freezed`, `json_serializable`, `injectable`, `build_runner`, `retrofit` — deferred by
  [`docs/ROADMAP.md`](docs/ROADMAP.md); models are hand-written `Equatable`, DI is manual `get_it`.
- **NEVER** add `fpdart` / `Either` / `Result<T>` / `.fold()` — errors are a `sealed Failure` thrown and caught
  with plain `try`/`catch`.
- **NEVER** use Riverpod or Provider for state — BLoC/Cubit only (some epic bodies mention Riverpod; ignore it, §3).
- **NEVER** add `firebase_auth` — social login exchanges provider tokens server-side (Laravel Socialite) via the
  existing `SocialTokenExchange`.
- **NEVER** call Dio directly from a feature — all HTTP goes through `ApiClient`.
- **NEVER** hardcode colors, spacing, radii, elevation, text styles, asset paths, durations, or user-facing
  strings — use the token/resource system (§6).
- **NEVER** store tokens in `SharedPreferences` — auth tokens live only in `TokenStorage` (secure storage).
- **NEVER** add `shimmer` (use `skeletonizer`, §10) or `flutter_screenutil` (use `AppBreakpoints`, §8.2).
- **NEVER** commit generated l10n (`lib/core/l10n/`) — regenerate with `flutter gen-l10n`.
- **NEVER** commit directly to `develop` or `main`; **NEVER** add AI/agent attribution to commits or PRs.
- **NEVER** keep auto-generated/tool-default branch names (`claude/...`, `cursor/...`, random suffixes) — branch names are hand-written `<type>/<issue>-<slug>` (§13.1).
- **NEVER** use `print`/`debugPrint` — log through `Talker` (§9).

---

## §3 Source of truth & conflict resolution

Precedence when sources disagree (highest wins):

| Rank | Source | Governs |
|------|--------|---------|
| 1 | Live backend contract — [`osta_readme_files/guides/09_api_endpoints.md`](osta_readme_files/guides/09_api_endpoints.md) + [osta_backend](https://github.com/YoussefSalem582/osta_backend/issues) | Endpoint paths, payload shapes, status codes |
| 2 | [`AGENTS.md`](AGENTS.md) + [`docs/ROADMAP.md`](docs/ROADMAP.md) + ADRs | Architecture, tooling, conventions |
| 3 | **This document** | The 4 amendments (§0) + execution order + cross-cutting UX/offline rules |
| 4 | Feature docs ([`osta_readme_files/features/`](osta_readme_files/features/README.md)) | Feature scope details, corrections to epics |
| 5 | GitHub epic bodies (#30–#62) | Acceptance criteria, screens, flows, edge cases |

> ⚠️ **The epics contain a stale package boilerplate — ignore it.**
> Every epic body quotes a "Core stack" stanza listing `injectable`, `freezed` + `json_serializable`
> (`build_runner`), and `fpdart`, and a few epics mention "Riverpod providers" or `shimmer` skeletons.
> That boilerplate predates the plain-Dart refactor
> ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69)) and is **superseded**.
> From each epic take: screens, flows, acceptance criteria, endpoints, edge cases, and the epic-specific
> packages listed in §14. Discard: its tooling/state-management stanza.

> ⚠️ **Verify backend readiness before starting an epic.** Some epics carry a `backend:ready` label while their
> header text says "⛔ blocked" (or vice versa): [#46](https://github.com/YoussefSalem582/Osta-App/issues/46),
> [#47](https://github.com/YoussefSalem582/Osta-App/issues/47),
> [#51](https://github.com/YoussefSalem582/Osta-App/issues/51),
> [#62](https://github.com/YoussefSalem582/Osta-App/issues/62). The truth is the endpoint catalogue
> ([guide 09](osta_readme_files/guides/09_api_endpoints.md)) and
> [guide 11](osta_readme_files/guides/11_backend_feature_connectivity.md) — check them first; if an endpoint is
> not live, build against the documented contract behind the UI but do not merge the wiring until it ships.

---

## §4 Repo map — what already exists (DO NOT REBUILD)

Reuse these. Extending them is normal; re-implementing them is a defect.

| Area | Files | What it gives you |
|------|-------|-------------------|
| Networking | `lib/core/network/api_client.dart`, `api_exception.dart`, `api_result.dart`, `pagination_meta.dart`, `dio_client.dart` | `ApiClient.get/post/put/delete<T>(parse: ...)` → `ApiResult<T>` (+ `PaginationMeta`); envelope parsing; 7 typed `ApiException`s mapped from `error.code` (422 validation w/ field errors, 401, 403, 404, 429, 5xx, network) |
| Auth plumbing | `lib/core/network/auth_interceptor.dart`, `auth_events.dart`, `social_token_exchange.dart`, `token_pair.dart`, `lib/core/auth/token_storage.dart` | Sanctum bearer attach, queued 401 refresh-retry-once, `AuthEvents.onSessionExpired`, Google/Apple token exchange, secure token persistence |
| Config | `lib/core/config/app_config.dart` | Single `BASE_URL` via `--dart-define` (no flavors, no .env) |
| DI | `lib/core/di/injection.dart` | `getIt` + `configureDependencies()` — register everything here, by hand |
| Router | `lib/core/router/app_router.dart` | GoRouter; pages expose `static const path`; currently `/splash` → `/role` |
| Theme | `lib/core/theme/app_colors.dart`, `app_theme.dart`, `app_tokens.dart`, `app_typography.dart`, `theme_mode_controller.dart` | `AppColors` ThemeExtension (`context.appColors`; brand green `#0E7A3B` + lime `#B2D235`), `AppTheme.light()/dark()`, `AppSpacing`/`AppRadii`/`AppElevation`, Cairo variable-font `TextTheme`, persisted `ThemeModeController` (Cubit) |
| Assets | `lib/core/constants/app_images.dart` | `AppImages.logo/fullLogo/mascot` |
| Shared UI | `lib/shared/ui/` | `AppButton`, `AppTopBar`, `AppBottomNavBar`/`AppBottomNavItem`, `AppCard`, `AppTextField`, `AppBottomSheet`, `EmptyState`/`ErrorState`/`LoadingState` |
| Formatters | `lib/shared/formatters/app_formatters.dart` | `EgpFormatter`, `NumberFormatter` (Arabic-Indic digits in `ar_EG`) |
| L10n | `lib/l10n/app_en.arb`, `app_ar.arb`, `lib/shared/extensions/context_ext.dart` | `context.l10n.<key>`; generated output in `lib/core/l10n/` (git-ignored) |
| Errors | `lib/core/error/failure.dart` | `sealed class Failure implements Exception` — `NetworkFailure`/`ServerFailure`/`UnknownFailure` |
| Tests | `test/` (11 files, ~32 cases) | Network, theme (incl. required contrast test), shared UI, formatters — `flutter_test` + `http_mock_adapter` + hand-rolled fakes (no mockito/mocktail) |

Rules:

- **Before creating any widget, check `lib/shared/ui/` first.** Extend an `App*` component; don't fork it.
- Once auth ([#35](https://github.com/YoussefSalem582/Osta-App/issues/35)) lands, it becomes the canonical
  reference implementation for feature structure — copy its shape for every later feature.

---

## §5 Architecture spec — Clean Architecture + BLoC (no codegen)

Every feature lives in `lib/features/<area>/` (customer/business features nest:
`lib/features/customer/booking/`, `lib/features/business/dashboard/`) with three layers:

```text
lib/features/<feature>/
├── data/          # models (Equatable + hand-written fromJson/toJson), datasources (remote/local), repository impls
├── domain/        # entities, repository contracts (abstract), use cases — ZERO Flutter imports
└── presentation/  # blocs/cubits, pages, feature-local widgets
```

- **Dependency rule:** `data → domain ← presentation`. Domain depends on nothing above it.
- **Models:** plain `Equatable` classes with hand-written `fromJson`/`toJson`. No codegen, no annotations.
- **State:** `Bloc` for feature flows (events), `Cubit` for simple state (e.g. `ThemeModeController`).
  States/events are `Equatable` value types.
- **Errors are thrown, not returned.** The repository translates transport errors to domain failures; the bloc
  turns failures into UI states:

```dart
// data layer — repository implementation
Future<List<Booking>> myBookings() async {
  try {
    final result = await _api.get<List<Booking>>('/bookings', parse: Booking.listFromJson);
    return result.data;
  } on ApiException catch (e) {
    throw switch (e) {
      NetworkException() => const NetworkFailure(),
      ServerException() => const ServerFailure(),
      _ => UnknownFailure(e.message),
    };
  }
}

// presentation layer — bloc
try {
  emit(BookingsLoaded(await _repository.myBookings()));
} on Failure catch (f, st) {
  getIt<Talker>().handle(f, st);
  emit(BookingsError(f));
}
```

- **DI:** hand-written registrations in `configureDependencies()`:

```dart
getIt.registerLazySingleton<BookingRepository>(() => BookingRepositoryImpl(getIt(), getIt()));
getIt.registerFactory(() => BookingBloc(getIt()));
```

- **API:** all HTTP through `ApiClient`; success envelope `{success, data, meta}` → `ApiResult<T>`; error
  envelope → typed `ApiException`. Bad login is **422, not 401** (backend contract). Pagination via
  `PaginationMeta` from `meta`. Attach `Accept-Language` per §8.4.
- **Routing:** go_router; every page declares `static const path`. Role shells use `StatefulShellRoute`
  ([#34](https://github.com/YoussefSalem582/Osta-App/issues/34)) — Consumer: Home · Booking · Map · Shop · More;
  Provider: Dashboard · Catalog · Booking · Shop · More. **`me.type` is the single source of truth** for shell
  selection; unauthenticated access to any route redirects to login; 401/logout clears tokens + `me` cache and
  returns to login.

---

## §6 Centralized resource system

Everything visual or textual must be changeable from exactly one place. Mapping of the owner's mandate to repo
mechanisms:

| Resource | Central place | Access | Rule |
|----------|---------------|--------|------|
| **App colors** | `lib/core/theme/app_colors.dart` (`AppColors` ThemeExtension) + `ColorScheme` | `context.appColors.accent`, `Theme.of(context).colorScheme.*` | New colors need **light AND dark** values + the contrast test (`test/core/theme/contrast_test.dart`). No hex outside this file. |
| **App fonts** | `lib/core/theme/app_typography.dart` (`AppTypography`, Cairo variable font) | `Theme.of(context).textTheme.*` | No inline `TextStyle(...)`; new text roles are added to `AppTypography` |
| **App images** | `lib/core/constants/app_images.dart` (`AppImages`) | `AppImages.logo` | No raw `'assets/images/...'` strings; register new assets here + `pubspec.yaml` |
| **App icons** | **NEW** `lib/core/constants/app_icons.dart` (`AppIcons`) — create in the first UI epic that needs it (#33/#37) | `AppIcons.booking` | Static `IconData`/SVG-asset refs; no scattered `Icons.*` for brand/domain icons |
| **App text** | `lib/l10n/app_en.arb` + `app_ar.arb` (the central text store) | `context.l10n.<key>` | Zero hardcoded user-facing strings; every key exists in **both** ARBs; regenerate with `flutter gen-l10n` |
| Spacing / radii / elevation | `lib/core/theme/app_tokens.dart` | `AppSpacing.md`, `AppRadii.md`, `AppElevation.low` | No raw numbers |
| **Motion** | **NEW** `AppDurations` + `AppCurves` in `app_tokens.dart` (§8.3) | `AppDurations.base` | No inline `Duration(...)`/curves in widgets |
| **Breakpoints** | **NEW** `AppBreakpoints` in `app_tokens.dart` (§8.2) | `AppBreakpoints.medium` | No magic width numbers |

**Reusable-widget rule:** any UI fragment used (or clearly about to be used) **twice or more** is promoted to
`lib/shared/ui/` as an `App*` widget with dartdoc and a widget test. Feature-local widgets stay under the
feature's `presentation/widgets/`. Screens are compositions of reusable widgets — not monoliths.

---

## §7 Offline-first architecture (AMENDMENT — new core module)

No offline infrastructure exists today; this section defines it. Build the core module with the **first M1 epic
that needs persistence** (legal caching in [#38](https://github.com/YoussefSalem582/Osta-App/issues/38) is the
natural first consumer), then every subsequent repository adopts the pattern.

### 7.1 Stack (respects the no-codegen rule)

| Package | Role |
|---------|------|
| `sqflite` | Single local store — hand-written SQL, zero codegen. (**`drift` is banned** — it requires `build_runner`.) |
| `sqflite_common_ffi` (dev) | Runs DB tests on the host in CI |
| `connectivity_plus` | Connectivity signal for the offline banner + sync triggers (pair with a lightweight reachability probe — connectivity ≠ internet) |

### 7.2 Module layout

```text
lib/core/offline/
├── app_database.dart        # opens the DB, owns schema + migrations (hand-written SQL)
├── cache_store.dart         # generic JSON-document cache (read/upsert/evict by feature+key, TTL-aware)
├── pending_operations.dart  # queued-mutation store + models
├── sync_engine.dart         # drains the queue on reconnect (registered in DI, started at boot)
└── connectivity_service.dart# exposes Stream<bool> online$, current state
```

Two shared tables to start (features may add their own):

```sql
CREATE TABLE cache_entries (
  feature TEXT NOT NULL, key TEXT NOT NULL, json TEXT NOT NULL,
  fetched_at INTEGER NOT NULL, ttl_seconds INTEGER,
  PRIMARY KEY (feature, key)
);
CREATE TABLE pending_operations (
  id INTEGER PRIMARY KEY AUTOINCREMENT, method TEXT NOT NULL, path TEXT NOT NULL,
  body_json TEXT, idempotency_key TEXT NOT NULL, created_at INTEGER NOT NULL,
  retry_count INTEGER NOT NULL DEFAULT 0
);
```

The JSON-document cache deliberately reuses the existing hand-written `fromJson` — no parallel schema to
maintain.

### 7.3 Repository pattern — cache-then-network

Reads: **local DB is the single source of truth.** Emit cached data immediately, refresh from the network,
upsert, re-emit.

```dart
class CentersRepositoryImpl implements CentersRepository {
  CentersRepositoryImpl(this._remote, this._cache);

  Stream<List<Center>> nearby(LatLng at) async* {
    final cached = await _cache.read('centers', at.cacheKey);
    if (cached != null) yield Center.listFromJson(cached);          // 1. serve stale instantly
    try {
      final fresh = await _remote.nearby(at);                       // 2. refresh
      await _cache.upsert('centers', at.cacheKey, fresh.rawJson);   // 3. persist
      yield fresh.data;                                             // 4. re-emit
    } on Failure {
      if (cached == null) rethrow;                                  // nothing to show → surface error
    }
  }
}
```

Writes: safe mutations enqueue to `pending_operations` when offline (optimistic UI + rollback on sync failure);
the `SyncEngine` drains the queue on reconnect with exponential backoff, sending each operation's
`idempotency_key` so retries never duplicate server state.

### 7.4 Per-feature offline policy

| Policy | Features |
|--------|----------|
| **Cached reads** (cache-then-network) | Nearby/search centers & map data (#41/#43), center profiles (#42), my bookings list (#45), garage + maintenance (#50), business catalog (#56), shop browse/detail (#48), home feed sections (#51), legal docs (#38 — explicitly required by its epic), notifications inbox (#52), business dashboard snapshot (#54) |
| **Queued mutations** (optimistic + sync) | Garage CRUD + maintenance log (#50), catalog/pricing edits (#56), shop product edits (#57), profile edits (#40) |
| **Online-only** (graceful blocking UI + retry) | Auth (#35/#36/#53), booking create/confirm (#44 — the 10-minute slot hold and the exactly-one-POST rule make queued booking writes unsafe), cancel/reschedule (#45), booking accept/reject/assign (#55/#62), payments (#46), realtime channels (#47/#54), account deletion (#40) |

### 7.5 Offline UX rules

- A shared **offline banner** widget (promote to `lib/shared/ui/`) appears on every screen when offline.
- Screens showing cached data expose a **"last updated" affordance** (relative timestamp).
- Queued writes render **optimistically** with rollback + user notice if sync ultimately fails.
- **Pull-to-refresh everywhere** a list or feed exists.
- Online-only actions disable their CTA with a localized "you're offline" hint instead of failing.

---

## §8 UX standards

### 8.1 Theme — dark & light (mandate 2)

- Every screen MUST render correctly in **both** modes — verified by golden tests (light × dark).
- Semantic tokens only (`context.appColors`, `colorScheme`); adding a color means adding **both** light and dark
  values in `app_colors.dart` plus a contrast-test entry (WCAG AA).
- The persisted `ThemeModeController` (light/dark/system) is already wired; surface its toggle in Settings
  ([#40](https://github.com/YoussefSalem582/Osta-App/issues/40)).

### 8.2 Responsive design (mandate 3)

- **No `flutter_screenutil`** — it was deliberately removed; never reintroduce it.
- Add `AppBreakpoints` to `app_tokens.dart` using Material 3 window classes:
  `compact < 600` · `medium 600–839` · `expanded ≥ 840` (logical px).
- Adapt with `LayoutBuilder` / `MediaQuery.sizeOf`: multi-column grids and constrained content width
  (`ConstrainedBox(maxWidth: ...)`) on medium/expanded; never fixed pixel layouts.
- Prefer `Flexible`/`Expanded`/`FractionallySizedBox` over fixed sizes; min touch target **48dp**; layouts must
  survive text scale up to **2.0** without overflow (test key screens with `textScaleFactor: 2.0`).

### 8.3 Screen animations & transitions (mandate 5)

- Add the official **`animations`** package (Material motion; no codegen). Everything else uses Flutter
  built-ins — do not add `flutter_animate` or other animation DSLs.
- **One transition helper owns all route transitions:** create `lib/core/router/app_transitions.dart` exposing
  `CustomTransitionPage` builders; go_router routes use these instead of default pages:
  - **Shared-axis horizontal** — forward navigation within a flow (list → detail, wizard steps).
  - **Fade-through** — sibling/tab/shell switches.
  - **Vertical slide / bottom-sheet** — modals, sheets, dialogs-as-routes.
- **Hero** animations for card → detail images (center card → center profile #42, product card → product
  detail #48).
- **`AnimatedSwitcher`** for skeleton → content swaps (§10) and small state changes; implicit animations
  (`AnimatedContainer` etc.) for micro-interactions.
- **Staggered list entrances** capped: animate roughly the first 8 visible items, total sequence ≤ 400ms.
- Add motion tokens to `app_tokens.dart` — `AppDurations` (`fast 150ms` · `base 250ms` · `slow 400ms`) and
  `AppCurves` (`standard`, `emphasized`) — **never inline a `Duration` or curve in a widget**.
- MUST respect reduced motion: when `MediaQuery.disableAnimationsOf(context)` is true, collapse durations to
  zero (route transitions fall back to fades/none).

### 8.4 Localization & RTL (mandate 4)

- Arabic is the **default** locale and the app is RTL-first; English is secondary. Runtime language switching
  (persisted, no restart) lands in [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) — the first epic
  to execute.
- Every user-facing string: add the key to **both** `lib/l10n/app_en.arb` and `app_ar.arb`, run
  `flutter gen-l10n`, use `context.l10n.<key>`. Never edit or commit `lib/core/l10n/`.
- Directional layout only: `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end` — never `left`/`right`;
  mirror directional icons (chevrons, back arrows).
- Numbers, dates, plurals, and money localize through `intl` + the shared `EgpFormatter`/`NumberFormatter`
  (Arabic-Indic digits in `ar_EG`).
- Every API request carries `Accept-Language: ar|en` matching the active locale (Dio interceptor, part of #30).
- Golden tests cover **RTL × LTR** for key screens.

---

## §9 Logging & diagnostics — talker (AMENDMENT — mandate 7)

The `talker` family replaces `pretty_dio_logger`. Where `AGENTS.md` or older docs mention `pretty_dio_logger`,
this section supersedes them.

**Packages:** `talker_flutter`, `talker_dio_logger`, `talker_bloc_logger`. **Remove** `pretty_dio_logger` from
`pubspec.yaml` and `dio_client.dart` in the same change.

**Wiring (one small dedicated branch, early — see §14 M0):**

```dart
// core/di/injection.dart
getIt.registerLazySingleton<Talker>(() => TalkerFlutter.init());

// core/network/dio_client.dart — replaces PrettyDioLogger; redaction rules preserved
dio.interceptors.add(TalkerDioLogger(
  talker: getIt<Talker>(),
  settings: const TalkerDioLoggerSettings(
    hiddenHeaders: {'authorization'},      // NEVER log bearer tokens
    printRequestData: false,               // auth bodies stay out of logs
    printResponseData: false,
  ),
));

// main.dart
Bloc.observer = TalkerBlocObserver(talker: getIt<Talker>());

// core/router/app_router.dart
GoRouter(observers: [TalkerRouteObserver(getIt<Talker>())], ...)
```

**Usage conventions:**

- No `print`/`debugPrint` anywhere. `talker.info` = lifecycle events, `talker.warning` = recoverable oddities,
  `talker.handle(error, stackTrace)` = every caught `Failure`/exception surfaced to the UI.
- Security rules from `AGENTS.md` still apply: Authorization headers and auth request/response bodies are
  **always redacted**.
- Optional: a debug-only route exposing `TalkerScreen` for on-device QA (never linked in release builds).
- In tests, Talker doubles as a diagnostics aid — assert on logged errors where useful.

---

## §10 Loading states — skeletonizer (AMENDMENT — mandate 8)

- Every list/detail first-load renders a **`Skeletonizer`** over the real layout populated with plausible fake
  data — no bespoke skeleton widgets, no `shimmer` (epic mentions of shimmer are overridden):

```dart
Skeletonizer(
  enabled: state is BookingsLoading,
  child: BookingsList(bookings: state.orFake(Booking.fakes)),
)
```

- Swap skeleton → content through `AnimatedSwitcher` (fade, `AppDurations.fast`).
- The existing `LoadingState` shared widget remains for full-screen boot spinners and in-button progress;
  skeletonizer is for content placeholders.
- **Every screen ships the full state quartet:** loading (skeleton) · empty (`EmptyState`) · error
  (`ErrorState` + retry) · offline (banner / stale-data affordance, §7.5).

---

## §11 Testing requirements

Per epic, the minimum bar (CI runs `format · analyze · test` on every PR; all must be green):

| Kind | What |
|------|------|
| Unit | Every bloc/cubit (event → state, incl. failure paths) and repository (envelope parse, `ApiException` → `Failure` mapping, cache-then-network behavior) — hand-rolled fakes + `http_mock_adapter`; **no mockito/mocktail** |
| Widget | Every page: state quartet renders; interactions dispatch the right events |
| Golden | Key screens in **light/dark × RTL/LTR** (4 variants) |
| DB | Local datasources against `sqflite_common_ffi` |
| Contrast | Required for any new color pair (extend `test/core/theme/contrast_test.dart`) |

- Test tree mirrors `lib/` (`test/features/<feature>/...`).
- Epic-specific test expectations (e.g. #44's exactly-one-POST double-tap test, #47's reconnect test) come from
  the epic body + feature doc and are part of its Definition of Done.
- Local gate before every commit: `dart format .` && `flutter analyze` && `flutter test`.

---

## §12 Documentation requirements (mandate 9)

- **Dartdoc `///`** on every public class, method, and non-obvious member you add.
- After **every meaningful change**, update the mandatory four (per `AGENTS.md`):
  1. [`CHANGELOG.md`](CHANGELOG.md) — entry under `## [Unreleased]`;
  2. [`osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`](osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md) — dated entry at the top;
  3. [`osta_readme_files/CURRENT_STATUS.md`](osta_readme_files/CURRENT_STATUS.md) — status + metrics;
  4. The relevant feature doc in `osta_readme_files/features/`.
- Repo docs are bilingual EN/AR — when you touch them, keep both languages in sync (identifiers, tables, and
  endpoints stay English).
- Any architectural decision this plan doesn't already cover gets a new ADR in
  [`osta_readme_files/decisions/`](osta_readme_files/decisions/README.md).

---

## §13 Git workflow, releases & tags (mandate 11; releases are an AMENDMENT)

### 13.1 Branches & commits (existing convention — restated)

- **`develop` integrates; `main` releases.** `develop` is the default branch all day-to-day work targets; `main` is always releasable and advances **only** through a `develop → main` release PR. **Never commit to either directly.**
- One epic (or chore) per branch: `feat/<issue>-<slug>` (e.g. `feat/44-booking-funnel`); also `fix/`,
  `refactor/`, `test/`, `docs/`, `chore/`. Branch off up-to-date `develop`; PR base is `develop`.
- **Branch names are hand-written, descriptive, lowercase kebab-case** (`feat/44-booking-funnel`,
  `fix/auth-401-loop`, `chore/talker-logging`). **NEVER** keep an auto-generated or tool-default branch name
  (random suffixes, `claude/...`, `cursor/...`, `codex/...`). If your tooling created the branch for you,
  rename it before the first push: `git branch -m <type>/<issue>-<slug>`.
- **Small commits, clean graph:** Conventional Commits (`feat(booking): ...`), subject ≤ 72 chars, imperative,
  one logical change per commit. Build a feature **layer by layer** — `domain → data → presentation → tests →
  docs` — so the history reads as a story. Forbidden subjects: `WIP`, `update`, `misc`, `fixes`.
- PR descriptions are **bilingual (EN/AR)** and link their epic (`Closes #44`).
- **No AI/agent attribution** in commits, PR bodies, or code comments.
- Quality gate before every push: `dart format .` && `flutter analyze` && `flutter test`.

### 13.2 Releases & tags (NEW — no tags exist yet)

- **SemVer annotated tags `vX.Y.Z` on `main` only.** Pre-1.0: cut `v0.<n>.0` when a milestone completes
  (see the release column in §14); `v1.0.0` = MVP complete (M0–M5 + Shop/Home/Notifications green).
  Hotfixes on a release increment the patch (`v0.3.1`).
- `pubspec.yaml` `version: X.Y.Z+B` — version matches the tag; build number `+B` increases monotonically with
  every release.
- **Release procedure** (checklist) — a `develop → main` release:
  1. Branch `chore/release-vX.Y.Z` off up-to-date `develop` (the release candidate).
  2. Move `CHANGELOG.md` `[Unreleased]` content into a new `## [X.Y.Z] - YYYY-MM-DD` section (keep the
     Keep-a-Changelog link refs updated); bump `pubspec.yaml`.
  3. Update `CURRENT_STATUS.md` (version banner) + `DOCUMENTATION_UPDATE_SUMMARY.md`.
  4. Open the release PR **`chore/release-vX.Y.Z` → `main`** → review → merge (this is the only way `main` advances).
  5. Annotated tag on the merge commit: `git tag -a vX.Y.Z -m "OSTA vX.Y.Z — <milestone>"` → push the tag.
  6. GitHub Release from the tag with bilingual notes (optionally attach a debug APK).
  7. Merge `main` back into `develop` so the release commit, version bump, and any hotfixes live on both.
- Tag pushes touch the remote — do them only with the repo owner's approval, consistent with the approved
  command policy in `AGENTS.md`.

### 13.3 Target graph shape

```text
*   v0.3.0 — chore/release-v0.3.0 (tag)
*   Merge feat/43-filters-search
|\
| * test(filters): session persistence + debounce
| * feat(filters): filter sheet + query builder
| * feat(filters): domain contracts
|/
*   Merge feat/42-center-profile
...
```

Small feature branches merged one at a time into `develop`; `main` advances only through tagged `develop → main` releases at milestone boundaries — a graph a human can read.

---

## §14 Milestone execution plan (M0 → M7 + Phase 2)

Execution order follows tracker [#61](https://github.com/YoussefSalem582/Osta-App/issues/61) and
[`DELIVERY_PLAN.md`](osta_readme_files/reference/DELIVERY_PLAN.md); tick progress in
[`OSTA_TODO.md`](OSTA_TODO.md). For each epic: read the issue + its feature
doc, honor §2–§13, and treat the 3–5 ACs below as headlines — **the epic body remains the full AC source**.
Mockups live on the [`design-assets`](https://github.com/YoussefSalem582/Osta-App/tree/design-assets) branch.

> For the two amendment chores (talker, offline core) open a GitHub issue first so the branch can follow
> `feat/<issue>-<slug>`; if that's not possible, use the `chore/` names below.

### M0 — Finish the foundation → cut `v0.1.0`

| Epic | Branch | Build & key ACs |
|------|--------|-----------------|
| [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) Localization & RTL | `feat/30-localization-rtl` | Runtime ar/en switch (instant, persisted, no restart); `LocaleController` Cubit + SharedPreferences; `Accept-Language` Dio interceptor; directional-layout sweep; ARB-coverage test (every key in both files); zero hardcoded strings. |
| Talker migration (§9) | `chore/talker-logging` | Add `talker_flutter`/`talker_dio_logger`/`talker_bloc_logger`; remove `pretty_dio_logger`; DI singleton + bloc observer + route observer; redaction preserved; no `print` anywhere. |
| Offline core (§7) | `chore/offline-core` | `lib/core/offline/` module: `sqflite` DB + `cache_store` + `pending_operations` + `sync_engine` + `connectivity_service`; offline banner widget; DB tests on `sqflite_common_ffi`. |
| Motion + breakpoints (§8.2/§8.3) | `chore/motion-breakpoint-tokens` | `AppDurations`/`AppCurves`/`AppBreakpoints` in `app_tokens.dart`; `app_transitions.dart` helper wired into the router; reduced-motion support. |

### M1 — First-run, auth & account → cut `v0.2.0`

| Epic | Branch | Build & key ACs | Endpoints | Offline | Adds |
|------|--------|-----------------|-----------|---------|------|
| [#33](https://github.com/YoussefSalem582/Osta-App/issues/33) Role chooser | `feat/33-role-chooser` | 4 role cards — customer+business active, mechanic+tow "coming soon" disabled; `activeRole` persisted (secure storage); `account_type` flows into auth payloads. | reuses auth | — | `flutter_svg` |
| [#34](https://github.com/YoussefSalem582/Osta-App/issues/34) Role-aware routing & shells | `feat/34-role-shells` | `StatefulShellRoute` ×2 (Consumer: Home·Booking·Map·Shop·More / Provider: Dashboard·Catalog·Booking·Shop·More); `me.type` = source of truth; wrong-shell login self-heals + toast; unauthenticated → login; logout/401 clears state. | `GET /me`, `POST /auth/logout` | — | — |
| [#35](https://github.com/YoussefSalem582/Osta-App/issues/35) Auth email+password | `feat/35-auth-email-password` | Login/register (first/last, unique username, +20 phone, optional avatar, terms gate); inline 422 field errors (bad login = 422); tokens in `TokenStorage`, survive relaunch; forgot/reset E2E; **canonical feature reference** once merged. | `POST /auth/register`, `/auth/login`, `/auth/refresh`, `/auth/logout`, `/auth/password/forgot`, `/auth/password/reset` | online-only | `formz`, `image_picker` |
| [#36](https://github.com/YoussefSalem582/Osta-App/issues/36) Social login | `feat/36-social-login` | Google + Apple on login & register (Apple mandatory on iOS); native OAuth → `SocialTokenExchange` (server Socialite — **no firebase_auth**); cancel/network/email-conflict → localized snackbars. | `POST /auth/social/{google\|apple}` | online-only | `google_sign_in`, `sign_in_with_apple`, `crypto` |
| [#37](https://github.com/YoussefSalem582/Osta-App/issues/37) Splash, language & onboarding | `feat/37-splash-onboarding` | Branded splash: silent refresh + `/me` route ≤ ~2s, no flicker; language screen (first run only); 3-slide carousel gated on `onboarding_seen`. | `GET /me` | — | `flutter_native_splash` (dev), `smooth_page_indicator` |
| [#38](https://github.com/YoussefSalem582/Osta-App/issues/38) Terms, Privacy & About | `feat/38-legal-screens` | `LegalDocScreen` (versioned bilingual content); register blocked until accept checkbox; accepted versions sent with register; About (version, contact, support_id explainer); **cached by version for offline reads — first §7 consumer**. | `GET /legal/terms`, `/legal/privacy` | cached reads | `flutter_markdown_plus`, `url_launcher`, `package_info_plus` |
| [#39](https://github.com/YoussefSalem582/Osta-App/issues/39) Required car onboarding | `feat/39-car-onboarding` | Post-register gate: zero cars ⇒ Home unreachable by any path; brand→model→year/plate/km validated (year 1980–now+1, Egyptian plate, km ≥ 0); first car auto-primary; 422 inline; form reusable by #50. | `POST /vehicles`, `GET /vehicles` | online-only (gate check cached) | `dropdown_search` |
| [#40](https://github.com/YoussefSalem582/Osta-App/issues/40) Account & More hub | `feat/40-account-more-hub` | More hub in **both shells**; profile edit + avatar (optimistic); copyable `support_id` chip; settings (language/theme, instant + persisted); addresses CRUD (single default); soft delete → revoke all → role chooser. | `GET/PUT /me`, `POST /me/avatar`, `GET/POST/PUT/DELETE /me/addresses`, `DELETE /me` | profile edits queued; delete online-only | `image_picker`, `package_info_plus`, `url_launcher` |
| [#53](https://github.com/YoussefSalem582/Osta-App/issues/53) Business onboarding | `feat/53-business-onboarding` | Multi-step wizard + progress header; Step 1 identity/location (trade name is user-facing; logo optional; +20 phone; map pin); Step 2 catalog — presets, "Add 12 common services", custom sheet; **≥1 service mandatory**; live immediately → Dashboard. | `POST /auth/register` (`account_type=business`), `PUT /business/profile`, catalog seed | online-only; wizard state persisted locally | `google_maps_flutter`, `geolocator`, `permission_handler`, `formz`, `image_picker` |

### M2 — Discovery → cut `v0.3.0`

| Epic | Branch | Build & key ACs | Endpoints | Offline | Adds |
|------|--------|-----------------|-----------|---------|------|
| [#41](https://github.com/YoussefSalem582/Osta-App/issues/41) Map screen | `feat/41-map-screen` | Full-screen map from center FAB; nearest-first markers; live search + category chips (debounced); marker → place dialog (rating, distance, open-now, Book/Details); permission-denied/empty/error states; light+dark map styles. | `GET /centers/nearby`, `/centers/search`, `/centers/{id}` | cached reads | `google_maps_flutter`, `geolocator`, `permission_handler`, `geocoding`, `google_maps_cluster_manager_2` |
| [#42](https://github.com/YoussefSalem582/Osta-App/issues/42) Center profile | `feat/42-center-profile` | Header (name/type/rating/hours/address) + tabs Services/Reviews/About + Shop strip; per-tab state quartet; paginated reviews; pinned "Book a service" CTA carrying center id; Hero from map/list card. | `GET /centers/{id}` + `/services`, `/reviews`, `/availability`, `/products` | cached reads | `flutter_rating_bar`, `carousel_slider`, `readmore`, `url_launcher` |
| [#43](https://github.com/YoussefSalem582/Osta-App/issues/43) Filters & search | `feat/43-filters-search` | Filter sheet: type/price_max/min_rating/open_now (**no "verified"**); results always rating-desc on Map + List; ~300ms debounce; session-scoped filter state (restored on reopen, cleared on logout); badge + Clear all. | `GET /centers/search`, `GET /centers?type=&price_max=&min_rating=&open_now=&sort=rating_desc` | cached reads | `easy_debounce` |

### M3 — Booking (cash MVP) → cut `v0.4.0`

| Epic | Branch | Build & key ACs | Endpoints | Offline | Adds |
|------|--------|-----------------|-----------|---------|------|
| [#44](https://github.com/YoussefSalem582/Osta-App/issues/44) Booking funnel | `feat/44-booking-funnel` | Service catalog → slot picker (full slots disabled) → **10-min hold with visible countdown, auto-release at 0** → review (+ vehicle picker) → confirm pay-at-center; **exactly one POST** (disabled-while-pending); 409 (slot taken/hold expired) recovers to slot picker. | `GET /centers/{id}/availability?date=`, `POST /bookings` | **online-only** | `table_calendar` |
| [#45](https://github.com/YoussefSalem582/Osta-App/issues/45) My bookings & detail | `feat/45-my-bookings` | Upcoming/Past tabs (paginated, pull-to-refresh); detail: status timeline, payment block, center contact (call/chat), reference; cancel (cancellable statuses only) + reschedule via slot picker — **optimistic with rollback**. | `GET /bookings?status=`, `GET /bookings/{id}`, `POST /bookings/{id}/cancel`, `PATCH /bookings/{id}/reschedule` | list cached; actions online-only | `timeline_tile` |
| [#55](https://github.com/YoussefSalem582/Osta-App/issues/55) Business bookings mgmt | `feat/55-business-bookings` | List + calendar toggle, status filter chips; detail sheet (customer, vehicle, services, EGP total); accept / reject **with required reason** / advance status (**confirmed→in_progress→completed only**); assign-mechanic picker (active roster, reassign/unassign); live board via Reverb. | `GET /business/bookings`, `PATCH .../accept`, `.../reject`, `.../status`, `.../assign-mechanic`, `GET /business/mechanics` | list cached; actions online-only | `timeline_tile` |
| [#62](https://github.com/YoussefSalem582/Osta-App/issues/62) Team & mechanics | `feat/62-team-mechanics` | Roster CRUD (name, +20 phone, specialty, photo, active; soft delete); assign picker integration in #55; empty roster → "Add your team" CTA; **roster entry = no login** (distinct from Phase-2 solo-mechanic #59). | `GET/POST/PATCH/DELETE /business/mechanics`, `PATCH /business/bookings/{id}/assign-mechanic` | roster cached; edits queued | `image_picker`, `formz` |

### M3.5 — Payments (⛔ backend blocked — do not merge until osta_backend #47–#49 ship)

| Epic | Branch | Build & key ACs | Endpoints | Offline | Adds |
|------|--------|-----------------|-----------|---------|------|
| [#46](https://github.com/YoussefSalem582/Osta-App/issues/46) Paymob wallets + InstaPay | `feat/46-paymob-payments` | "Pay online" beside pay-at-center; Paymob **hosted checkout in WebView** (no SDK, no card data in app); state machine `idle→creatingIntent→awaitingGateway→polling→paid/failed`; **idempotency key ⇒ retry never double-charges**; invoice PDF; localized decline/timeout errors with safe retry. | `POST /payments/intent`, `GET /payments/{id}`, `GET /invoices/{id}` | **online-only** | `webview_flutter`, `url_launcher` |

### M4 — Realtime → cut `v0.5.0`

| Epic | Branch | Build & key ACs | Endpoints | Offline | Adds |
|------|--------|-----------------|-----------|---------|------|
| [#47](https://github.com/YoussefSalem582/Osta-App/issues/47) Realtime booking status | `feat/47-realtime-status` | **NEW shared `RealtimeService` in `lib/core/realtime/`** (single Reverb wrapper — features never open sockets); private `bookings.{id}` → animated 5-step timeline (~2s latency); reconnect with backoff+jitter; 15s poll fallback + reconcile on rejoin; unsubscribe on dispose; "reconnecting" banner. | Reverb `bookings.{id}` (`BookingStatusChanged`), `POST /broadcasting/auth`, poll `GET /bookings/{id}` | realtime online-only; last status cached | Reverb client (`pusher_channels_flutter` or `web_socket_channel` — resolve against backend #50/#51) |
| [#54](https://github.com/YoussefSalem582/Osta-App/issues/54) Business dashboard | `feat/54-business-dashboard` | Provider-shell home: 4 KPI counters, revenue snapshot, new-bookings list with inline accept/reject (optimistic + rollback), today timeline; live `centers.{id}` prepend + counter bump; **shell reusable by future mechanic/tow roles**. | `GET /business/dashboard`, `/business/bookings`, `/business/kpis`, Reverb `centers.{id}` | snapshot cached | `fl_chart` |

### M5 — Garage & catalog → cut `v0.6.0`

| Epic | Branch | Build & key ACs | Endpoints | Offline | Adds |
|------|--------|-----------------|-----------|---------|------|
| [#50](https://github.com/YoussefSalem582/Osta-App/issues/50) My Garage | `feat/50-my-garage` | Vehicles list (single primary badge) + full CRUD (soft delete + undo snackbar); rich detail (VIN, fuel, transmission, mileage…); maintenance log + running totals + oil-due banner; **PDF export via share sheet**; reuses #39 form. | `GET/POST/PUT/DELETE /vehicles`, `POST /vehicles/{id}/primary`, `GET/POST /vehicles/{id}/maintenance` | cached reads + queued mutations (flagship §7 feature) | `dropdown_search`, `pdf`, `printing` |
| [#56](https://github.com/YoussefSalem582/Osta-App/issues/56) Business catalog & pricing | `feat/56-business-catalog` | Services CRUD (name, EGP price, `price_type` fixed/starting_from/hourly, duration, active toggle — deactivate ≠ delete); promotions CRUD (discount, window, target); customer profile shows **active services + live promotions only**; price_type labels correct on both surfaces. | `GET/POST/PUT/DELETE /business/services`, `/business/promotions` | cached reads + queued edits | `flutter_form_builder`, `form_builder_validators` |

### Shop, Home & Notifications → cut `v0.7.0`

| Epic | Branch | Build & key ACs | Endpoints | Offline | Adds |
|------|--------|-----------------|-----------|---------|------|
| [#48](https://github.com/YoussefSalem582/Osta-App/issues/48) Shop browse + detail | `feat/48-shop-browse` | Two-sided marketplace — **no cart, no checkout**; browse grid (search + chips + infinite scroll) → detail (carousel, EGP, seller card) → **Enquire**; polymorphic seller catalogs (User OR ServiceCenter); own-listings CRUD. | `GET /products`, `/products/{id}`, `/centers/{id}/products`, `/users/{id}/products`, `POST /products/{id}/enquiries`, `GET/POST/PATCH/DELETE /me/products` | cached reads; enquiries online-only | `carousel_slider`, `flutter_staggered_grid_view`, `share_plus`, `url_launcher` |
| [#57](https://github.com/YoussefSalem582/Osta-App/issues/57) Business shop mgmt | `feat/57-business-shop` | Products tab in provider shell: CRUD, multi-image upload/reorder, deactivate (`is_active=false`, keeps record) vs delete (confirm); instant reflection in public browse + center profile. | `GET/POST/PUT/PATCH/DELETE /me/products` (+ images) | cached reads + queued edits | `image_picker`, `image_cropper`, `flutter_form_builder`, `form_builder_validators` |
| [#51](https://github.com/YoussefSalem582/Osta-App/issues/51) Home dashboard | `feat/51-home-dashboard` | Default post-login landing; **map demoted to a FAB**; sections: active-booking card (live status, deep-link), prominent Book CTA, nearby strip, shop highlights, my-cars shortcut; per-section state quartet + pull-to-refresh; **skeletonizer showcase**; golden RTL/LTR × light/dark of the full feed. | `GET /bookings?status=active`, `/service-centers/nearby`, `/products?featured=1`, `/cars` | cached reads per section | `carousel_slider` (shimmer overridden → skeletonizer) |
| [#52](https://github.com/YoussefSalem582/Osta-App/issues/52) Notifications + FCM | `feat/52-notifications-fcm` | Inbox (paginated, unread badge, optimistic mark-read); deep-link by `type`+`data.target` to booking/enquiry **on either shell**; FCM token registered on login / removed on logout; push handled foreground/background/**terminated**; one-time permission prompt + graceful off-state. | `GET /notifications`, `POST /notifications/{id}/read`, `POST /devices` | inbox cached | `firebase_core`, `firebase_messaging` (push only — **never** firebase_auth), `flutter_local_notifications` |
| [#49](https://github.com/YoussefSalem582/Osta-App/issues/49) Customer public profile (P2) | `feat/49-customer-profile` | Two tabs: My Shop (grid, `ProductFormSheet`, deactivate — no hard delete) + Reviews (aggregate average); **owner vs visitor mode** (controls only when `id == currentUser.id`). | `GET/POST /me/products`, `PATCH /me/products/{id}`, `GET /users/{id}/reviews`, `GET /users/{id}` | cached reads + queued edits | `flutter_rating_bar`, `share_plus` |

**→ `v1.0.0` = MVP complete** (everything above merged and green; fold in #46 whenever the payments backend
ships — before or after v1.0.0, whichever comes first).

### M6 + Phase 2 (⛔ backend blocked — architecture-ready only, post-1.0)

| Epic | Branch | Build & key ACs |
|------|--------|-----------------|
| [#58](https://github.com/YoussefSalem582/Osta-App/issues/58) Business More hub | `feat/58-business-more-hub` | Extract a **role-agnostic `ProviderMoreShell`**; business profile editor (trade name, hours, gallery), Team deep-link → #62 roster, capacity settings, KPI cards (`?range=`), reviews inbox (reply + report). |
| [#59](https://github.com/YoussefSalem582/Osta-App/issues/59) Solo-mechanic flow | `feat/59-solo-mechanic` | Enable the chooser tile; mechanic onboarding (skills, experience, **map-drawn mobile service area — no street address**); reuse provider shell behind `role == solo-mechanic` capability flags; public profile = Shop + Reviews (no services catalog). |
| [#60](https://github.com/YoussefSalem582/Osta-App/issues/60) Tow-truck flow | `feat/60-tow-truck` | 4th role tile; provider shell with roadside jobs queue; driver status machine `en-route→arrived→towing→completed`; GPS streaming to `tracking.{jobId}` (throttled, stops on completion); customer live "track my tow" map. Adds `flutter_background_service` (not the paid `flutter_background_geolocation`). |

Until the backend ships these roles, they stay visibly **disabled "coming soon"** — no dead code paths.

### Package policy summary

- **Global (add once, early):** `talker_flutter` · `talker_dio_logger` · `talker_bloc_logger` · `skeletonizer` ·
  `connectivity_plus` · `sqflite` (+ dev `sqflite_common_ffi`) · `animations`.
- **Per-epic (add only in the epic that needs them):** listed in the tables above.
- **Never add (override the epics):** `injectable` · `freezed` · `json_serializable` · `build_runner` ·
  `fpdart` · Riverpod/Provider · `shimmer` · `flutter_screenutil` · `firebase_auth` · `pretty_dio_logger`
  (removed) · `flutter_background_geolocation` (paid license).

---

## §15 Cross-epic patterns

Apply these everywhere; never reinvent them per feature.

- **Shared provider shell spine** — one provider shell scaffold ([#34](https://github.com/YoussefSalem582/Osta-App/issues/34) → #54 → #58) serves business today and mechanic/tow in Phase 2 via capability flags. Never fork it per role.
- **`RealtimeService` only** — all Reverb channels (`bookings.{id}`, `centers.{id}`, later `tracking.{jobId}`)
  go through the single wrapper from #47: subscribe/auth/backoff+jitter/poll-fallback/dispose. Features never
  touch sockets.
- **Optimistic UI + rollback** — one recipe (used by #45 cancel/reschedule, #54/#55 accept/reject, #50/#56/#57
  edits): apply the state change locally, fire the request, roll back + localized error snackbar on failure.
- **Two-sided polymorphic Shop** — `Product.owner` and `Review.reviewable` are `User` OR `ServiceCenter`
  (#48/#49/#57, feeds #51 highlights). No cart anywhere.
- **Two "mechanic" concepts — never conflate:** center staff mechanic = roster entry, **no login**
  (#62/#55, MVP) vs solo-mechanic = full provider **role** with login (#59, Phase 2).
- **`support_id`** — the human-friendly support reference from `/me`; surfaced on profile (#40), About (#38),
  booking confirmation (#44); include it on error screens where users might contact support.
- **Egyptian formats** — phones masked `+20`; money exclusively through `EgpFormatter` (Arabic-Indic digits in
  `ar_EG`); dates/plurals via `intl` with the active locale.
- **The state quartet** (§10) + pull-to-refresh on every list/feed; empty states get a CTA, error states get
  retry.

Backend quick reference:

| Contract | Value |
|----------|-------|
| Base | `/api/v1`, host from `AppConfig` (`--dart-define BASE_URL`) |
| Envelope | success `{success, data, meta}` · error `{success:false, error:{code, message, details}}` |
| Error codes | `VALIDATION_ERROR` 422 (incl. **bad login**) · `UNAUTHENTICATED` 401 · `FORBIDDEN` 403 · `NOT_FOUND` 404 · `TOO_MANY_REQUESTS` 429 · `SERVER_ERROR` 5xx |
| Auth | Sanctum dual-token; `AuthInterceptor` refreshes once on 401 then emits `onSessionExpired` |
| Locale | `Accept-Language: ar\|en` on every request; server messages localized |
| Pagination | `meta: {current_page, last_page, per_page, total}` → `PaginationMeta` |
| Payments | Paymob **hosted checkout** (WebView); webhook is server-authoritative; idempotency keys |
| Realtime | Laravel Reverb (Pusher protocol); private channels via `POST /broadcasting/auth` |
| Push | FCM; device tokens via `POST /devices` |

---

## §16 Definition of Done — every epic PR

- [ ] Compiles; `dart format .`, `flutter analyze`, `flutter test` all green locally and in CI
- [ ] Clean Architecture layers respected; models hand-written `Equatable`; **no codegen**
- [ ] All new strings in **both** ARBs; `flutter gen-l10n` run; zero hardcoded user-facing text
- [ ] Verified in **light AND dark** theme
- [ ] Verified in **RTL (ar) AND LTR (en)** — directional widgets only
- [ ] Responsive at compact/medium/expanded widths; survives text scale 2.0
- [ ] State quartet on every screen: skeleton (skeletonizer) / empty / error+retry / offline
- [ ] Offline policy from §7.4 implemented for the feature's reads/writes
- [ ] Transitions/animations per §8.3 (tokens, helper, reduced-motion respected)
- [ ] Talker wired for new flows; no `print`/`debugPrint`; secrets redacted
- [ ] Design tokens only — no raw colors/spacing/radii/durations/paths
- [ ] Repeated UI promoted to `lib/shared/ui/` `App*` widgets (dartdoc + widget test)
- [ ] DI registered manually in `configureDependencies()`
- [ ] Tests: bloc + repository units, page widget tests, goldens (light/dark × RTL/LTR), DB tests where local data is touched
- [ ] Dartdoc on all new public APIs
- [ ] Mandatory four docs updated (§12)
- [ ] Branch `feat/<issue>-<slug>`; small layered Conventional Commits; bilingual PR linking the epic; **no AI attribution**

---

## §17 Appendix

**Approved commands** (no approval prompt needed): `flutter pub get` · `flutter gen-l10n` · `flutter analyze` ·
`flutter test` · `dart format .` — there is **no `build_runner`** in this project.
Run the app: `flutter run --dart-define=BASE_URL=https://api.osta.dev/api/v1`.

**Where to look:** doc index [`osta_readme_files/INDEX.md`](osta_readme_files/INDEX.md) · pitfalls
[`COMMON_PITFALLS.md`](osta_readme_files/reference/COMMON_PITFALLS.md) · incident recipes
[`TROUBLESHOOTING.md`](osta_readme_files/reference/TROUBLESHOOTING.md) · terms
[`GLOSSARY.md`](osta_readme_files/reference/GLOSSARY.md) · design mockups: `design-assets` branch
(`mockups/*.png`, embedded in each epic).

**Precedence in one line:** backend contract → `AGENTS.md`/ROADMAP/ADRs → **this plan** (4 amendments +
execution order) → feature docs → epic bodies (ignore their stale package stanza).

**Follow-up owed (not part of this document's delivery):** sync `AGENTS.md` itself with the four amendments
(talker, skeletonizer, offline-first, releases/tags) in a small `docs/` branch so the canon converges.
