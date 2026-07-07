> [INDEX](../INDEX.md) > [Features](README.md) > My Garage

# 🚗 My Garage — vehicles + maintenance / جراجي — السيارات والصيانة

## Overview / نظرة عامة

My Garage is the customer-side vehicle hub, specified by epic [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50) (M5, b2c, p1, owner: roaa). It lists the user's vehicles with a primary badge, supports add / edit / soft-delete (with an undo snackbar), set-primary, and a detail view (brand, model, year, plate, VIN, fuel, transmission, mileage). Each vehicle also carries a maintenance tracker: maintenance records, spend totals, an oil-change-due banner, and client-side PDF export via the share sheet. It builds on the required car-onboarding gate from [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39), which forces every customer to add a first car (auto-primary) before reaching Home. Backend support is fully merged: vehicles CRUD ([backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54)) and the maintenance tracker ([backend #55](https://github.com/YoussefSalem582/osta_backend/issues/55)) are both closed.

> ‏"جراجي" هو مركز سيارات العميل، محدد في الملف [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50). يعرض سيارات المستخدم مع شارة "أساسية"، ويدعم الإضافة والتعديل والحذف الناعم (مع إمكانية التراجع)، وتعيين السيارة الأساسية، وشاشة تفاصيل (الماركة، الموديل، السنة، اللوحة، رقم الشاسيه، الوقود، ناقل الحركة، الممشى). ولكل سيارة سجل صيانة: سجلات وإجماليات وتنبيه موعد تغيير الزيت وتصدير PDF عبر مشاركة الملفات. الواجهة الخلفية جاهزة بالكامل: عمليات السيارات ([backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54)) ومتتبع الصيانة ([backend #55](https://github.com/YoussefSalem582/osta_backend/issues/55)) كلاهما مُنجز.

## Status & Issues / الحالة والمهام

The two issues below track this feature; both mirrored backend epics are already merged.

> ‏المهمتان التاليتان تتابعان هذه الميزة، وكلا الملفين الخلفيين المقابلين مُنجزان بالفعل.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50) | My Garage | OPEN | M5 | p1 | roaa | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) (closed) + [backend #55](https://github.com/YoussefSalem582/osta_backend/issues/55) (closed) — **ready** |
| [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39) | Required car onboarding (related gate) | OPEN | M1 | p0 | roaa | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) (closed; create+list shipped early at M1) — **ready** |

Nothing is blocked on the backend: both mirrored epics are merged, so this feature is app-work only.

> ‏لا شيء معطّل بسبب الواجهة الخلفية: كلا الملفين المقابلين مُنجز، فهذه الميزة عمل تطبيقي بالكامل.

## Screens / Mockups / الشاشات والتصاميم

| Screen | Mockup |
|---|---|
| My Garage (list, detail, maintenance) | ![My Garage](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/15-my-garage.png) |
| Add first car (onboarding gate, #39) | ![Add first car](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/06-add-first-car.png) |

## Planned architecture / البنية المخطّطة

Everything below is **planned** — `lib/features/customer/garage/` is currently an empty stub directory with no dart files.

> ‏كل ما يلي **مخطّط له** — مجلد `lib/features/customer/garage/` حاليًا مجرد مجلد فارغ بلا أي ملفات dart.

The feature will follow the repo's plain-Dart approach: no codegen, hand-written models and dependency registration. Advanced tooling (freezed, json_serializable, injectable) is deferred, not rejected — see the phased plan in [ROADMAP](../../docs/ROADMAP.md).

> ‏ستتبع الميزة أسلوب الـ Dart البسيط المعتمد في المستودع: بلا توليد كود، مع نماذج وتسجيل تبعيات مكتوبَين يدويًا. الأدوات المتقدمة (freezed وjson_serializable وinjectable) مؤجّلة لا مرفوضة — راجع الخطة المرحلية في [ROADMAP](../../docs/ROADMAP.md).

- **Layers** (Clean Architecture, matching the repo convention data → domain ← presentation):
  - `data/` — plain `Equatable` vehicle and maintenance-record models with hand-written `fromJson` / `toJson` (like `lib/features/auth/data/models/auth_token_model.dart`), a remote data source calling the shared `ApiClient` (`lib/core/network/api_client.dart`), and a repository implementation that catches typed `ApiException`s and rethrows a sealed `Failure` (`core/error/failure.dart`).
  - `domain/` — repository contract; entity names TBD — see epic [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50).
  - `presentation/` — garage list, vehicle detail (with maintenance tab), and add/edit form screens; Cubits/Blocs (`flutter_bloc`) for list, detail, and form state.
- **Data flow**: UI → Cubit → repository → `ApiClient` (Dio 5 behind the envelope-aware client). The client throws typed `ApiException`s; the repository catches them with plain `try`/`catch` and rethrows a `Failure`, and the Cubit catches the `Failure` — no `Either`, no `.fold()`, no `Result<T>`. List endpoints return `ApiResult<T>` with `PaginationMeta` where paginated. Auth headers and 401 refresh-retry-once are handled globally by `AuthInterceptor`.
- **DI**: register data sources, repositories, and Cubits with **manual** `get_it` registration — add a hand-written `registerLazySingleton` line in `configureDependencies()` (`core/di/injection.dart`, exposes the global `getIt`). No annotations, no `build_runner`.
- **Routing**: garage routes added to `go_router` (`core/router/app_router.dart`) inside the planned customer shell (`StatefulShellRoute`, epic [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)). Current router only has `/splash` and `/role` — no shells yet. Route paths are declared as `static const path` on the page widgets. The #39 gate reads `GET /vehicles` at startup and blocks Home (back-nav disabled) until the first car exists.
- **Maintenance extras**: totals and oil-change-due banner computed from maintenance records; PDF export is client-side, handed to the OS share sheet.

The error and DI contracts above are the current repo pattern; the deferred codegen alternatives live in [ROADMAP](../../docs/ROADMAP.md).

> ‏عقدا الأخطاء وحقن التبعيات أعلاه هما النمط الحالي في المستودع، وبدائل توليد الكود المؤجّلة موثّقة في [ROADMAP](../../docs/ROADMAP.md).

## API endpoints / نقاط نهاية الـ API

Base `/api/v1`, Sanctum bearer, envelope `{success, data, meta?}`. All shipped on the backend; none is wired in the app yet.

> ‏القاعدة `/api/v1`، مصادقة Sanctum بحامل، والمغلّف `{success, data, meta?}`. كل النقاط منشورة على الواجهة الخلفية، ولم تُربط أي منها في التطبيق بعد.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/vehicles` | List own vehicles (also feeds the #39 onboarding gate) | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| POST | `/vehicles` | Add vehicle (201; first is auto `is_primary`) | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| GET | `/vehicles/{id}` | Vehicle detail | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| PUT | `/vehicles/{id}` | Edit vehicle | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| DELETE | `/vehicles/{id}` | Soft-delete vehicle (undo snackbar in app) | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| POST | `/vehicles/{id}/primary` | Set primary (exactly one primary enforced) | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| GET | `/vehicles/{id}/maintenance` | List maintenance records (owner-scoped, 404 foreign) | [backend #55](https://github.com/YoussefSalem582/osta_backend/issues/55) | Planned |
| POST | `/vehicles/{id}/maintenance` | Add record (multipart receipt → private S3, signed URLs) | [backend #55](https://github.com/YoussefSalem582/osta_backend/issues/55) | Planned |
| GET | `/vehicles/{id}/maintenance/export` | Branded maintenance-history PDF | [backend #55](https://github.com/YoussefSalem582/osta_backend/issues/55) | Planned |

Vehicle fields (backend #54): brand, model, year, plate, VIN, fuel/transmission enums, current_mileage, is_primary. Completed bookings auto-create `source=booking` maintenance records via a `BookingCompleted` listener (backend #55).

> ‏حقول السيارة (backend #54): الماركة والموديل والسنة واللوحة ورقم الشاسيه وأنواع الوقود وناقل الحركة والممشى الحالي وعلامة السيارة الأساسية. الحجوزات المكتملة تُنشئ تلقائيًا سجلات صيانة بالمصدر `source=booking` عبر مستمع `BookingCompleted` (backend #55).

## Packages & shared widgets / الحزم والمكوّنات المشتركة

- **Planned package** (from the epic, not yet in `pubspec.yaml`): `dropdown_search` — brand/model pickers in the add/edit form.
- **Existing shared UI to reuse** (`lib/shared/ui/`): `AppCard` (vehicle cards), `AppButton`, `AppTextField` (form), `AppBottomSheet` (add/edit sheet), `AppTopBar`, `EmptyState` / `ErrorState` / `LoadingState` (list states).
- **Formatters** (`lib/shared/formatters/app_formatters.dart`): `EgpFormatter` for maintenance costs and totals, `NumberFormatter` for mileage (ar_EG Arabic-Indic digits).
- **l10n**: all strings via `context.l10n` (ARB in `lib/l10n/`, Arabic default, RTL-first).

New user-facing strings go in both ARB files and are picked up by `flutter gen-l10n` (the only codegen step in this repo).

> ‏أي نصوص جديدة تظهر للمستخدم تُضاف في ملفَّي ARB معًا ويلتقطها `flutter gen-l10n` (خطوة توليد الكود الوحيدة في هذا المستودع).

## Testing expectations / توقعات الاختبار

- **Widget tests**: from the related #39 gate — empty `GET /vehicles` shows the AddFirstCarScreen and blocks Home; plus list/detail/form coverage for the garage flows. Specific case list TBD — see epic [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50).
- **Golden tests**: follow the design-system pattern from epic #29 — light/dark × RTL/LTR per screen.
- **Unit tests**: repository/Cubit logic (soft-delete + undo, set-primary, maintenance totals and oil-change-due computation), using the existing hand-written fakes pattern in `test/core/network/fakes.dart` (no mockito/mocktail).

Tests run with `flutter test` — the CI runs a single "format · analyze · test" job, so keep `dart format .`, `flutter analyze`, and `flutter test` green locally.

> ‏تُشغَّل الاختبارات بأمر `flutter test` — وتشغّل الـ CI مهمة واحدة باسم "format · analyze · test"، فحافظ على نظافة `dart format .` و`flutter analyze` و`flutter test` محليًا.

## Related docs / روابط ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Roadmap — deferred tooling plan](../../docs/ROADMAP.md)
- Sibling features: [Required car onboarding](car-onboarding.md) · [Home dashboard](home-dashboard.md) · [Account & More hub](account-more.md)
