> [INDEX](../INDEX.md) > [Features](README.md) > Splash, language select & onboarding

# 🚀 Splash, Language Select & Onboarding / شاشة البداية واختيار اللغة والتعريف بالتطبيق

## Overview / نظرة عامة

The first-run experience of the OSTA app: a branded splash screen, a language picker (Arabic default), and a 3-slide onboarding carousel that is shown on first launch only. Beyond branding, the splash screen does real work — it silently refreshes the Sanctum session and calls `GET /me` so a returning user is routed straight into the correct role shell (customer or business) without re-authenticating, per the first-run flow rules of epic [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32). The `onboarding_seen` flag and the chosen locale are persisted so neither screen appears twice. Today only a stub exists in code: `lib/features/splash/presentation/splash_page.dart` shows a 2-second intro and then navigates to role selection — everything else in this doc is planned, specified by epic [app #37](https://github.com/YoussefSalem582/Osta-App/issues/37).

> ‏تجربة التشغيل الأول لتطبيق أُسطى: شاشة بداية تحمل هوية العلامة، واختيار اللغة (العربية هي الافتراضية)، وشرائح تعريفية ثلاث تظهر عند أول تشغيل فقط. وبجانب العرض البصري، تقوم شاشة البداية بعمل حقيقي — فهي تجدّد جلسة Sanctum تلقائيًا وتستدعي `GET /me` لتوجيه المستخدم العائد مباشرة إلى الواجهة المناسبة لدوره (عميل أو مركز خدمة) دون تسجيل دخول جديد. ويتم حفظ علامة `onboarding_seen` واللغة المختارة حتى لا تظهر أيٌّ من الشاشتين مرة أخرى. الموجود حاليًا في الكود مجرد شاشة مبدئية بسيطة تعرض مقدمة لمدة ثانيتين ثم تنتقل إلى اختيار الدور، وكل ما عدا ذلك مخطَّط ضمن المهمة رقم ٣٧.

## Status & Issues / الحالة والمهام

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #37](https://github.com/YoussefSalem582/Osta-App/issues/37) | Splash, language select & onboarding (customer) | Open | M1 | p1 | adel | [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37) (auth/refresh, closed) + [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) (`GET /me`, closed) — **ready** |
| [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32) | First-run flow & role split (4-role) — canonical (splash session-refresh routing) | Open | M1 | p0 | youssef | [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) (role-bound register/login, closed) — **ready** |

Related but tracked separately: runtime language switching and the `Accept-Language` interceptor belong to epic [app #30](https://github.com/YoussefSalem582/Osta-App/issues/30) (Localization & RTL, open); the splash language picker only persists the initial choice.

> ‏مُتابَعة بشكل منفصل: تبديل اللغة أثناء التشغيل ومُعترِض `Accept-Language` يتبعان المهمة رقم ٣٠ (التعريب ودعم الاتجاه من اليمين لليسار، مفتوحة)؛ أما مُنتقي اللغة في شاشة البداية فيحفظ الاختيار المبدئي فقط.

## Screens / Mockups / الشاشات والتصاميم

### Splash / شاشة البداية
![Splash](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/01-splash.png)

### Onboarding carousel / شرائح التعريف
![Onboarding](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/05-onboarding-nearest-center.png)

### First-run flow & session-refresh routing (from epic #32) / تدفّق التشغيل الأول وتوجيه تجديد الجلسة
![First-run flow 1](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/40-first-run-flow-and-role-routing-1.png)
![First-run flow 2](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/41-first-run-flow-and-role-routing-2.png)

### Language selection / اختيار اللغة
No dedicated mockup in epic #37; the localization epic's mockup covers language UI:

> ‏لا يوجد تصميم مخصّص في المهمة رقم ٣٧؛ تصميم مهمة التعريب يغطي واجهة اللغة:

![Localization & RTL](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/38-localization-and-rtl.png)

## Planned architecture / البنية المخطَّطة

**Current state**: `lib/features/splash/` is a stub — a single `presentation/splash_page.dart` that waits 2 seconds and pushes `/role`. No data or domain layer, no cubit. Everything below is planned, not built.

> ‏الحالة الحالية: مجلد `lib/features/splash/` عبارة عن شاشة مبدئية — ملف واحد `presentation/splash_page.dart` ينتظر ثانيتين ثم ينتقل إلى `/role`. لا توجد طبقة بيانات أو نطاق، ولا يوجد Cubit. وكل ما يلي مخطَّط وليس منجزًا بعد.

- **State management** — Bloc/Cubit per repo convention (`flutter_bloc` 9). A splash-startup cubit (name TBD — see epic #37) drives the boot sequence; onboarding page state uses a lightweight cubit or plain `PageController` with `smooth_page_indicator`. Registered by **hand** in `configureDependencies()` (`lib/core/di/injection.dart`) with a `getIt.registerLazySingleton` line, exactly like the existing `ThemeModeController` — no `injectable`, no `build_runner`, no codegen. See [ROADMAP.md](../../docs/ROADMAP.md) for the deferred DI-codegen plan.
- **Boot sequence (splash)** —
  1. Read persisted state: tokens via `TokenStorage` (`flutter_secure_storage`), `activeRole` (secure storage per epic [app #33](https://github.com/YoussefSalem582/Osta-App/issues/33)), and `onboarding_seen` + `locale` flags (`shared_preferences`).
  2. No token → first-launch path: language picker (AR default) → 3-slide onboarding (first launch only) → role chooser → auth.
  3. Token present → silently refresh the session and call `GET /me` through the shared `ApiClient` (`lib/core/network/`); the `AuthInterceptor` already handles the 401 refresh-retry-once dance. Route by `me.type`: customer → customer shell, business → business shell (shells themselves are epic [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)).
  4. Refresh fails / session expired → clear tokens and land on the login flow (see `AuthEvents.onSessionExpired`).
- **Routing** — `go_router` global redirect (epic #32): splash is the initial route today (`/splash` in `core/router/app_router.dart`); the redirect will consult `{token, activeRole, onboarding_seen}` so the role chooser and onboarding are shown exactly once.
- **Persistence** — `onboarding_seen` and `locale` in `shared_preferences` (keys TBD — see epic #37), tokens in `flutter_secure_storage`.
- **Data flow** — presentation → cubit → `ApiClient` (envelope-aware). The cubit wraps the call in plain `try`/`catch`: the network layer throws typed `ApiException`s, which the cubit catches and converts to a `sealed Failure` (`lib/core/error/failure.dart`) for the UI — no `Either`, no `.fold()`, no `Result<T>`. This feature is thin enough that a dedicated repository/use-case layer is TBD — see epic #37.

The startup cubit's boot logic is a straightforward `try`/`catch`: attempt the refresh + `GET /me`, catch a `Failure` on the sad path, and route to login. This beginner-friendly error contract (sealed `Failure`, no functional-error library) is deliberate; the `fpdart` / `Either` approach is deferred, tracked in [ROADMAP.md](../../docs/ROADMAP.md).

> ‏منطق الإقلاع في الـ Cubit هو ببساطة `try`/`catch`: يحاول تجديد الجلسة واستدعاء `GET /me`، وعند الفشل يلتقط كائن `Failure` ويوجّه المستخدم إلى تسجيل الدخول. وهذا التعامل المبسّط مع الأخطاء (`sealed Failure` بدون مكتبة أخطاء دالّية) مقصود ومناسب لفريق جديد على Flutter؛ أما أسلوب `fpdart` / `Either` فمؤجَّل ومُوثَّق في خطة الطريق.

## API endpoints / نقاط نهاية الـ API

The two endpoints below are consumed during the splash boot sequence; language and onboarding are purely local.

> ‏نقطتا النهاية التاليتان تُستخدَمان أثناء تسلسل إقلاع شاشة البداية؛ أما اللغة والتعريف فمحليّان بالكامل.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| POST | `/auth/refresh` | Silent session refresh during splash | [app #37](https://github.com/YoussefSalem582/Osta-App/issues/37) / [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37) | **Connected** (called by `AuthInterceptor` in `lib/core/network`) |
| GET | `/me` | Fetch user `type` to pick the role shell | [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32) / [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned (backend merged) |

Language selection and the onboarding carousel are purely local — no endpoints.

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages (from epic #37, not yet in `pubspec.yaml`)**

> ‏حزم مخطَّطة (من المهمة رقم ٣٧، لم تُضَف بعد إلى `pubspec.yaml`):

- `smooth_page_indicator` — dots for the 3-slide onboarding carousel.

**Already available and to be reused**

> ‏متاحة بالفعل وستُعاد الاستفادة منها:

- `shared_preferences` — `onboarding_seen` + `locale` flags (same pattern as `ThemeModeController`'s `theme_mode` key).
- `flutter_secure_storage` via `TokenStorage` (`core/auth/token_storage.dart`) — token pair read at boot.
- `go_router` (`core/router/app_router.dart`) — redirect logic.
- `AppImages` (`core/constants/app_images.dart`: `logo`, `fullLogo`, `mascot`) — branded splash artwork.
- `AppButton`, `AppTypography` (Cairo), `AppColors`/`AppTheme` tokens — onboarding slides and language picker UI.
- `context.l10n` (`shared/extensions/context_ext.dart`) — all strings from ARB, zero hardcoded text (epic #30 rule).

The models this feature touches (e.g. the `me` payload) are plain `Equatable` classes with hand-written `fromJson`/`toJson` — see `lib/features/auth/data/models/auth_token_model.dart` for the pattern. No `@freezed`, no `@JsonSerializable`, no `part '*.g.dart'`; codegen for models is deferred per [ROADMAP.md](../../docs/ROADMAP.md).

> ‏النماذج التي تلمسها هذه الميزة (مثل حمولة `me`) هي أصناف `Equatable` عادية مع دوال `fromJson`/`toJson` مكتوبة يدويًا — راجع `lib/features/auth/data/models/auth_token_model.dart` كنموذج. لا `@freezed` ولا `@JsonSerializable` ولا `part '*.g.dart'`؛ توليد أكواد النماذج مؤجَّل حسب خطة الطريق.

## Testing expectations / توقّعات الاختبار

Epic #37 does not enumerate a test list; repo-wide conventions apply. Tests are plain `flutter_test` with hand-written fakes — no mocking framework, no generated mocks.

> ‏لا تُحدِّد المهمة رقم ٣٧ قائمة اختبارات؛ تُطبَّق أعراف المستودع العامة. الاختبارات تعتمد على `flutter_test` مع بدائل (fakes) مكتوبة يدويًا — بلا إطار محاكاة ولا نماذج مولَّدة.

- **Unit** — startup cubit routing decisions: no token → onboarding/role path; valid token → shell route; failed refresh → login. Reuse `test/core/network/fakes.dart` (`FakeDio`, `FakeTokenStorage`).
- **Unit** — persistence of `onboarding_seen` and `locale` (mirroring `theme_mode_controller_test.dart`).
- **Widget** — first launch shows language picker + carousel; second launch skips both (flag persisted); both locales render with correct `Directionality` (epic #30 pattern).
- **Golden** — splash and onboarding slides, light/dark × RTL/LTR (pattern established by design-system epic #29).

## Related docs / روابط ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Roadmap — deferred tooling plan](../../docs/ROADMAP.md)
- [Features index](README.md)
- Sibling feature docs: role selection & routing ([app #32](https://github.com/YoussefSalem582/Osta-App/issues/32)–[#34](https://github.com/YoussefSalem582/Osta-App/issues/34)), auth ([app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)/[#36](https://github.com/YoussefSalem582/Osta-App/issues/36)) — see the [Features index](README.md) for the full list.
