> [INDEX](../INDEX.md) > [Features](README.md) > Service Center Profile

# 🏬 Service Center Profile / Details — ملف مركز الخدمة

## Overview / نظرة عامة

The service center profile is the customer-facing detail page for a workshop, dealership, or other service center: a header card (name, type, rating, working hours, address) sits above **Services / Reviews / About** tabs plus a Shop strip that surfaces the center's products. It includes an image/product carousel and quick actions to call or WhatsApp the center. Customers arrive here from the map screen ([app #41](https://github.com/YoussefSalem582/Osta-App/issues/41)) or search results and continue into the booking funnel ([app #44](https://github.com/YoussefSalem582/Osta-App/issues/44)). Specified by epic [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42) — nothing is built yet; `lib/features/customer/map/` is an empty stub.

> ‏ملف مركز الخدمة هو صفحة التفاصيل الموجهة للعميل لأي ورشة أو توكيل أو مركز خدمة: بطاقة رأسية (الاسم، النوع، التقييم، ساعات العمل، العنوان) فوق تبويبات **الخدمات / التقييمات / عن المركز** بالإضافة إلى شريط المتجر الذي يعرض منتجات المركز. تتضمن الصفحة عارض صور/منتجات دوّارًا وإجراءات سريعة للاتصال أو التواصل عبر واتساب. يصل العميل إلى هذه الصفحة من شاشة الخريطة أو نتائج البحث ويكمل منها إلى مسار الحجز. الميزة محددة في الـ epic رقم ‎#42 — لم يُبنَ منها شيء بعد؛ مجلد الميزة لا يزال فارغًا.

## Status & Issues / الحالة والمهام

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42) | Service center profile | OPEN | M2 | p1 | adel | [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) ✅ closed — **ready** (profile/services/reviews/availability) · [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) ✅ closed — **ready** (services catalog CRUD feeding public list) |

Related backend context: the Shop strip's products come from the Shop domain ([backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52), closed) — `GET /centers/{id}/products` was deferred from backend #42 to Shop #52 and is now available. All backend endpoints this screen needs are merged, so the app work is unblocked.

> ‏سياق الـ backend المرتبط: منتجات شريط المتجر تأتي من نطاق الـ Shop (backend #52، مُغلق) — نقطة النهاية `GET /centers/{id}/products` أُجّلت من backend #42 إلى Shop #52 وأصبحت متاحة الآن. كل نقاط نهاية الـ backend التي تحتاجها هذه الشاشة مدمجة، ومن ثم فعمل التطبيق غير محجوب.

## Screens / Mockups / الشاشات والتصاميم

| Screen | Mockup |
|---|---|
| Center profile & details | ![Center profile and details](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/09-center-profile-and-details.png) |

## Planned architecture / المعمارية المخطط لها

Everything below is **planned** per epic [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42). The feature folder `lib/features/customer/map/` exists as an empty stub (no dart files); center profile lives in the map/discovery feature area alongside [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41) and [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43).

> ‏كل ما يلي **مخطط له** حسب الـ epic رقم ‎#42. مجلد الميزة `lib/features/customer/map/` موجود كهيكل فارغ (بدون ملفات dart)؛ ملف مركز الخدمة يقع في منطقة ميزة الخريطة/الاستكشاف جنبًا إلى جنب مع app #41 و app #43.

The codebase intentionally uses **plain, readable Dart with no code generation** so a team new to Flutter can be productive quickly. Advanced tooling (freezed, json_serializable, injectable, fpdart) is **deferred, not rejected** — see the phased plan in [`docs/ROADMAP.md`](../../docs/ROADMAP.md). This feature will follow the same plain-Dart conventions.

> ‏تعتمد قاعدة الكود عمدًا على **Dart بسيط وواضح بدون توليد كود** حتى يكون الفريق الجديد على Flutter مُنتِجًا بسرعة. الأدوات المتقدمة (freezed و json_serializable و injectable و fpdart) **مؤجّلة لا مرفوضة** — راجع الخطة المرحلية في `docs/ROADMAP.md`. هذه الميزة ستتبع نفس أعراف الـ Dart البسيط.

- **Layers (Clean Architecture)** — `data → domain ← presentation` inside `lib/features/customer/map/`:
  - `data/`: plain `Equatable` models with hand-written `fromJson`/`toJson` for the center detail, service, review (with rating breakdown), availability, and product payloads (no `@freezed`, no `part '*.g.dart'`); a repository implementation calling `ApiClient` (`lib/core/network/api_client.dart`), which unwraps the `{success, data, meta?}` envelope into `ApiResult<T>` and throws typed `ApiException`s (404 `NotFoundException` for inactive centers).
  - `domain/`: a repository contract that **throws** a `Failure` (`sealed class Failure implements Exception` in `core/error/failure.dart`) on error; callers use plain `try`/`catch` — no `Either`, no `Result<T>`, no `.fold()`.
  - `presentation/`: a center-profile Bloc/Cubit per tab data source (center header, services, paginated reviews with `PaginationMeta`, availability, products), plus the tabbed profile page. Blocs `try`/`catch` the repository's `Failure` and emit an error state. Exact cubit split is TBD — see epic.
- **DI**: repository and cubits registered by **hand** in `configureDependencies()` (`core/di/injection.dart`) with `getIt.registerLazySingleton(...)` — no `injectable`, no annotations, no `build_runner`. Add one registration line per new service.
- **Routing**: a `go_router` route under the customer shell (shells themselves are planned in [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)); today the router only has `/splash` and `/role`. Entry points: map marker bottom dialog "Details" button (#41) and search results (#43); the "Book" action hands off to the booking funnel (#44). Route path TBD — see epic.
- **Localization**: all strings via `context.l10n` (ARB, Arabic default, RTL-first); prices rendered with `EgpFormatter` and counts with `NumberFormatter` (Arabic-Indic digits under `ar`).

## API endpoints / نقاط نهاية الـ API

Base `/api/v1`, Sanctum bearer, `{success, data, meta?}` envelope. All backend work is merged; nothing is wired in the app yet.

> ‏القاعدة `/api/v1`، مصادقة Sanctum bearer، وغلاف `{success, data, meta?}`. كل عمل الـ backend مدمج؛ لم يُربَط شيء في التطبيق بعد.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/centers/{center}` | Center header: name, type, rating, hours, address (+`services_count`/`reviews_count`); inactive centers 404 | [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) | Planned |
| GET | `/centers/{center}/services` | Services tab (active services only) | [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) / [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Planned |
| GET | `/centers/{center}/reviews?page=` | Reviews tab, paginated + `meta.summary {rating, count}` rating breakdown | [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) | Planned |
| GET | `/centers/{center}/availability?date=YYYY-MM-DD` | Slot availability `{date, timezone, is_open, slots[{start,end,available}]}` — feeds Book action | [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) | Planned |
| GET | `/centers/{id}/products` | Shop strip (center-owned products) | [backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |

## Packages & shared widgets / الحزم والودجت المشتركة

**Planned packages** (from epic [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42), not yet in `pubspec.yaml`):

> ‏حزم مخطط لها (من الـ epic رقم ‎#42، غير موجودة بعد في `pubspec.yaml`):

| Package | Use |
|---|---|
| `carousel_slider` | Gallery + products carousel |
| `url_launcher` | Call / WhatsApp quick actions |

**Existing shared components to reuse** (`lib/shared/`):

> ‏مكوّنات مشتركة موجودة يُعاد استخدامها (`lib/shared/`):

- `AppTopBar` (RTL-safe app bar), `AppCard` (header card, service/review cards), `AppButton` (Book / call actions), `AppBottomSheet` (marker/summary dialogs)
- `EmptyState` / `ErrorState` / `LoadingState` (`shared/ui/status_states.dart`) for each tab's async states
- `EgpFormatter` / `NumberFormatter` (`shared/formatters/app_formatters.dart`) for prices and rating counts
- `context.l10n` extension (`shared/extensions/context_ext.dart`)
- `cached_network_image` (already a dependency) for gallery and product images

## Testing expectations / توقعات الاختبار

From the epic and repo conventions — all TBD until implementation:

> ‏من الـ epic وأعراف المستودع — كلها غير محددة حتى التنفيذ:

- **Unit**: repository/cubit tests mapping envelope responses to states, including 404 (inactive center) surfaced as a `NotFoundException` → `Failure` caught by the bloc → `ErrorState`, and paginated reviews via `PaginationMeta`. Reuse the fakes pattern in `test/core/network/fakes.dart`.
- **Widget**: tabbed page renders header + Services/Reviews/About tabs and Shop strip; empty/error states per tab.
- **Golden**: light/dark × RTL/LTR per the design-system pattern established by [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).

## Related docs / وثائق ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Tooling roadmap](../../docs/ROADMAP.md)
- Sibling features: [Map & discovery](map-discovery.md) · [Home dashboard](home-dashboard.md) · [Car onboarding](car-onboarding.md) · [Auth](auth.md)
