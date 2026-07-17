> [INDEX](../INDEX.md) > [Features](README.md) > Business onboarding

# 🏪 Business Onboarding & Registration / تسجيل مراكز الخدمة والانضمام

## Overview / نظرة عامة

Open self-serve registration for service centers — no verification queue: a business account is **live the moment the wizard finishes** (epic [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53)). The owner signs up with email + password or Google/Apple, with `account_type=business` taken from the persisted active role; the backend atomically provisions a LIVE `ServiceCenter` at register ([backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40)). A two-step wizard follows: **Step 1 — business info** (optional logo, Egyptian +20 phone, address, and a map pin via `google_maps_flutter` + `geolocator`) → **Step 2 — catalog** (at least one service, picked from seeded presets or added as custom) → the center goes live and the owner lands on the Business Dashboard. The center is discoverable in `/centers/nearby` immediately ([backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56)). Both mirrored backend epics are closed — the app side is not backend-blocked.

> ‏تسجيل ذاتي مفتوح لمراكز الخدمة — بدون طابور تحقق: حساب العمل **يصبح مفعّلًا فور انتهاء المعالج** (المهمة [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53)). يسجّل المالك بالبريد الإلكتروني وكلمة المرور أو عبر جوجل/أبل مع إرسال `account_type=business` من الدور المفعّل المحفوظ، ويُنشئ الخادم مركز خدمة مفعّلًا تلقائيًا عند التسجيل (المهمة [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40)). يلي ذلك معالج من خطوتين: **الخطوة ١ — بيانات النشاط** (شعار اختياري، رقم هاتف مصري +20، العنوان، وتحديد الموقع على الخريطة عبر `google_maps_flutter` و`geolocator`) ثم **الخطوة ٢ — الكتالوج** (خدمة واحدة على الأقل من القوالب الجاهزة أو خدمة مخصصة) ثم يُفعَّل المركز وينتقل المالك إلى لوحة تحكم الأعمال. يظهر المركز فورًا في `/centers/nearby` (المهمة [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56)). مهمتا الخادم المقابلتان مغلقتان — لا شيء معطّل من جهة الخادم.

## Status & Issues / الحالة والمهام

Egyptian caption: الجدول التالي يلخّص حالة المهمة والمهام المرتبطة بها من جهة الخادم.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) | Business onboarding & registration | Wired (API + wizard; social/custom-service deferred) | M1 | p0 | haidy | [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) ✅ + [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) ✅ — ready |

[backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) ships the full B2B onboarding contract (`PUT /business/profile` with multipart logo, 12 seeded catalog presets across OIL/BRAKES/AC, bulk catalog attach, capacity). [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) makes register/login role-bound (`account_type ∈ {customer, business}`, phone/email uniqueness per account type, Egypt +20 phone normalization) and provisions the live center atomically on business register.

> ‏تُسلّم المهمة [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) عقد الانضمام الكامل للأعمال (`PUT /business/profile` مع رفع شعار متعدد الأجزاء، و12 قالب خدمة جاهزًا موزّعة على OIL/BRAKES/AC، وربط الكتالوج بالجملة، والسعة). أما المهمة [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) فتجعل التسجيل والدخول مرتبطَين بالدور (`account_type ∈ {customer, business}`، وتفرّد الهاتف/البريد لكل نوع حساب، وتوحيد صيغة الهاتف المصري +20) وتُنشئ المركز المفعّل تلقائيًا عند تسجيل حساب عمل.

## Screens / Mockups / الشاشات والتصاميم

| Screen | Epic | Mockup |
|---|---|---|
| Provider onboarding (flow overview) | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) | ![Provider onboarding](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/21-provider-onboarding.png) |
| Step 1 — Business identity & location | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) | ![Business registration — identity and location](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/22-business-registration-identity-and-location.png) |
| Step 2 — Services (catalog) | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) | ![Business registration — services](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/23-business-registration-services.png) |

## Architecture / البنية

`lib/features/business/onboarding/` is **wired** (2026-07-16): presentation (3 wizard screens + widgets including `MapPinPickerSheet`) + data (`BusinessOnboardingRepository`, `CatalogPreset`, `BusinessProfileInput`) + `BusinessOnboardingCubit`. A `ShellRoute` shares one cubit across `/provider-onboarding` → `/business-identity` → `/business-catalog`. Completion is **derived from the server** (2026-07-17): `SessionState.businessOnboarded` resolves from `GET /business/services` being non-empty, since the wizard cannot finish without ≥1 service. It was a persisted `session_business_onboarded` preference until sign-out wiping it started re-running the wizard and duplicating the catalog — see the CHANGELOG. Social business signup remains a UI stub.

> ‏`lib/features/business/onboarding/` **موصول** (2026-07-16): طبقة العرض + البيانات + الـ Cubit. يشارك `ShellRoute` cubitًا واحدًا عبر خطوات المعالج. اكتمال المعالج **يُشتقّ من الخادم** (2026-07-17): كتالوج غير فارغ يعني أن المعالج انتهى، بعد أن كان محفوظًا على الجهاز فيتكرّر الكتالوج عند كل تسجيل خروج. التسجيل الاجتماعي ما زال stub في الواجهة.

- **Account creation is shared with the auth feature** ([app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)/[#36](https://github.com/YoussefSalem582/Osta-App/issues/36)): the same register screens send `account_type=business` from the persisted `activeRole`. Social UI is still a stub.
- **State**: `BusinessOnboardingCubit` holds the identity draft, preset list/selection, submit/activate status, and 422 `fieldErrors`.
- **Data flow**: presentation → `BusinessOnboardingRepository` → `ApiClient`. `ApiException` throws through; the cubit `try`/`catch`es — no `Either` / `.fold()`. Profile submit is multipart when a logo is attached.
- **Map pin**: Step 1 opens `MapPinPickerSheet` (`google_maps_flutter` + `LocationService` / `geolocator`); pin stored server-side as PostGIS ([backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56)).
- **Catalog step**: loads 12 seeded presets, requires ≥1, bulk-attaches via `POST /business/catalog`. Presets **toggle**; custom services are **removable** rows (a `Custom` badge + delete button — never a switch, which used to delete on "off"). The "add common" shortcut reflects the active category filter and unions into the current picks. Activate shows the service count and a **review-and-confirm sheet** (`activation_review_sheet.dart`) before the center goes live.
- **UI/UX (2026-07-17)**: cards sit on `AppCard` + `AppElevation`; the required-location error lives on `LocationPickerCard` itself; the step header is slimmed with the "goes live instantly" line on the `AppTopBar` subtitle. See the CHANGELOG entry for the full pass.
- **DI**: manual `get_it` — `BusinessOnboardingRepository` (lazy singleton) + `BusinessOnboardingCubit` (factory) in `configureDependencies()`.
- **Routing**: authenticated `business` + `businessOnboarded == false` → identity → catalog wizard; Activate → release the gate → `/business` shell ([app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)). Tri-state like the customer's add-car gate: only an explicit `false` opens the wizard, so an unresolved check fails open rather than re-onboarding a finished owner. `/provider-onboarding` intro is routable but no longer the forced entry (merchants already saw the logged-out carousel).

## API endpoints / نقاط نهاية الـ API

Base `/api/v1`, envelope `{success, data, meta?}`. Legend: **Connected** = already called from `lib/core/network`; **Planned** = epic open, not yet wired.

> ‏القاعدة `/api/v1` والمغلّف `{success, data, meta?}`. الدليل: **Connected** أي مُستدعاة فعلًا من `lib/core/network`، و**Planned** أي المهمة مفتوحة ولم تُوصَّل بعد.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| POST | `/auth/register` | Register owner with `account_type=business`; atomically provisions a LIVE ServiceCenter | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40) | **Connected** (`AuthRepositoryImpl.register`) |
| POST | `/auth/social/{google\|apple}` | Social register/login with `account_type` from the active role | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #38](https://github.com/YoussefSalem582/osta_backend/issues/38) | **Connected** (core `SocialTokenExchange`; UI stub) |
| PUT | `/business/profile` | Step 1 submit — multipart logo, legal/trade name, +20 phone, address, city, map pin, business_type, year_founded | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) | **Connected** (`BusinessOnboardingRepository.updateProfile`) |
| GET | `/business/catalog/presets` | Load the 12 seeded service presets (OIL / BRAKES / AC) for Step 2 | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) | **Connected** (`fetchPresets`) |
| POST | `/business/catalog` | Bulk-attach the selected services (≥1 required) | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) / [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) | **Connected** (`attachCatalog`) |

`PUT /business/capacity` (weekly slots, breaks, holidays) also ships in [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56) but is not part of the #53 wizard — it surfaces later via the Business More hub ([app #58](https://github.com/YoussefSalem582/Osta-App/issues/58)).

> ‏تُسلَّم أيضًا `PUT /business/capacity` (الفترات الأسبوعية والاستراحات والعطلات) ضمن [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56)، لكنها ليست جزءًا من معالج المهمة #53 — تظهر لاحقًا عبر مركز "المزيد" للأعمال ([app #58](https://github.com/YoussefSalem582/Osta-App/issues/58)).

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Packages in use:**

| Package | Why | Status |
|---|---|---|
| `google_maps_flutter` | Map pin picker in Step 1 | **In pubspec** (shared with customer map) |
| `geolocator` | Device location for the map pin | **In pubspec** (via `LocationService`) |
| `image_picker` | Optional business logo upload | **In pubspec** |
| `google_sign_in` / `sign_in_with_apple` | Social register path (shared with auth) | Still deferred ([app #36](https://github.com/YoussefSalem582/Osta-App/issues/36)) |

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
