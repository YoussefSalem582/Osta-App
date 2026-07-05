> [INDEX](../INDEX.md) > [Features](README.md) > Auth

# 🔐 Auth — Email + Password & Social Login / المصادقة — البريد الإلكتروني وتسجيل الدخول الاجتماعي

## Overview / نظرة عامة

Authentication for the single OSTA app across both role shells (CUSTOMER and BUSINESS). Users register with first/last name, a unique username, email, Egyptian phone (+20), password + confirmation, an optional profile photo, and mandatory terms acceptance; login, token refresh, logout, and forgot/reset-password via email round out the email flow (epic [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)). Social login adds native Google and Apple sign-in with a server-side token exchange through Laravel Socialite — no `firebase_auth` (epic [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36)). The backend contract is Sanctum dual tokens (access ~60 min, refresh 30 d) stored in `flutter_secure_storage`; register/login carry `account_type ∈ {customer, business}` taken from the persisted active role. Bad credentials and invalid provider tokens both return 422. The core plumbing (interceptor, token storage, social exchange, token model) is already merged from epic [app #31](https://github.com/YoussefSalem582/Osta-App/issues/31); the feature UI layer is not built yet.

> ‏المصادقة لتطبيق أُسطى الواحد عبر واجهتي الأدوار (العميل ومركز الخدمة). يسجّل المستخدم بالاسم الأول والأخير واسم مستخدم فريد والبريد الإلكتروني ورقم هاتف مصري (+20) وكلمة مرور مع تأكيدها وصورة شخصية اختيارية وقبول إلزامي للشروط؛ ويكتمل مسار البريد بتسجيل الدخول وتجديد الرمز وتسجيل الخروج واستعادة كلمة المرور عبر البريد (المهمة [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)). يضيف تسجيل الدخول الاجتماعي جوجل وأبل عبر تبادل الرمز مع الخادم من خلال Socialite — بدون `firebase_auth` (المهمة [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36)). العقد مع الخادم هو رمزا Sanctum (وصول ~٦٠ دقيقة وتجديد ٣٠ يومًا) محفوظان في التخزين الآمن، مع إرسال `account_type` من الدور المفعّل. البنية الأساسية (المعترض وتخزين الرموز وتبادل الرمز الاجتماعي ونموذج الرموز) مدمجة بالفعل من المهمة [app #31](https://github.com/YoussefSalem582/Osta-App/issues/31)؛ أما طبقة الواجهة فلم تُبنَ بعد.

## Status & Issues / الحالة والمهام

> ‏المهام التالية مُجمّعة حسب حالة الواجهة والمهمة على الخادم.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35) | Auth email+password + secure storage + forgot | Open | M1 | p0 | youssef | [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37) ✅ + [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) ✅ — ready |
| [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36) | Social login Google & Apple | Open | M1 | p1 | youssef | [backend #38](https://github.com/YoussefSalem582/osta_backend/issues/38) ✅ — ready |

All mirrored backend epics are closed — nothing on the app side is backend-blocked. [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) adds role-bound register/login (`account_type ∈ {customer, business}`, Egypt phone normalization, business register atomically provisions a live ServiceCenter).

> ‏كل المهام المقابلة على الخادم مُغلقة — لا شيء في جهة التطبيق محجوب بانتظار الخادم. المهمة [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) تضيف تسجيلًا ودخولًا مرتبطين بالدور (`account_type ∈ {customer, business}` وتوحيد رقم الهاتف المصري، ويُنشئ تسجيل مركز الخدمة مركزًا حيًّا بشكل ذرّي).

## Screens / Mockups / الشاشات والتصاميم

| Screen | Epic | Mockup |
|---|---|---|
| Create account (email) | [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35) | ![Create account — email](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/04-create-account-email.png) |
| Social login | [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36) | ![Social login](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/03-social-login.png) |

## Planned architecture / البنية المخطّطة

`lib/features/auth/` is currently a **stub**: the only file is `data/models/auth_token_model.dart` (a plain `Equatable` dual-token model with hand-written `fromJson`/`toJson`); `domain/` and `presentation/` are empty. Everything below is planned per the epics unless marked existing.

> ‏مجلد `lib/features/auth/` ما زال **هيكلًا مبدئيًا**: الملف الوحيد هو `data/models/auth_token_model.dart` (نموذج رمزين من نوع `Equatable` مع `fromJson`/`toJson` مكتوبين يدويًا)؛ ومجلدا `domain/` و`presentation/` فارغان. كل ما يلي مخطّط حسب المهام ما لم يُذكر أنه قائم.

**Already built (core layer, epic #31 — merged):**

> ‏المبنيّ فعلًا (طبقة النواة، المهمة #31 — مدمجة):

- `core/network/auth_interceptor.dart` — `AuthInterceptor extends QueuedInterceptor`: attaches the bearer access token, and on 401 performs a single refresh-retry-once (queued so concurrent requests wait for one refresh).
- `core/auth/token_storage.dart` — `TokenStorage` over `flutter_secure_storage`, keys `access_token` / `refresh_token` (`readAccessToken` / `readRefreshToken` / `writeTokens` / `clear`).
- `core/network/social_token_exchange.dart` — `SocialTokenExchange`: `POST /auth/social/{provider}`, parses and stores the token pair.
- `core/network/token_pair.dart` — parses the dual tokens from the response envelope.
- `core/network/auth_events.dart` — broadcast `onSessionExpired` stream (refresh failure → app-level reaction).
- `features/auth/data/models/auth_token_model.dart` — plain `Equatable` dual-token model (hand-written `fromJson`/`toJson`/`props`, no codegen).

**Planned (epics #35/#36):**

> ‏المخطّط (المهام #35/#36):

- **State**: an `AuthCubit` (named in [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36)) on top of a shared token store, driving register / login / social / logout / forgot-reset states. Repository and use-case split per Clean Architecture (data → domain ← presentation) — layout TBD, see epics.
- **Data flow**: presentation → auth repository → `core/network` `ApiClient` (envelope-aware, typed `ApiException`s — bad login surfaces as `ValidationException` 422 with `fieldErrors`). The repository catches the `ApiException` and throws a `sealed` `Failure` (`NetworkFailure` / `ServerFailure` / `UnknownFailure` from `core/error/failure.dart`); the cubit uses a plain `try`/`catch` to map that `Failure` to an error state. No `Either`, no `.fold()`, no `Result<T>` — functional error types are deferred (see [ROADMAP](../../docs/ROADMAP.md) Phase 5).
- **DI**: hand-written `get_it` registration in `lib/core/di/injection.dart` (`configureDependencies()` adds a `registerLazySingleton` line per service), same as the existing `TokenStorage` / `SocialTokenExchange` / `AuthEvents` singletons. No annotations, no `build_runner` — DI codegen is deferred (see [ROADMAP](../../docs/ROADMAP.md) Phases 1–3).
- **Routing**: `go_router` — auth screens are not yet in `core/router/app_router.dart` (today only `/splash`, `/role`). The global redirect from [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32)/[#34](https://github.com/YoussefSalem582/Osta-App/issues/34) will send unauthenticated users to Login and clear tokens on 401 (listening to `AuthEvents.onSessionExpired`).
- **Social sign-in**: native `google_sign_in` / `sign_in_with_apple` → provider token → existing `SocialTokenExchange`; `account_type` comes from the persisted `activeRole` ([app #33](https://github.com/YoussefSalem582/Osta-App/issues/33)).
- **Terms gate**: register requires a terms-acceptance checkbox linking to the legal screens of [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38).

The error and DI contracts are deliberately plain so a team new to Flutter can read the flow top to bottom without codegen or functional-programming detours; the heavier tooling is scheduled, not abandoned.

> ‏عقدا معالجة الأخطاء وحقن الاعتماديات بسيطان عن قصد ليقرأ فريق جديد على Flutter المسار من أوله لآخره دون توليد كود أو منعطفات برمجة دالّية؛ والأدوات الأثقل مؤجَّلة ومجدولة لا مُلغاة (انظر [ROADMAP](../../docs/ROADMAP.md)).

## API endpoints / نقاط نهاية الـ API

Base `/api/v1`, envelope `{success, data, meta?}`. Legend: **Connected** = already called from `lib/core/network`; **Planned** = epic open, not yet wired.

> ‏الأساس `/api/v1` وبمغلّف `{success, data, meta?}`. الدليل: **Connected** = مُستدعاة فعلًا من `lib/core/network`؛ **Planned** = المهمة مفتوحة ولم تُوصَّل بعد.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| POST | `/auth/register` | Email register (multipart optional avatar, `account_type`) | [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35) / [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37), [#40](https://github.com/YoussefSalem582/osta_backend/issues/40) | Planned |
| POST | `/auth/login` | Email login (`account_type`; bad creds 422) | [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35) / [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37), [#40](https://github.com/YoussefSalem582/osta_backend/issues/40) | **Connected** |
| POST | `/auth/refresh` | Rotate the dual token pair | [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35) / [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37) | **Connected** (via `AuthInterceptor`) |
| POST | `/auth/logout` | Revoke tokens | [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35) / [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37) | Planned |
| POST | `/auth/social/{google\|apple}` | Exchange provider token → `{user, access_token, refresh_token}`; invalid token 422 | [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36) / [backend #38](https://github.com/YoussefSalem582/osta_backend/issues/38) | **Connected** (via `SocialTokenExchange`) |
| POST | `/forgot-password` | Send reset email (public) | [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35) / [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| POST | `/reset-password` | Reset password from email link (public) | [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35) / [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages (from the epics, not yet in pubspec):**

> ‏الحزم المخطّطة (من المهام، لم تُضَف بعد إلى pubspec):

| Package | Why | Epic |
|---|---|---|
| `google_sign_in` | Native Google OAuth | [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36) |
| `sign_in_with_apple` | Native Apple sign-in | [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36) |
| `image_picker` | Optional avatar at register | [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35) |

**Existing shared components to reuse (`lib/shared/ui/`):** `AppTextField` (form fields), `AppButton` (primary/secondary/text with built-in loading state for submit), `AppTopBar` (RTL-safe), `ErrorState` / `LoadingState` from `status_states.dart`, `AppBottomSheet` where sheet UX fits. Strings via `context.l10n` (ARB, Arabic default). Already in pubspec and needed here: `flutter_secure_storage` (tokens), `flutter_bloc` (AuthCubit), `equatable` (models — plain classes with hand-written `fromJson`/`toJson`, no codegen).

> ‏مكوّنات مشتركة قائمة يُعاد استخدامها من `lib/shared/ui/`: `AppTextField` لحقول النموذج، و`AppButton` بحالة تحميل مدمجة للإرسال، و`AppTopBar` الآمن للاتجاه من اليمين لليسار، و`ErrorState`/`LoadingState` من `status_states.dart`، و`AppBottomSheet` حين تناسب واجهة الورقة السفلية. النصوص عبر `context.l10n` (ARB، والعربية افتراضية). الموجود بالفعل في pubspec والمطلوب هنا: `flutter_secure_storage` للرموز، و`flutter_bloc` للـ `AuthCubit`، و`equatable` للنماذج — أصناف عادية مع `fromJson`/`toJson` يدويين دون توليد كود.

## Testing expectations / توقّعات الاختبار

**Already passing (core layer):**

> ‏نجحت بالفعل (طبقة النواة):

- `test/core/network/auth_interceptor_test.dart` — 5 cases: token attach, 401 refresh, request queuing, token rotation.
- `test/core/network/social_token_exchange_test.dart` — exchange + store.
- `test/auth_token_model_test.dart` — token model coverage.
- `test/core/network/api_client_test.dart` — envelope, error mapping (incl. 422), 401 retry.

**Planned for the feature (per epics #35/#36 and repo conventions):**

> ‏المخطّط للميزة (حسب المهام #35/#36 وأعراف المستودع):

- Unit tests for AuthCubit states (register/login/social/forgot), including 422 `ValidationException` mapping for bad login and bad provider token.
- Widget tests for form validation (required fields, +20 phone, password confirm, mandatory terms checkbox) — exact matrix TBD, see epics.
- Golden tests light/dark × RTL/LTR following the design-system pattern from [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).

Tests use `flutter_test` with `http_mock_adapter` and hand-written fakes — no mockito/mocktail, no `build_runner`.

> ‏تعتمد الاختبارات على `flutter_test` مع `http_mock_adapter` وبدائل مكتوبة يدويًا — دون mockito/mocktail ودون `build_runner`.

## Related docs / روابط ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md) — full endpoint catalogue and status legend
- [Delivery plan](../reference/DELIVERY_PLAN.md) — milestone map (auth is M1)
- [Roadmap](../../docs/ROADMAP.md) — phased plan for the deferred tooling (codegen, functional errors, flavors, CI matrix)
- [All feature docs](README.md) — siblings, notably role selection & routing ([app #32](https://github.com/YoussefSalem582/Osta-App/issues/32)–[#34](https://github.com/YoussefSalem582/Osta-App/issues/34)), splash & onboarding ([app #37](https://github.com/YoussefSalem582/Osta-App/issues/37)), and legal/terms ([app #38](https://github.com/YoussefSalem582/Osta-App/issues/38)), which gate or feed the auth flow
