> [INDEX](../INDEX.md) > [Features](README.md) > Business onboarding

# 🏪 Business Onboarding & Registration / تسجيل مراكز الخدمة والانضمام

## Overview / نظرة عامة

Open self-serve registration for service centers — no verification queue: a business account is **live the moment the wizard finishes** (epic [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53)). The owner signs up with email + password or Google/Apple, with `account_type=business` taken from the persisted active role; the backend atomically provisions a LIVE `ServiceCenter` at register ([backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40)). A two-step wizard follows: **Step 1 — business info** (optional logo, Egyptian +20 phone, address, and a map pin via `google_maps_flutter` + `geolocator`) → **Step 2 — catalog** (at least one service, picked from seeded presets or added as custom) → the center goes live and the owner lands on the Business Dashboard. The center is discoverable in `/centers/nearby` immediately ([backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56)). Both mirrored backend epics are closed — the app side is not backend-blocked.

> ‏تسجيل ذاتي مفتوح لمراكز الخدمة — بدون طابور تحقق: حساب العمل **يصبح مفعّلًا فور انتهاء المعالج** (المهمة [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53)). يسجّل المالك بالبريد الإلكتروني وكلمة المرور أو عبر جوجل/أبل مع إرسال `account_type=business` من الدور المفعّل المحفوظ، ويُنشئ الخادم مركز خدمة مفعّلًا تلقائيًا عند التسجيل (المهمة [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40)). يلي ذلك معالج من خطوتين: **الخطوة ١ — بيانات النشاط** (شعار اختياري، رقم هاتف مصري +20، العنوان، وتحديد الموقع على الخريطة عبر `google_maps_flutter` و`geolocator`) ثم **الخطوة ٢ — الكتالوج** (خدمة واحدة على الأقل من القوالب الجاهزة أو خدمة مخصصة) ثم يُفعَّل المركز وينتقل المالك إلى لوحة تحكم الأعمال. يظهر المركز فورًا في `/centers/nearby` (المهمة [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56)). مهمتا الخادم المقابلتان مغلقتان — لا شيء معطّل من جهة الخادم.

## Status & Issues / الحالة والمهام

Egyptian caption: الجدول التالي يلخّص حالة المهمة والمهام المرتبطة بها من جهة الخادم.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) | Business onboarding & registration | Open | M1 | p0 | haidy | [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) ✅ + [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) ✅ — ready |

[backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) ships the full B2B onboarding contract (`PUT /business/profile` with multipart logo, 12 seeded catalog presets across OIL/BRAKES/AC, bulk catalog attach, capacity). [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) makes register/login role-bound (`account_type ∈ {customer, business}`, phone/email uniqueness per account type, Egypt +20 phone normalization) and provisions the live center atomically on business register.

> ‏تُسلّم المهمة [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) عقد الانضمام الكامل للأعمال (`PUT /business/profile` مع رفع شعار متعدد الأجزاء، و12 قالب خدمة جاهزًا موزّعة على OIL/BRAKES/AC، وربط الكتالوج بالجملة، والسعة). أما المهمة [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) فتجعل التسجيل والدخول مرتبطَين بالدور (`account_type ∈ {customer, business}`، وتفرّد الهاتف/البريد لكل نوع حساب، وتوحيد صيغة الهاتف المصري +20) وتُنشئ المركز المفعّل تلقائيًا عند تسجيل حساب عمل.

## Screens / Mockups / الشاشات والتصاميم

| Screen | Epic | Mockup |
|---|---|---|
| Provider onboarding (flow overview) | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) | ![Provider onboarding](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/21-provider-onboarding.png) |
| Step 1 — Business identity & location | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) | ![Business registration — identity and location](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/22-business-registration-identity-and-location.png) |
| Step 2 — Services (catalog) | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) | ![Business registration — services](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/23-business-registration-services.png) |

## Planned architecture / البنية المخطّطة

`lib/features/business/onboarding/presentation/` is **implemented** with three wizard screens (`ProviderOnboardingPage`, `BusinessIdentityPage`, `BusinessCatalogPage`) and 8 reusable widgets (`StepHeader`, `LogoUploadBox`, `LocationPickerCard`, `PresetServicesBanner`, `ServiceCategoryChips`, `AddPresetCard`, `ServiceToggleCard`, `AddCustomServiceButton`). Other business sub-folders (`bookings/`, `dashboard/`, `services/`, `team/`, `wallet/`) remain stubs. BLoC, repository, and API integration follow below per epic [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53).

> ‏تم تنفيذ طبقة العرض في `lib/features/business/onboarding/presentation/` عبر شاشات المعالج الثلاث ومكوناتها الثمانية القابلة لإعادة الاستخدام. وتظل بقية مجلدات الأعمال مبدئية حتى ربط المنطق والـ API وفق المهمة [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53).

- **Account creation is shared with the auth feature** ([app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)/[#36](https://github.com/YoussefSalem582/Osta-App/issues/36)): the same register / social-login screens are used, sending `account_type=business` from the `activeRole` persisted by the role chooser ([app #33](https://github.com/YoussefSalem582/Osta-App/issues/33)). Social exchange reuses the already-merged `core/network/social_token_exchange.dart`; tokens land in `TokenStorage` (`flutter_secure_storage`).
- **State**: BLoC/Cubit per the repo convention (`flutter_bloc` 9) — a wizard cubit driving step state and per-step validation; exact class names TBD — see epic. Models are plain `Equatable` classes with hand-written `fromJson`/`toJson` (no codegen — see [ROADMAP](../../docs/ROADMAP.md)).
- **Data flow**: presentation → business-onboarding repository → `core/network` `ApiClient` (envelope-aware `get/post/put/delete<T>`, typed `ApiException`s — field errors surface as `ValidationException` 422 with `fieldErrors`). The repository catches those and **throws** a sealed `Failure` (`core/error/failure.dart`); the wizard cubit uses plain `try`/`catch` — no `Either`, no `.fold()`, no `Result<T>`. The profile submit is multipart (optional logo).
- **Map pin**: Step 1 embeds a map picker (`google_maps_flutter`) with device location from `geolocator`; the pin is stored server-side as a PostGIS point ([backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56)).
- **Catalog step**: Step 2 loads the 12 seeded presets, requires ≥1 selected (or custom) service, and bulk-attaches them.
- **DI**: **manual** `get_it` registration — add a hand-written `registerLazySingleton` line for the repository/cubit in `lib/core/di/injection.dart` (`configureDependencies()`), same pattern as the existing `ApiClient` / `TokenStorage` singletons. No `injectable`, no `build_runner` (deferred — see [ROADMAP](../../docs/ROADMAP.md)).
- **Routing**: `go_router` — no business routes exist yet (`core/router/app_router.dart` today serves only `/splash` and `/role`). On wizard completion the owner is routed into the planned Provider shell at `/dashboard` ([app #34](https://github.com/YoussefSalem582/Osta-App/issues/34), dashboard itself is epic [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54)).

> ‏**إنشاء الحساب مشترك مع ميزة المصادقة** ([app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)/[#36](https://github.com/YoussefSalem582/Osta-App/issues/36)): تُستخدم نفس شاشات التسجيل والدخول الاجتماعي، مع إرسال `account_type=business` من `activeRole` المحفوظ عبر شاشة اختيار الدور ([app #33](https://github.com/YoussefSalem582/Osta-App/issues/33))، ويُعاد استخدام `core/network/social_token_exchange.dart` المدموج مسبقًا، وتُحفظ الرموز في `TokenStorage` (`flutter_secure_storage`). **الحالة** تُدار عبر BLoC/Cubit حسب عُرف المستودع؛ والنماذج أصنافٌ عادية ترث `Equatable` مع `fromJson`/`toJson` مكتوبة يدويًا (بدون توليد كود — راجع [ROADMAP](../../docs/ROADMAP.md)). **تدفّق البيانات** يمرّ من العرض إلى مستودع الانضمام ثم إلى `ApiClient`؛ ويلتقط المستودع أخطاء `ApiException` **ويرمي** صنف `Failure` المغلق (`core/error/failure.dart`)، بينما يستخدم الـ cubit `try`/`catch` بسيطة — بلا `Either` ولا `.fold()` ولا `Result<T>`. أما **حقن التبعيات** فيتم بتسجيل يدوي في `get_it` عبر سطر `registerLazySingleton` مكتوب بخط اليد داخل `lib/core/di/injection.dart` (بدون `injectable` ولا `build_runner` — مؤجَّل، راجع [ROADMAP](../../docs/ROADMAP.md)). ويُوجَّه المالك عند اكتمال المعالج إلى واجهة مقدّم الخدمة عند `/dashboard`.

## API endpoints / نقاط نهاية الـ API

Base `/api/v1`, envelope `{success, data, meta?}`. Legend: **Connected** = already called from `lib/core/network`; **Planned** = epic open, not yet wired.

> ‏القاعدة `/api/v1` والمغلّف `{success, data, meta?}`. الدليل: **Connected** أي مُستدعاة فعلًا من `lib/core/network`، و**Planned** أي المهمة مفتوحة ولم تُوصَّل بعد.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| POST | `/auth/register` | Register owner with `account_type=business`; atomically provisions a LIVE ServiceCenter | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) | Planned |
| POST | `/auth/social/{google\|apple}` | Social register/login with `account_type` from the active role | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #38](https://github.com/YoussefSalem582/osta_backend/issues/38) | **Connected** (via `SocialTokenExchange`) |
| PUT | `/business/profile` | Step 1 submit — multipart logo, legal/trade name, +20 phone, address, city, map pin, business_type, year_founded | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) | Planned |
| GET | `/business/catalog/presets` | Load the 12 seeded service presets (OIL / BRAKES / AC) for Step 2 | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) | Planned |
| POST | `/business/catalog` | Bulk-attach the selected services (≥1 required) | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) | Planned |

`PUT /business/capacity` (weekly slots, breaks, holidays) also ships in [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) but is not part of the #53 wizard — it surfaces later via the Business More hub ([app #58](https://github.com/YoussefSalem582/Osta-App/issues/58)).

> ‏تُسلَّم أيضًا `PUT /business/capacity` (الفترات الأسبوعية والاستراحات والعطلات) ضمن [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56)، لكنها ليست جزءًا من معالج المهمة #53 — تظهر لاحقًا عبر مركز "المزيد" للأعمال ([app #58](https://github.com/YoussefSalem582/Osta-App/issues/58)).

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages (from the epic, not yet in pubspec):**

> ‏حزم مخطّطة (من المهمة، لم تُضَف إلى pubspec بعد):

| Package | Why | Epic |
|---|---|---|
| `google_maps_flutter` | Map pin picker in Step 1 | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) |
| `geolocator` | Device location for the map pin | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) |
| `image_picker` | Optional business logo upload | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) |
| `google_sign_in` / `sign_in_with_apple` | Social register path (shared with auth) | [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36) |

**Existing shared components to reuse (`lib/shared/ui/`):** `AppTextField` (business info form), `AppButton` (step navigation/submit with built-in loading state), `AppTopBar` (RTL-safe wizard app bar), `AppCard` (preset service cards), `AppBottomSheet` (custom-service entry), `EmptyState` / `ErrorState` / `LoadingState` from `status_states.dart` (presets fetch). `EgpFormatter` (`shared/formatters/app_formatters.dart`) for service prices in Step 2. Strings via `context.l10n` (ARB, Arabic default). Already in pubspec and needed here: `flutter_bloc` (wizard cubit), `equatable` (models), `flutter_secure_storage` (tokens).

> ‏مكوّنات مشتركة قائمة يُعاد استخدامها (`lib/shared/ui/`): `AppTextField` لنموذج بيانات النشاط، و`AppButton` للتنقّل والإرسال مع حالة تحميل مدمجة، و`AppTopBar` كشريط علوي آمن للعربية، و`AppCard` لبطاقات الخدمات الجاهزة، و`AppBottomSheet` لإدخال خدمة مخصّصة، و`EmptyState`/`ErrorState`/`LoadingState` من `status_states.dart` عند جلب القوالب. ويُستخدم `EgpFormatter` (`shared/formatters/app_formatters.dart`) لأسعار الخدمات في الخطوة ٢، والنصوص عبر `context.l10n` (ARB، العربية افتراضيًا). والموجود بالفعل في pubspec والمطلوب هنا: `flutter_bloc` (cubit المعالج)، و`equatable` (النماذج)، و`flutter_secure_storage` (الرموز).

## Testing expectations / توقّعات الاختبار

Per epic [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) and repo conventions:

> ‏وفق المهمة [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) وأعراف المستودع:

- **Widget tests per wizard step validation** (explicit acceptance in the epic): Step 1 required fields incl. +20 phone and map pin, Step 2 blocks continue until ≥1 service is selected.
- Unit tests for the wizard cubit states, including 422 `ValidationException` → `fieldErrors` mapping on profile submit.
- Golden tests light/dark × RTL/LTR following the design-system pattern from [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).
- Already passing at the core layer (reused here): `test/core/network/api_client_test.dart` (envelope, error mapping, 401 retry) and `social_token_exchange_test.dart`.

> ‏اختبارات ودجت للتحقّق من كل خطوة في المعالج (قبولٌ صريح في المهمة): حقول الخطوة ١ المطلوبة بما فيها هاتف +20 وتحديد الموقع، والخطوة ٢ تمنع المتابعة حتى اختيار خدمة واحدة على الأقل. واختبارات وحدة لحالات cubit المعالج، بما فيها ربط `ValidationException` عند 422 بـ `fieldErrors` عند إرسال الملف. واختبارات golden للوضعين الفاتح/الداكن × RTL/LTR وفق نمط نظام التصميم من [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29). وتمرّ بالفعل في طبقة النواة (يُعاد استخدامها هنا): `test/core/network/api_client_test.dart` و`social_token_exchange_test.dart`.

## Related docs / وثائق ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md) — full endpoint catalogue and status legend
- [Delivery plan](../reference/DELIVERY_PLAN.md) — milestone map (business onboarding is M1)
- [Auth](auth.md) — shared register / social-login flow that carries `account_type=business`
- [Role selection & routing](role-selection-and-routing.md) — persisted `activeRole` and the Provider shell redirect ([app #32](https://github.com/YoussefSalem582/Osta-App/issues/32)–[#34](https://github.com/YoussefSalem582/Osta-App/issues/34))
- [Roadmap](../../docs/ROADMAP.md) — phased reintroduction of deferred tooling (codegen, fpdart, flavors, CI matrix)
- [All feature docs](README.md) — siblings, notably the Business Dashboard ([app #54](https://github.com/YoussefSalem582/Osta-App/issues/54)) the wizard lands on and the catalog & pricing epic ([app #56](https://github.com/YoussefSalem582/Osta-App/issues/56)) that later manages the seeded services
