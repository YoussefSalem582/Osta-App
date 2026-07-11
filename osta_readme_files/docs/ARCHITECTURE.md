# Architecture / المعمارية

OSTA follows **Clean Architecture + BLoC**, one module per feature, with a hard dependency rule: **no layer imports from a layer above it.** The codebase is deliberately **plain Dart — no codegen** (models, DI, and errors are hand-written); advanced tooling is deferred, see [`docs/ROADMAP.md`](../../docs/ROADMAP.md).

> ‏يتبع OSTA نمط **Clean Architecture + BLoC**، وحدة لكل ميزة، بقاعدة اعتماد صارمة: **لا طبقة تستورد من طبقة أعلى منها.** الشيفرة **Dart بسيطة بلا توليد كود** (النماذج والحقن والأخطاء مكتوبة يدويًا)؛ والأدوات المتقدّمة مؤجّلة — راجع [`docs/ROADMAP.md`](../../docs/ROADMAP.md).

## Layers / الطبقات

```text
┌──────────────────────────────────────────────────────────┐
│ Presentation   pages / widgets / bloc (or cubit)          │
│    depends on ↓                                            │
├──────────────────────────────────────────────────────────┤
│ Domain         entities / repository contracts / usecases │  ← pure Dart
│    depends on ↓ (contracts only)                          │
├──────────────────────────────────────────────────────────┤
│ Data           models / datasources / repository impls    │
└──────────────────────────────────────────────────────────┘
```

- **Domain** is pure Dart (no Flutter imports): `entities/` (extend `Equatable`), `repositories/` (abstract contracts), `usecases/` (one class per operation).
- **Data**: `models/` (plain `Equatable` classes with hand-written `fromJson`/`toJson`), `datasources/` (call `ApiClient`), `repositories/` (implementations mapping `ApiException` → `Failure`).
- **Presentation**: `bloc/`, `pages/`, `widgets/` (feature-specific only).

> ‏**النطاق (Domain)** دارت خالص بلا استيراد Flutter؛ **البيانات (Data)** نماذج `Equatable` بدوالّ `fromJson`/`toJson` يدوية ومصادر بيانات تنادي `ApiClient` ومستودعات تحوّل `ApiException` إلى `Failure`؛ **العرض (Presentation)** الـ blocs والصفحات والودجات الخاصة بالميزة.

## Data flow / تدفّق البيانات

```text
UI (Page)
  → adds Event to BLoC
    → BLoC calls UseCase                (inside try/catch)
      → UseCase calls Repository (contract)
        → Repository calls RemoteDataSource → ApiClient
      ← returns the entity, OR throws a Failure
    ← BLoC emits State  (Loaded on success / Error on caught Failure)
  ← UI renders: Loading → LoadingState, Loaded → content, Error → ErrorState
```

Errors are **thrown, not returned**. There is no `Either`/`Result<T>`/`.fold()` (fpdart deferred — [`docs/ROADMAP.md`](../../docs/ROADMAP.md) Phase 5). The network layer throws typed `ApiException`s (`core/network/api_exception.dart`); repositories catch those and throw a matching **sealed `Failure`** (`core/error/failure.dart`: `NetworkFailure`, `ServerFailure`, `UnknownFailure`); the bloc uses plain `try`/`catch` and emits an error state carrying `failure.message`.

> ‏الأخطاء **تُرمى ولا تُرجَّع**. لا يوجد `Either`/`Result<T>`/`.fold()` (الـ fpdart مؤجّل). الطبقة الشبكية ترمي `ApiException` بأنواعها، والمستودع يلتقطها ويرمي `Failure` مغلقًا مناسبًا، والـ bloc يلتقطه بـ `try`/`catch` ويُصدر حالة خطأ تحمل `failure.message`.

## Networking / الشبكة

Every HTTP call goes through `ApiClient` (`core/network/api_client.dart`), which parses the backend envelope `{success, data, meta}` / `{success:false, error:{code,message,details}}` into a typed `ApiResult<T>` (data + optional `PaginationMeta`) or throws a typed `ApiException` (`ValidationException` 422 + `fieldErrors`, `Unauthenticated` 401, `Forbidden` 403, `NotFound` 404, `RateLimit` 429, `Server` 5xx, `Network`). Dio is configured in `dio_client.dart` with three interceptors: `AuthInterceptor` (attaches the Sanctum bearer, single 401 refresh-retry via a `QueuedInterceptor`), `dio_smart_retry`, and a redacted `pretty_dio_logger`. A failed refresh emits on `AuthEvents.onSessionExpired` → route to login. `SocialTokenExchange` handles Google/Apple. Tokens live in `TokenStorage` (`flutter_secure_storage`), never `SharedPreferences`.

> ‏كل نداء HTTP يمرّ عبر `ApiClient` الذي يفكّ المغلّف إلى `ApiResult<T>` أو يرمي `ApiException`. الـ Dio مُهيّأ بثلاثة اعتراضات: `AuthInterceptor` (توكن Sanctum + تجديد 401 مرة واحدة)، وإعادة المحاولة، ومسجّل مُعتَّم. عند فشل التجديد يُطلَق `AuthEvents.onSessionExpired`. التوكِنات في `TokenStorage` وليس `SharedPreferences`.

## Dependency injection / حقن الاعتماديات

`get_it`, registered **by hand** in `configureDependencies()` (`core/di/injection.dart`) — no `injectable`, no `build_runner`. `SharedPreferences` is a `registerSingleton` resolved up front; everything else (`AppConfig`, `TokenStorage`, `Dio`, `ApiClient`, `SocialTokenExchange`, `ThemeModeController`, `AppRouter`) is a `registerLazySingleton`. Feature BLoCs are registered as factories; a new service adds one hand-written line.

> ‏`get_it` مسجَّل **يدويًا** في `configureDependencies()` — بلا `injectable` وبلا `build_runner`. كل خدمة جديدة تضيف سطرًا واحدًا مكتوبًا باليد.

## Configuration / الإعدادات

`AppConfig` (`core/config/app_config.dart`) holds a single `baseUrl` from the `BASE_URL` dart-define (default `https://osta.technology92.com/api/v1`). No `.env`, **no build flavors** (multi-flavor deferred — [`docs/ROADMAP.md`](../../docs/ROADMAP.md) Phase 4).

## Routing / التوجيه

`go_router` (`core/router/app_router.dart`). Today: `/splash → /role`; `initialLocation` is `SplashPage.path`, and each page exposes a `static const path`. The planned model ([app #32](https://github.com/YoussefSalem582/Osta-App/issues/32)/[#34](https://github.com/YoussefSalem582/Osta-App/issues/34)) adds a top-level `redirect` on `activeRole`/`me.type` into a Consumer shell (`/home`) or Provider shell (`/dashboard`) via `StatefulShellRoute`.

## Theming, localization / الثيم والترجمة

- All colours/spacing/radii/typography live in `core/theme/` (`AppColors` `ThemeExtension`, `AppSpacing`/`AppRadii`/`AppElevation` in `app_tokens.dart`, Cairo variable font in `AppTypography`). Resolve via `context.appColors` / `Theme.of(context)`. No hardcoded values.
- English + Arabic via ARB (`lib/l10n/app_en.arb` template + `app_ar.arb`) + `flutter gen-l10n` → `lib/core/l10n/` (`AppLocalizations`, `context.l10n`). **Arabic is default; RTL-first** (`EdgeInsetsDirectional`, `start`/`end`). Money/numbers via `EgpFormatter`/`NumberFormatter` (Arabic-Indic digits under `ar_EG`). l10n is the **only** generated code.

> ‏كل الألوان والمسافات والزوايا والخطوط في `core/theme/`؛ تُستدعى عبر `context.appColors` / `Theme.of(context)` بلا قيم ثابتة. الترجمة عربي + إنجليزي عبر ARB و`flutter gen-l10n`، والعربية افتراضية وRTL أولًا. الترجمة هي الكود المولَّد الوحيد.

## Adding a new feature module / إضافة وحدة ميزة جديدة

1. Create `lib/features/<feature>/{data,domain,presentation}` (customer/business areas are nested).
2. **Domain:** entities (`Equatable`), a repository contract, use cases.
3. **Data:** models (`Equatable` + hand-written `fromJson`/`toJson`), a remote data source over `ApiClient`, a repository impl mapping `ApiException` → `Failure` (throws on failure).
4. **Presentation:** BLoC (`<feature>_bloc.dart` / `_event.dart` / `_state.dart`) + pages/widgets composed from `lib/shared/ui/`. Wire `Loading → LoadingState`, `Loaded → content`, `Error → ErrorState`.
5. Register DI in `configureDependencies()` (BLoC as factory, the rest as lazy singletons) — by hand.
6. Add the route in `core/router/app_router.dart`.
7. Add ARB strings (en + ar) and run `flutter gen-l10n`.
8. Tests: repository + BLoC (with `http_mock_adapter` / fakes), key widgets/goldens.
9. Ship on `feat/<issue>-<slug>` branched off `develop` (hand-written name — never a tool-generated one like `claude/...`), **PR base `develop`**, bilingual description. A finished version/milestone reaches `main` via a `develop → main` release PR (then tag `v0.<n>.0`, `v1.0.0` = MVP).

Full step-by-step: [`osta_readme_files/guides/03_how_to_add_new_feature.md`](../guides/03_how_to_add_new_feature.md).

## Reference module / الوحدة المرجعية

Once it lands, **auth** ([app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)) is the canonical example of the layering — until then follow the guide above. Today the only implemented feature pages are `splash` and `role`; the rest of `lib/features/` is stub folders specified by open GitHub epics (see [`osta_readme_files/reference/DELIVERY_PLAN.md`](../reference/DELIVERY_PLAN.md)).

## See also / انظر أيضًا

- Canonical conventions: [`AGENTS.md`](../../AGENTS.md)
- Deferred tooling & phased plan: [`docs/ROADMAP.md`](../../docs/ROADMAP.md)
- Full architecture guide with diagrams: [`osta_readme_files/guides/02_architecture.md`](../guides/02_architecture.md)
- Decision records: [`osta_readme_files/decisions/`](../decisions/README.md)
