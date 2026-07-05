# Glossary / المصطلحات

> [INDEX](../INDEX.md) > Glossary
>
> One-line definitions for project-specific terms. Sorted alphabetically.

One-line definitions for the project's own terms. The codebase runs on plain, readable Dart — no codegen except localization — so the entries below describe the hand-written contracts a Flutter-new team can follow. Deferred tooling is flagged and tracked in [`ROADMAP.md`](../../docs/ROADMAP.md).

> ‏تعريفات من سطر واحد لمصطلحات المشروع. الكود مكتوب بلغة Dart بسيطة وواضحة — من غير أي توليد كود ما عدا الترجمة (l10n) — فالمصطلحات تحت بتوصّف العقود المكتوبة باليد اللي يقدر فريق جديد على Flutter يمشي عليها. الأدوات المؤجّلة مُعلّمة ومتتبّعة في [`ROADMAP.md`](../../docs/ROADMAP.md).

| Term | Definition |
|------|------------|
| **activeRole** | The persisted role (customer / business) chosen in the role chooser; routes the user into the Consumer or Provider shell, verified against `me.type`. Stored in secure storage ([app #33](https://github.com/YoussefSalem582/Osta-App/issues/33)). |
| **ADR** | Architecture Decision Record — short markdown capturing *why* a choice was made. Lives in [`decisions/`](../decisions/README.md). |
| **AGENTS.md** | The canonical instruction file for AI agents/contributors. `CLAUDE.md` is a thin shim over it. |
| **ApiClient** | The Dio wrapper (`lib/core/network/api_client.dart`) that parses the ApiResponse envelope → `ApiResult<T>` or throws a typed `ApiException`. Every HTTP call goes through it. |
| **ApiException** | Sealed network-layer error (`ValidationException` 422, `Unauthenticated` 401, `Forbidden` 403, `NotFound` 404, `RateLimit` 429, `Server` 5xx, `Network`). Repositories catch it and convert/rethrow as a `Failure`. |
| **ApiResult<T>** | Success payload from `ApiClient`: data + optional `PaginationMeta`. |
| **ApiResponse envelope** | The backend response shape: `{success, data, meta}` / `{success:false, error:{code,message,details}}`. |
| **AppColors / AppTokens / AppTypography** | Design-token classes in `lib/core/theme/`. `AppColors` is a `ThemeExtension`; tokens are `AppSpacing`/`AppRadii`/`AppElevation`. Never hardcode. |
| **AppConfig** | Runtime config from `--dart-define` (`lib/core/config/app_config.dart`). Holds a single `baseUrl` read from the `BASE_URL` dart-define. No `.env`, no flavor enum. |
| **AppImages** | Asset-path constants (`lib/core/constants/app_images.dart`): `logo`, `fullLogo`, `mascot`. |
| **AuthEvents** | Broadcast stream (`onSessionExpired`) fired when a token refresh fails → route to login. |
| **AuthInterceptor** | `QueuedInterceptor` that attaches the bearer and does a single 401 refresh-retry (queued to avoid refresh storms). |
| **backend:ready / backend:blocked** | Issue labels: the backend route is merged (safe to integrate) vs not yet (scaffold/UI only). |
| **BASE_URL** | The one dart-define that configures the API base; passed on `flutter run --dart-define=BASE_URL=…` and read by `AppConfig`. Replaces the removed multi-flavor setup (multi-flavor deferred — [ROADMAP](../../docs/ROADMAP.md) Phase 4). |
| **BLoC / Cubit** | State management (`flutter_bloc`). BLoC for feature flows, Cubit for simple state (e.g. `ThemeModeController`). |
| **Cairo** | The Arabic+Latin variable font used by `AppTypography` (weights via `FontVariation`). |
| **codegen (deferred)** | Model/DI code generation (`freezed`, `json_serializable`, `injectable`, `build_runner`) is **not used**. Models are plain `Equatable` classes with hand-written `fromJson`/`toJson`; DI is registered by hand in `configureDependencies()`. Only localization is generated (`flutter gen-l10n`). Reintroduction is deferred — [ROADMAP](../../docs/ROADMAP.md) Phases 1–3. |
| **configureDependencies()** | The manual DI wiring in `lib/core/di/injection.dart`: a sequence of hand-written `getIt.registerSingleton` / `registerLazySingleton` lines (no annotations). A new service adds one line. |
| **ConsumerShell / ProviderShell** | The two role shells (planned): customer `/home` vs business `/dashboard`; the provider shell absorbs future roles. |
| **design-assets branch** | The git branch hosting `mockups/*.png` referenced by the feature docs. |
| **dual token (Sanctum)** | Access (~60 min) + refresh (30 d) token pair from the Laravel backend. |
| **EGP / EgpFormatter** | Egyptian Pound; the formatter (`shared/formatters/`) renders EGP with Arabic-Indic digits under `ar_EG`. |
| **epic** | Every tracked GitHub issue is a `type:epic`; one per feature area. |
| **Equatable** | The value-equality base class for hand-written models (`class X extends Equatable` with a `props` list). Used instead of `freezed` — see **codegen (deferred)**. |
| **Failure** | Sealed domain error (`NetworkFailure`, `ServerFailure`, `UnknownFailure`) in `lib/core/error/failure.dart`. Repositories **throw** it; callers/blocs use plain `try`/`catch`. No `Either`, no `.fold()`. |
| **Filament** | The backend's admin web UI (`/admin`); no mobile API. |
| **fpdart / Either (deferred)** | Functional error handling was considered and **deferred**. The app uses a sealed `Failure` + plain `try`/`catch` instead of `Either<Failure, T>` — [ROADMAP](../../docs/ROADMAP.md) Phase 5. |
| **get_it** | The service-locator DI. Registered **manually** in `configureDependencies()` (`lib/core/di/injection.dart`) with a global `getIt`; no `injectable`, no `build_runner`. |
| **getIt** | The global `GetIt.instance` service locator; services are resolved with `getIt()` after `configureDependencies()` runs at startup. |
| **go_router / StatefulShellRoute** | Declarative router; shells use `StatefulShellRoute` to keep bottom-nav state. Routes in `lib/core/router/app_router.dart`. |
| **hold (10-min booking hold)** | A created booking holds the slot for 10 minutes (`hold_expires_at`); a backend job releases it if unconfirmed. |
| **InstaPay** | An Egyptian instant-payment rail; one of the Paymob methods (with wallets). |
| **mechanic roster vs solo_mechanic** | A *center mechanic* is a login-less staff record on a ServiceCenter ([app #62](https://github.com/YoussefSalem582/Osta-App/issues/62)); a *solo_mechanic* is a Phase-2 authenticated provider role ([app #59](https://github.com/YoussefSalem582/Osta-App/issues/59)). Different things. |
| **milestone (M0–M7, M3.5, Shop, Home)** | Delivery buckets grouping epics. See [DELIVERY_PLAN.md](DELIVERY_PLAN.md). |
| **mockups** | Design PNGs on the `design-assets` branch, embedded by feature docs. |
| **open onboarding** | Businesses register and go live instantly — no verification/approval step. |
| **PaginationMeta** | `{currentPage, lastPage, perPage, total}` from list-response `meta`; a plain `Equatable` model with hand-written `fromJson`. |
| **Paymob** | The Egyptian payment gateway (wallets + InstaPay MVP; Apple Pay Phase 2); the app uses hosted checkout in a WebView. |
| **PostGIS** | Postgres spatial extension powering `/centers/nearby` (geography points, distance). |
| **Reverb / pusher_channels_flutter** | Laravel's WebSocket server (Pusher protocol) and the Flutter client for realtime booking/dashboard updates. |
| **RTL** | Right-to-left layout; Arabic is the default locale, so RTL is the default direction. |
| **support_id** | A per-user human-readable id (`OSTA-XXXXX`) surfaced in the app for support. |
| **ThemeModeController** | Cubit persisting the light/dark/system choice (`theme_mode` in SharedPreferences). |
| **TokenStorage** | `flutter_secure_storage` wrapper for tokens (`access_token`, `refresh_token`). Never use SharedPreferences for tokens. |
| **two-sided shop** | The Shop marketplace: customers AND businesses list products; browse + enquire only, no cart/checkout. |
| **UUID PKs** | The backend uses UUID primary keys everywhere. |
| **very_good_analysis** | The strict lint ruleset the project uses. |
