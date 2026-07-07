> [INDEX](../INDEX.md) > [Features](README.md) > Role Selection & Routing

# 🚦 First-Run Role Split, Role Chooser & Role-Aware Shells / تقسيم الأدوار عند التشغيل الأول واختيار الدور والتوجيه حسب الدور

## Overview / نظرة عامة

OSTA ships ONE Flutter app that hosts every role flow. On first run the app splits users into a role: a splash screen reads the persisted `{token, activeRole}` pair and either routes straight into the right shell or shows a role chooser — exactly once. The chooser presents 4 role cards (CUSTOMER and BUSINESS active; SOLO-MECHANIC and TOW-TRUCK disabled as "coming soon", Phase 2), with no guest mode. The chosen `activeRole` is persisted and sent to the backend as `account_type` on register/login. After login, a `go_router` top-level redirect keyed on `me.type` places the user in `ConsumerShell` (`/home`) or `ProviderShell` (`/dashboard`); landing in the wrong shell auto-corrects with a toast, and a 401 clears tokens and returns to Login. Today only the splash page and the role selection page are implemented — everything else in this doc is planned, specified by epics [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32), [app #33](https://github.com/YoussefSalem582/Osta-App/issues/33), and [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34).

> ‏يُشحن تطبيق أُسطى كتطبيق Flutter واحد يستضيف جميع مسارات الأدوار. عند التشغيل الأول يقسّم التطبيق المستخدمين حسب الدور: تقرأ شاشة البداية الزوج المحفوظ `{token, activeRole}` وإما توجّه المستخدم مباشرة إلى الهيكل الصحيح أو تعرض شاشة اختيار الدور — مرة واحدة فقط. تعرض الشاشة 4 بطاقات أدوار (العميل ومركز الخدمة مفعّلان؛ الميكانيكي المستقل وسائق الونش معطّلان بعلامة "قريبًا"، المرحلة الثانية)، بدون وضع الضيف. يُحفظ الدور المختار `activeRole` ويُرسل إلى الخادم كـ `account_type` عند التسجيل أو الدخول. بعد تسجيل الدخول، يوجّه `go_router` المستخدم بناءً على `me.type` إلى `ConsumerShell` (‏`/home`) أو `ProviderShell` (‏`/dashboard`)؛ والوصول إلى الهيكل الخاطئ يُصحَّح تلقائيًا مع رسالة منبثقة، ويؤدي خطأ 401 إلى مسح الرموز والعودة إلى تسجيل الدخول. حاليًا لم تُنفَّذ سوى شاشة البداية وشاشة اختيار الدور — وكل ما عدا ذلك في هذا المستند مخطَّط، ومحدَّد في الإصدارات ‎#32 و‎#33 و‎#34.

## Status & Issues / الحالة والقضايا

The table below tracks the epics and their backend readiness.

> ‏يتتبّع الجدول التالي الإصدارات (epics) وجاهزية الخادم المقابلة لها.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32) | First-run flow & role split (4-role) — canonical | Open | M1 | p0 | youssef | [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) — **ready** (closed) |
| [app #33](https://github.com/YoussefSalem582/Osta-App/issues/33) | Role chooser screen | Open | M1 | p0 | haidy | [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) — **ready** (closed) |
| [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34) | Role-aware routing & shells | Open | M1 | p0 | youssef | [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40), [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) (`GET /me`), [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37) (logout) — all **ready** (closed) |

Backend epic [#40](https://github.com/YoussefSalem582/osta_backend/issues/40) delivers role-bound register/login (`account_type ∈ {customer, business}`, business register atomically provisions a LIVE ServiceCenter, phone/email unique per account_type) — so nothing on this feature is backend-blocked.

> ‏يوفّر إصدار الخادم [#40](https://github.com/YoussefSalem582/osta_backend/issues/40) تسجيلًا ودخولًا مرتبطين بالدور (`account_type ∈ {customer, business}`، وتسجيل مركز الخدمة يُنشئ ServiceCenter مباشرًا بشكل ذرّي، مع تفرّد الهاتف والبريد لكل نوع حساب) — لذا لا شيء في هذه الميزة محجوب بانتظار الخادم.

## Screens / Mockups / الشاشات والتصاميم

### First-run flow & role routing — part 1 ([app #32](https://github.com/YoussefSalem582/Osta-App/issues/32))

![First-run flow and role routing 1](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/40-first-run-flow-and-role-routing-1.png)

### First-run flow & role routing — part 2 ([app #32](https://github.com/YoussefSalem582/Osta-App/issues/32))

![First-run flow and role routing 2](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/41-first-run-flow-and-role-routing-2.png)

### Role chooser ([app #33](https://github.com/YoussefSalem582/Osta-App/issues/33))

![Role selection](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/02-role-selection.png)

### Role-based navigation & shells ([app #34](https://github.com/YoussefSalem582/Osta-App/issues/34))

![Routing and role-based navigation](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/42-routing-and-role-based-navigation.png)

## Planned architecture / البنية المخطَّطة

### What exists today (main @ 160f4dd) / ما هو موجود اليوم

`/splash` and `/role` are the **only** implemented feature pages in the app:

> ‏`/splash` و`/role` هما صفحتا الميزة الوحيدتان المنفَّذتان في التطبيق:

- `lib/features/splash/presentation/splash_page.dart` — 2-second branded intro, then navigates to role selection.
- `lib/features/role/presentation/role_selection_page.dart` — role picker (customer vs business).
- `lib/core/router/app_router.dart` — `GoRouter` with `initialLocation: SplashPage.path`; routes `/splash` and `/role`. Route paths are `static const path` fields on the page widgets (no `RouteNames` class). No redirect logic, no shells yet. `AppRouter` is registered **by hand** as a lazy singleton in `configureDependencies()` (`lib/core/di/injection.dart`) via `get_it` — no annotations, no codegen.

> ‏يُسجَّل `AppRouter` يدويًا كـ lazy singleton داخل `configureDependencies()` في ‏`lib/core/di/injection.dart` عبر `get_it` — بدون تعليقات توضيحية وبدون توليد كود.

The `role` feature folder is presentation-only (no `data/` or `domain/` layers), and the `customer/` and `business/` feature folders are empty stub directories. Everything below is **planned**, not built.

> ‏مجلد ميزة `role` يحتوي على طبقة العرض فقط (بلا طبقتَي `data/` أو `domain/`)، ومجلدا `customer/` و`business/` مجرد أدلّة فارغة. كل ما يلي **مخطَّط** وليس مبنيًا بعد.

### Planned flow (epics #32/#33/#34) / التدفّق المخطَّط

The steps below trace the intended first-run journey end to end.

> ‏تتتبّع الخطوات التالية رحلة التشغيل الأول المقصودة من بدايتها إلى نهايتها.

1. **Splash** reads persisted `{token, activeRole}`. Epic [#37](https://github.com/YoussefSalem582/Osta-App/issues/37) extends this to silently refresh the session and call `GET /me` to route.
2. **Role chooser shown once** (first run only, per [#32](https://github.com/YoussefSalem582/Osta-App/issues/32)): 4 role cards — 2 active (customer, business), 2 disabled with "coming soon" (solo-mechanic, tow-truck; both Phase 2). No guest mode.
3. **Persistence**: `activeRole` goes to `flutter_secure_storage` (per [#33](https://github.com/YoussefSalem582/Osta-App/issues/33)); first-run flags use `shared_preferences` (per [#32](https://github.com/YoussefSalem582/Osta-App/issues/32)). Tokens already live in `core/auth/token_storage.dart` (`access_token`/`refresh_token`).
4. **`account_type`**: the persisted `activeRole` is sent as `account_type` on `POST /auth/register` and `POST /auth/login` (and on social exchange, per epic [#36](https://github.com/YoussefSalem582/Osta-App/issues/36)).
5. **Role-aware routing** ([#34](https://github.com/YoussefSalem582/Osta-App/issues/34)): a `go_router` **top-level redirect** keyed on `me.type` — `customer` → `ConsumerShell` at `/home`, `business` → `ProviderShell` at `/dashboard`. Each shell is a `StatefulShellRoute` (the provider shell absorbs the future solo-mechanic/tow-truck roles). Opening the wrong shell auto-corrects with a toast ([#32](https://github.com/YoussefSalem582/Osta-App/issues/32)).
6. **Session expiry**: 401 ⇒ clear tokens → Login. The plumbing hook already exists: `core/network/auth_events.dart` broadcasts an `onSessionExpired` stream fired by `AuthInterceptor` when the refresh-retry-once fails; the router redirect will listen to it.

### State management & data flow (planned) / إدارة الحالة وتدفّق البيانات

- **Bloc/Cubit**: `flutter_bloc` per project convention; the exact cubit names for role/session state are TBD — see epics [#32](https://github.com/YoussefSalem582/Osta-App/issues/32)/[#34](https://github.com/YoussefSalem582/Osta-App/issues/34). Pattern reference in the codebase: `ThemeModeController` (a Cubit persisting to `shared_preferences`).
- **Data flow**: presentation cubit → (planned) repository in the feature's `data/` layer → `ApiClient` in `lib/core/network/` — envelope-aware `{success, data, meta?}`, returning `ApiResult<T>` or throwing typed `ApiException`s (`UnauthenticatedException` on 401, `ValidationException` on 422, …). The repository catches those `ApiException`s and rethrows a `sealed Failure` (`core/error/failure.dart`); the cubit wraps the call in a plain `try`/`catch` — no `Either`, no `.fold()`, no `Result<T>`.
- **DI**: register the cubits/repositories with `get_it` by **hand-writing a `registerLazySingleton` line** in `configureDependencies()` (`lib/core/di/injection.dart`), exactly like the existing `AppConfig`/`Dio`/`ApiClient`/`TokenStorage`/`AuthEvents`/`AppRouter` registrations. No `injectable`, no `build_runner`.

> ‏تدفّق البيانات: كيوبت العرض ← مستودع (مخطَّط) في طبقة `data/` الخاصة بالميزة ← `ApiClient` في `lib/core/network/` — يفهم المغلّف `{success, data, meta?}` ويُرجع `ApiResult<T>` أو يرمي `ApiException`s المصنَّفة. يلتقط المستودع تلك الاستثناءات ويعيد رمي `sealed Failure`؛ ويلفّ الكيوبت الاستدعاء في `try`/`catch` بسيط — بلا `Either` وبلا `.fold()` وبلا `Result<T>`. أما الحقن (DI) فيتم بكتابة سطر `registerLazySingleton` يدويًا في `configureDependencies()`، بلا `injectable` وبلا `build_runner`. تفاصيل خطة إعادة إدخال الأدوات المتقدّمة مؤجَّلة وموثّقة في [docs/ROADMAP.md](../../docs/ROADMAP.md).

## API endpoints / نقاط نهاية الـ API

Base URL `/api/v1`, response envelope `{success, data, meta?}`. Status legend: **Connected** = already called from `lib/core/network`; **Planned** = epic open, not yet wired.

> ‏عنوان الأساس `/api/v1`، والمغلّف `{success, data, meta?}`. دليل الحالة: **Connected** يعني مُستدعى فعلًا من `lib/core/network`، و**Planned** يعني الإصدار مفتوح ولم يُوصَل بعد.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| POST | `/auth/login` | Login carrying `account_type`; returns Sanctum dual tokens (bad credentials = 422) | [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32) / [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) | **Connected** |
| POST | `/auth/register` | Register with `account_type ∈ {customer, business}`; business register provisions a LIVE ServiceCenter | [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32) / [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) | Planned |
| GET | `/me` | Read the authenticated user (incl. `type`) to drive the shell redirect | [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32), [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34) / [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| POST | `/auth/logout` | End session; app clears tokens and returns to Login | [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34) / [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37) | Planned |

## Packages & shared widgets / الحزم والودجات المشتركة

**No new packages required** — every dependency these epics name is already in `pubspec.yaml`:

> ‏لا حاجة لأي حزم جديدة — كل اعتماد تذكره هذه الإصدارات موجود بالفعل في `pubspec.yaml`:

| Package | Use here |
|---|---|
| `go_router` 17 | Global redirect + `StatefulShellRoute` shells ([#32](https://github.com/YoussefSalem582/Osta-App/issues/32)/[#34](https://github.com/YoussefSalem582/Osta-App/issues/34)) |
| `shared_preferences` | First-run / role-chooser-seen flags ([#32](https://github.com/YoussefSalem582/Osta-App/issues/32)) |
| `flutter_secure_storage` | Persist `activeRole` ([#33](https://github.com/YoussefSalem582/Osta-App/issues/33)); tokens via existing `TokenStorage` |
| `flutter_bloc` / `get_it` | Cubits + manual DI registration, per project convention |

**Existing `lib/shared/ui/` components to reuse** (do not rebuild):

> ‏مكوّنات `lib/shared/ui/` الموجودة التي يجب إعادة استخدامها (لا تُعِد بناءها):

- `AppCard` + `AppButton` — the 4 role cards and their CTAs (disabled variant for the two "coming soon" roles).
- `AppTopBar` (RTL-safe) and `AppBottomNavBar`/`AppBottomNavItem` (with badges) — the tab scaffolding of `ConsumerShell` and `ProviderShell`.
- `LoadingState` / `ErrorState` (`status_states.dart`) — splash session-restore and `GET /me` failure states.
- `context.l10n` (`shared/extensions/context_ext.dart`) — the ARB set already contains `chooseRole`, `roleCustomer`, `roleBusiness`, and `retry`.
- `AppImages` (`core/constants/app_images.dart`) — logo / fullLogo / mascot for the splash screen.

## Testing expectations / توقّعات الاختبار

- **Golden tests** ([app #33](https://github.com/YoussefSalem582/Osta-App/issues/33)): role chooser in RTL + dark/light, following the design-system pattern from epic #29 (light/dark × RTL/LTR).
- **Widget/unit tests** for the redirect and first-run logic (#32/#34): not enumerated in the epic digests — TBD, see [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32) and [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34).
- **Existing coverage to build on**: `test/widget_test.dart` (app smoke test through `/splash`), `test/shared/ui/navigation_test.dart` (5 cases on `AppTopBar`/`AppBottomNavBar`), and the fakes in `test/core/network/fakes.dart` (`FakeDio`, `FakeTokenStorage`) for exercising the 401 → clear-tokens path.

> ‏تُبنى الاختبارات الجديدة على التغطية الموجودة: اختبار الدخان في `test/widget_test.dart`، وحالات التنقّل في `test/shared/ui/navigation_test.dart`، والفيكات في `test/core/network/fakes.dart` لتجربة مسار 401 ← مسح الرموز. الاختبارات تعتمد `flutter_test` و`http_mock_adapter` وفيكات مكتوبة يدويًا — بلا mockito أو mocktail.

## Related docs / مستندات ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md) — full endpoint catalogue and status legend.
- [Delivery plan](../reference/DELIVERY_PLAN.md) — where M1 role epics sit in the milestone sequence.
- [Features index](README.md) — sibling feature docs (auth, splash & onboarding, home dashboard, and the rest of M1).
- [Tooling roadmap](../../docs/ROADMAP.md) — the phased plan for reintroducing deferred tooling (codegen, functional errors, flavors, CI matrix).
