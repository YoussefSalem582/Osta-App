> [INDEX](../INDEX.md) > [Features](README.md) > Required car onboarding

# 🚗 Required Car Onboarding (Add First Car) / إضافة أول سيارة

## Overview / نظرة عامة

Every customer must register at least one car before reaching Home. After login (and role routing), the app checks `GET /vehicles` — if the list is empty, a mandatory **AddFirstCarScreen** is shown and back-navigation to Home is blocked by the router. The form collects brand, model, model year, plate, and kilometers, then submits `POST /vehicles`; the first vehicle is automatically marked `is_primary=true` by the backend (201). Once a vehicle exists, the gate opens and the customer lands on Home. This gate is a product rule from the MVP tracker ([app #61](https://github.com/YoussefSalem582/Osta-App/issues/61)) and is specified by epic [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39). The full garage experience (edit, delete, primary switching, maintenance) comes later in [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50).

> ‏يجب على كل عميل تسجيل سيارة واحدة على الأقل قبل الوصول إلى الشاشة الرئيسية. بعد تسجيل الدخول، يتحقق التطبيق من `GET /vehicles` — إذا كانت القائمة فارغة تظهر شاشة إلزامية لإضافة أول سيارة، ويمنع الموجّه (router) الرجوع للخلف. يجمع النموذج: الماركة، الموديل، سنة الصنع، رقم اللوحة، وعدد الكيلومترات، ثم يرسل `POST /vehicles`، وتُعلَّم أول سيارة تلقائيًا كسيارة أساسية. بعد إضافة السيارة يُفتح الطريق إلى الشاشة الرئيسية. التفاصيل الكاملة في القضية المرتبطة على GitHub.

## Status & Issues / الحالة والقضايا

Egyptian caption: القضية والقيود المرتبطة بهذه الميزة.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39) | Required car onboarding | OPEN | M1 | p0 | roaa | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) — **ready** (closed; create+list shipped early at M1 for this gate) |

Backend is not a blocker: the vehicles CRUD epic ([backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54)) is closed, and its create + list endpoints were deliberately delivered early at M1 to support this required-onboarding gate.

> ‏الخلفية (backend) ليست عائقًا: ملحمة إدارة السيارات ([backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54)) مغلقة، وقد سُلّمت نقطتا الإنشاء والقائمة مبكرًا عند M1 لدعم بوابة الإضافة الإلزامية هذه.

## Screens / Mockups / الشاشات والنماذج

| Screen | Mockup |
|---|---|
| Add First Car | ![Add first car](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/06-add-first-car.png) |

## Planned architecture / البنية المخطط لها

> Everything below is **planned** per epic [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39) — the feature folder `lib/features/customer/garage/` is currently an empty stub (no dart files).

> ‏كل ما يلي **مخطط له** حسب الملحمة [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39) — مجلد الميزة `lib/features/customer/garage/` حاليًا مجرد هيكل فارغ (بدون ملفات dart).

- **Feature folder**: `lib/features/customer/garage/` with the standard Clean Architecture split `data → domain ← presentation` (shared with the later My Garage epic [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50)).
- **State management**: a Cubit/Bloc (`flutter_bloc`) for the add-first-car form — submit `POST /vehicles`, expose loading / validation-error / success states. Exact class names TBD — see epic.
- **Data flow**: repository calls go through the existing envelope-aware `ApiClient` in `lib/core/network/api_client.dart`, returning `ApiResult<T>` or throwing typed `ApiException`s (`ValidationException` with `fieldErrors` maps 422 responses onto form fields). The repository catches those and rethrows a `Failure` (`sealed class Failure implements Exception`, see `lib/core/error/failure.dart`); the cubit uses plain `try`/`catch` to turn a caught `Failure` into an error state — no `Either`, no `Result<T>`, no `.fold()`.
- **Models**: a plain vehicle model as `class Vehicle extends Equatable` with a hand-written `factory Vehicle.fromJson` / `toJson` / `props` — mirroring `lib/features/auth/data/models/auth_token_model.dart`. No `freezed`, no `json_serializable`, no `build_runner`, no `*.g.dart` / `*.freezed.dart`. (Codegen is deferred — see [ROADMAP](../../docs/ROADMAP.md), Phases 1–3.)
- **DI**: the repository and cubit are registered **manually** with `get_it` — a hand-written `registerLazySingleton` line added to `configureDependencies()` in `lib/core/di/injection.dart`, alongside the existing registrations. No `injectable`, no annotations, no `injection.config.dart`.
- **Routing gate**: `go_router` (currently only `/splash` and `/role` exist). The customer-shell redirect (planned in [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)) reads `GET /vehicles`; empty list → redirect to AddFirstCarScreen, and the router **blocks back-navigation** so Home is unreachable until a car exists.

The error and DI conventions above are deliberate: the project uses plain, readable Dart so a team new to Flutter can move fast. The heavier tooling (fpdart, freezed/json_serializable/injectable) is deferred, not rejected — the phased reintroduction plan lives in [ROADMAP](../../docs/ROADMAP.md).

> ‏اتفاقيات معالجة الأخطاء وحقن الاعتماديات أعلاه مقصودة: المشروع يستخدم Dart بسيطًا وواضحًا كي يتحرك فريق جديد على Flutter بسرعة. الأدوات الأثقل (fpdart، freezed/json_serializable/injectable) مؤجَّلة وليست مرفوضة — خطة إعادة إدخالها على مراحل موجودة في [ROADMAP](../../docs/ROADMAP.md).

## API endpoints / نقاط نهاية الـ API

Egyptian caption: النقاط أدناه هي بوابة الفحص وإنشاء أول سيارة.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/vehicles` | Gate check — empty list triggers the add-first-car screen | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) / [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39) | Planned |
| POST | `/vehicles` | Create first vehicle → 201; first is auto `is_primary=true` | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) / [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39) | Planned |

Vehicle fields (backend #54): brand, model, year, plate, VIN, fuel/transmission enums, current_mileage, is_primary. The onboarding form captures the epic's subset: brand, model, model_year, plate, kilometers.

> ‏حقول السيارة (backend #54): brand، model، year، plate، VIN، تعدادات الوقود/ناقل الحركة، current_mileage، is_primary. نموذج الإضافة يلتقط المجموعة الفرعية للملحمة: brand، model، model_year، plate، kilometers.

## Packages & shared widgets / الحزم والعناصر المشتركة

- **New packages**: none required by epic #39 itself (the richer garage epic [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50) plans `dropdown_search` for brand/model pickers — reusable here if built first).
- **Existing shared UI to reuse** (`lib/shared/ui/`): `AppTextField` (form inputs), `AppButton` (submit with loading state), `AppTopBar`, `AppCard`, `ErrorState`/`LoadingState` from `status_states.dart`.
- **Formatters**: `NumberFormatter` (`lib/shared/formatters/app_formatters.dart`) for kilometers display with ar_EG Arabic-Indic digits.
- **l10n**: all strings via `context.l10n` (`shared/extensions/context_ext.dart`); Arabic default, RTL-first.

> ‏لا تحتاج الملحمة #39 حزمًا جديدة. يُعاد استخدام عناصر الواجهة المشتركة الموجودة في `lib/shared/ui/` (مثل `AppTextField` و`AppButton` و`ErrorState`/`LoadingState`)، والمنسّق `NumberFormatter` لعرض الكيلومترات بأرقام عربية-هندية، وكل النصوص عبر `context.l10n` مع العربية كلغة افتراضية واتجاه من اليمين لليسار.

## Testing expectations / توقعات الاختبار

From epic [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39):

> ‏من الملحمة [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39):

- **Widget test**: with an empty `GET /vehicles` response, AddFirstCarScreen is shown and Home is blocked.
- **Unit tests**: cubit submit flow — success (201) and 422 `ValidationException` field-error mapping (fakes available in `test/core/network/fakes.dart`).
- **Golden tests**: per the design-system pattern ([app #29](https://github.com/YoussefSalem582/Osta-App/issues/29)) — light/dark × RTL/LTR.

## Related docs / روابط ذات صلة

- [API endpoints](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [ROADMAP — deferred tooling plan](../../docs/ROADMAP.md)
- Sibling features: [My Garage](garage.md) · [First-run flow & role routing](role-selection-and-routing.md) · [Auth](auth.md) · [Home dashboard](home-dashboard.md)
