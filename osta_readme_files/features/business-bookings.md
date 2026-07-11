> [INDEX](../INDEX.md) > [Features](README.md) > Business bookings management & team assignment

# 🗓️ Business Bookings Management & Team Assignment — إدارة حجوزات المركز وتعيين الفنيين

## Overview / نظرة عامة

The service-center side of bookings: a bookings **list + calendar** view, a **detail sheet** showing the customer, vehicle, booked services and total, **accept / reject-with-reason** actions (reject is blocked until a reason is entered), and status advancement `confirmed → in_progress → completed` — specified by epic [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) (M3). Its companion epic [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) (M3) adds the **mechanics roster**: technicians (name, specialty, +20 phone, photo, active flag) managed from Business More → Business management, an **assign picker** on the booking detail listing active mechanics only, and reassign/unassign chips. Roster mechanics have **no login** of their own — this is not the Phase-2 solo-mechanic flow ([app #59](https://github.com/YoussefSalem582/Osta-App/issues/59)). Every status change the center makes pushes live to the customer's booking detail (ties into realtime epic [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47)). The backend is fully shipped ([backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) B2B booking ops + [backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64) mechanics roster — both closed), so nothing here is backend-blocked. The feature folders `lib/features/business/bookings/` and `lib/features/business/team/` are empty stubs today, so everything below is planned, not built.

> ‏الجانب الخاص بمركز الخدمة من الحجوزات: عرض **قائمة + تقويم** للحجوزات، و**ورقة تفاصيل** تعرض العميل والسيارة والخدمات المحجوزة والإجمالي، وإجراءا **القبول / الرفض مع ذكر السبب** (زر الرفض معطَّل حتى إدخال السبب)، وتقديم الحالة `confirmed → in_progress → completed` — كما هو محدد في القضية [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) (المرحلة M3). وتضيف القضية المرافقة [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) (المرحلة M3) **سجل الفنيين**: فنيون (الاسم، التخصص، هاتف ‎+20، الصورة، حالة التفعيل) تتم إدارتهم من «المزيد» في واجهة الأعمال ← إدارة الأعمال، مع **منتقي تعيين** في تفاصيل الحجز يعرض الفنيين النشطين فقط، وشرائح لإعادة التعيين/إلغائه. فنيو السجل **لا يملكون حساب دخول** — هذا يختلف عن مسار الميكانيكي المستقل في المرحلة الثانية ([app #59](https://github.com/YoussefSalem582/Osta-App/issues/59)). كل تغيير في الحالة يجريه المركز يصل مباشرةً إلى شاشة تفاصيل حجز العميل (بالارتباط مع قضية التحديث اللحظي [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47)). جانب الخادم مكتمل بالفعل (قضيتا الخلفية ‎#46 و‎#64 — كلتاهما مغلقتان)، فلا يوجد أي حظر من جهة الخادم. مجلدا الميزة `lib/features/business/bookings/` و`lib/features/business/team/` ما زالا فارغين، فكل ما يلي مخطَّط وغير مُنفَّذ بعد.

## Status & Issues / الحالة والقضايا

The two epics below drive this feature; both have their backend closed and ready.

> ‏القضيتان التاليتان تقودان هذه الميزة؛ وجانب الخادم لكلتيهما مغلق وجاهز.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) | Business bookings management | Open | M3 | p0 | haneen | [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) (B2B booking ops) — closed, **ready** |
| [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) | Business team & mechanics management | Open | M3 | p0 | haneen | [backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64) (center mechanics roster) — closed, **ready** (issue carries the `backend:ready` label) |

Adjacent epics: new bookings land live on the business dashboard ([app #54](https://github.com/YoussefSalem582/Osta-App/issues/54), M4) over the WS channel `centers.{id}`; the customer sees status transitions through [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47); and [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) optionally surfaces a "Your technician" section on the customer booking detail ([app #45](https://github.com/YoussefSalem582/Osta-App/issues/45)).

> ‏قضايا مجاورة: الحجوزات الجديدة تظهر مباشرةً على لوحة تحكم الأعمال ([app #54](https://github.com/YoussefSalem582/Osta-App/issues/54)، المرحلة M4) عبر قناة الـ WS ‏`centers.{id}`؛ ويرى العميل انتقالات الحالة من خلال [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47)؛ وتُظهر [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) اختياريًا قسم «الفني الخاص بك» في تفاصيل حجز العميل ([app #45](https://github.com/YoussefSalem582/Osta-App/issues/45)).

## Screens / Mockups / الشاشات والتصاميم

### Bookings management (list + calendar + detail sheet) / إدارة الحجوزات

![Bookings management](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/25-bookings-management.png)

### Assign technician to booking / تعيين فني للحجز

![Assign technician to booking](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/32-assign-technician-to-booking.png)

### Team — add technicians / الفريق — إضافة فنيين

![Team — add technicians](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/29-team-add-technicians.png)

### Add or edit technician / إضافة أو تعديل فني

![Add or edit technician](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/31-add-or-edit-technician.png)

### Team permissions / صلاحيات الفريق

![Team permissions](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/30-team-permissions.png)

## Planned architecture / البنية المخطَّطة

`lib/features/business/bookings/` and `lib/features/business/team/` exist as empty stub directories today — no Dart files yet. Planned shape (layered feature structure, per epics #55/#62 and repo conventions):

> ‏مجلدا `lib/features/business/bookings/` و`lib/features/business/team/` موجودان اليوم كدليلَين فارغين — بلا أي ملفات Dart بعد. الشكل المخطَّط (بنية ميزة ذات طبقات، حسب القضيتين #55/#62 وأعراف المستودع):

- **Presentation (bookings, #55)**: a bookings page with list and calendar views backed by a Cubit/Bloc querying `GET /business/bookings?date=&status=&per_page=`; tapping a booking opens a detail sheet (shared `AppBottomSheet`) with customer, vehicle, services and total, plus accept, reject-with-reason (submit blocked until a reason is entered), status-advance, and assign-mechanic actions. Exact page/cubit names are TBD — see epic [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55).
- **Presentation (team, #62)**: `MechanicsManagementScreen` (roster list with active flags) reached via Business More → Business management, a mechanic form sheet (name, specialty, +20 phone, optional photo via `image_picker`), an empty-state CTA, and the assign picker on the booking detail showing **active mechanics only**, with reassign/unassign chips.
- **Status machine**: statuses are `pending | confirmed | in_progress | completed | cancelled | invoiced`; transitions are gated server-side by `canTransitionTo` ([backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46)). Assignment requires an active, same-center mechanic (422 otherwise); `mechanic_id: null` unassigns ([backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64)). `BookingResource` includes `assigned_mechanic {id, name, specialty}`.
- **Realtime**: transitions made here are broadcast to the customer as `BookingStatusUpdated` on the private channel `bookings.{id}` ([backend #51](https://github.com/YoussefSalem582/osta_backend/issues/51), consumed by [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47)); incoming `BookingCreated` events on `centers.{id}` are the business dashboard's concern ([app #54](https://github.com/YoussefSalem582/Osta-App/issues/54)).
- **Data flow**: repositories in `data/` call the envelope-aware `ApiClient` (`lib/core/network/api_client.dart`), which returns `ApiResult<T>` (with `PaginationMeta` for the paginated list) or throws typed `ApiException`s (e.g. `ValidationException` with `fieldErrors` for the 422 assign/reject cases). Repositories catch those and, on failure, throw a `sealed Failure` (`lib/core/error/failure.dart` — `NetworkFailure` / `ServerFailure` / `UnknownFailure`); the Cubit/Bloc wraps the call in a plain `try`/`catch` and maps the caught `Failure` to an error state. No `fpdart`, no `Either`, no `Result<T>`, no `.fold()` — functional error types are **deferred** ([ROADMAP Phase 5](../../docs/ROADMAP.md)).
- **DI**: Cubits and repositories are registered by hand with `get_it` — one `registerLazySingleton` line each in `configureDependencies()` (`lib/core/di/injection.dart`, global `getIt`). No `injectable`, no `build_runner`, no `injection.config.dart`; DI codegen is **deferred** ([ROADMAP Phases 1–3](../../docs/ROADMAP.md)).
- **Models**: `BookingModel` / `MechanicModel` will be plain `class X extends Equatable` with hand-written `fromJson` / `toJson` / `props` (pattern: `lib/features/auth/data/models/auth_token_model.dart`). No `@freezed`, no `@JsonSerializable`, no `part '*.g.dart'` / `part '*.freezed.dart'`; model codegen is **deferred** ([ROADMAP Phases 1–3](../../docs/ROADMAP.md)).
- **Routing**: both screens live inside the planned business/provider shell (`StatefulShellRoute` landing on `/dashboard`, epic [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)). Today's router only knows `/splash` and `/role` (route paths are `static const path` on the page widgets) — exact paths are TBD — see epic.

## API endpoints / نقاط نهاية الـ API

The endpoints below are shipped and closed on the backend; the app status is "Planned" only because the Flutter feature folders are still stubs.

> ‏نقاط النهاية التالية مُنفَّذة ومغلقة على الخادم؛ وحالة التطبيق «مخطَّط» فقط لأن مجلدات ميزة Flutter ما زالت فارغة.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/business/bookings?date=&status=&per_page=` | Bookings list + calendar day query (paginated) | [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) / [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/accept` | Accept a pending booking | [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) / [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/reject` | Reject with `{reason}` (UI blocks until reason entered) | [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) / [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/status` | Advance `{status}` (`confirmed → in_progress → completed`, `canTransitionTo` gate) | [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) / [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/assign-mechanic` | `{mechanic_id\|null}` — assign/reassign; `null` unassigns; 422 if not an active same-center mechanic | [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55), [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) / [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46), [backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64) | Planned |
| GET | `/business/mechanics?active=` | Roster list; assign picker uses `active=true` | [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62), [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) / [backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64) | Planned |
| POST | `/business/mechanics` | Add mechanic (name, specialty, optional +20 phone, optional photo) | [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) / [backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64) | Planned |
| PATCH | `/business/mechanics/{id}` | Edit mechanic (incl. `is_active` toggle) | [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) / [backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64) | Planned |
| DELETE | `/business/mechanics/{id}` | Remove mechanic (soft delete) | [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) / [backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64) | Planned |

All responses use the standard `{success, data, meta?}` envelope under `/api/v1` with Sanctum auth.

> ‏كل الاستجابات تستخدم الغلاف القياسي ‏`{success, data, meta?}` تحت المسار ‏`/api/v1` مع مصادقة Sanctum.

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages** (from the epics, not yet in `pubspec.yaml`):

> ‏حزم مخطَّطة (من القضايا، وليست بعد في `pubspec.yaml`):

- `image_picker` — mechanic photo in the form sheet ([app #62](https://github.com/YoussefSalem582/Osta-App/issues/62)).
- Calendar view widget for the bookings list — package choice is TBD — see epic [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) (`table_calendar` is already planned for the customer booking funnel, [app #44](https://github.com/YoussefSalem582/Osta-App/issues/44)).

**Already available and to be reused:**

> ‏متاح بالفعل وسيُعاد استخدامه:

- Shared UI (`lib/shared/ui/`): `AppCard` (booking + mechanic cards), `AppButton` (accept/reject/assign actions), `AppBottomSheet` (detail sheet, mechanic form sheet), `AppTopBar`, `AppTextField` (reject reason, mechanic form fields), `EmptyState` / `ErrorState` / `LoadingState` (empty roster CTA, list states).
- `PaginationMeta` (`lib/core/network/api_client.dart`) for the paginated bookings list.
- Formatters (`lib/shared/formatters/app_formatters.dart`): `EgpFormatter` for booking totals, `NumberFormatter` (ar_EG Arabic-Indic digits).
- `context.l10n` (`lib/shared/extensions/context_ext.dart`) — no hardcoded strings; ARB keys in `lib/l10n/`.

## Testing expectations / توقعات الاختبار

- **Golden tests** ([app #62](https://github.com/YoussefSalem582/Osta-App/issues/62)): light/dark + RTL for the team screens, following the design-system pattern from epic [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).
- **Cubit unit tests**: reject action stays blocked until a reason is entered ([app #55](https://github.com/YoussefSalem582/Osta-App/issues/55)); status transitions; assign picker exposes active mechanics only ([app #62](https://github.com/YoussefSalem582/Osta-App/issues/62)). Exact matrix for #55 is TBD — see epic.
- Repository unit tests can reuse the existing network fakes (`test/core/network/fakes.dart`), including 422 `ValidationException` mapping for reject/assign, asserting the repository throws the expected `Failure` from a plain `try`/`catch`.

> ‏تُعيد اختبارات المستودع استخدام مزيّفات الشبكة القائمة (`test/core/network/fakes.dart`)، بما في ذلك تحويل `ValidationException` عند الخطأ 422 لحالتي الرفض/التعيين، مع التحقق من أن المستودع يرمي الـ `Failure` المتوقَّع عبر `try`/`catch` بسيط.

## Related docs / مستندات ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Features index](README.md)
- Sibling features: [My bookings](my-bookings.md) (customer side that receives status pushes and the optional "Your technician" section) · [Booking funnel](booking-funnel.md) (creates the bookings managed here) · [Business dashboard](business-dashboard.md) (live new-booking feed + accept/reject shortcuts) · [Notifications](notifications.md) (booking-status push)
