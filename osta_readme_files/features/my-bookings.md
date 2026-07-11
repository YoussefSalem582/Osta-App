> [INDEX](../INDEX.md) > [Features](README.md) > My bookings, booking detail & realtime status

# 📋 My Bookings, Detail & Realtime Status — حجوزاتي وتفاصيل الحجز والحالة اللحظية

## Overview / نظرة عامة

The customer's booking hub: a **My bookings** screen with Upcoming/Past tabs, and a **booking detail** screen showing a status timeline, payment method, booking reference, contact-the-center actions (call/chat), plus **cancel** and **reschedule** flows — specified by epic [app #45](https://github.com/YoussefSalem582/Osta-App/issues/45) (M3). On top of that, epic [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47) (M4) makes the status **live**: the detail screen subscribes to the private Reverb channel `bookings.{id}` via `pusher_channels_flutter`, with backoff reconnect, a polling fallback to `GET /bookings/{id}`, and reconcile-on-rejoin. The backend side is fully shipped ([backend #45](https://github.com/YoussefSalem582/osta_backend/issues/45), [#50](https://github.com/YoussefSalem582/osta_backend/issues/50), [#51](https://github.com/YoussefSalem582/osta_backend/issues/51) — all closed). The app feature folder `lib/features/customer/booking/` is currently an empty stub, so everything below is planned, not built.

> ‏مركز حجوزات العميل: شاشة **حجوزاتي** بتبويبَي "القادمة/السابقة"، وشاشة **تفاصيل الحجز** التي تعرض خطًا زمنيًا للحالة وطريقة الدفع ومرجع الحجز وأزرار التواصل مع المركز (اتصال/محادثة)، بالإضافة إلى **الإلغاء** و**إعادة الجدولة** — كما هو محدد في القضية [app #45](https://github.com/YoussefSalem582/Osta-App/issues/45) (المرحلة M3). وتضيف القضية [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47) (المرحلة M4) التحديث **اللحظي**: تشترك شاشة التفاصيل في القناة الخاصة `bookings.{id}` عبر Reverb باستخدام `pusher_channels_flutter`، مع إعادة اتصال تدريجية، والرجوع إلى الاستعلام الدوري `GET /bookings/{id}` عند انقطاع الاتصال، والمزامنة عند إعادة الانضمام. جانب الخادم مكتمل بالفعل (قضايا الخلفية ‎#45 و‎#50 و‎#51 — كلها مغلقة). مجلد الميزة `lib/features/customer/booking/` ما زال فارغًا، فكل ما يلي مخطَّط وغير مُنفَّذ بعد.

## Status & Issues / الحالة والقضايا

The customer-facing issues below are ready to build: the backend they depend on is closed and shipped.

> ‏القضايا الموجَّهة للعميل التالية جاهزة للتنفيذ: الخلفية التي تعتمد عليها مغلقة ومكتملة.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #45](https://github.com/YoussefSalem582/Osta-App/issues/45) | My bookings & detail | Open | M3 | p1 | roaa | [backend #45](https://github.com/YoussefSalem582/osta_backend/issues/45) (listing & detail) + [backend #44](https://github.com/YoussefSalem582/osta_backend/issues/44) (reschedule/cancel) — both closed, **ready** |
| [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47) | Realtime booking status | Open | M4 | p1 | roaa | [backend #50](https://github.com/YoussefSalem582/osta_backend/issues/50) (Reverb + channel auth) + [backend #51](https://github.com/YoussefSalem582/osta_backend/issues/51) (broadcast events) — both closed, **ready** |

Status changes are pushed from the business side: epic [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) (business bookings management) advances `confirmed → in_progress → completed`, and those transitions land on the customer's detail screen through the realtime channel. Epic [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) optionally surfaces a "Your technician" section on the customer booking detail.

> ‏تُدفع تغييرات الحالة من جانب النشاط التجاري: القضية [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) (إدارة حجوزات النشاط التجاري) تنقل الحالة `confirmed → in_progress → completed`، وتصل هذه التنقلات إلى شاشة تفاصيل العميل عبر القناة اللحظية. وتعرض القضية [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) اختياريًا قسم "الفني الخاص بك" في تفاصيل حجز العميل.

## Screens / Mockups / الشاشات والتصاميم

### My bookings (Upcoming / Past tabs + detail) / حجوزاتي (تبويبا القادمة/السابقة + التفاصيل)

![My bookings](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/13-my-bookings.png)

### Live booking status / حالة الحجز اللحظية

![Live booking status](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/14-live-booking-status.png)

## Planned architecture / البنية المخطَّطة

`lib/features/customer/booking/` exists as an empty `data/domain/presentation` stub today — no Dart files yet. Planned shape (Clean Architecture, per epics #45/#47 and repo conventions):

> ‏يوجد `lib/features/customer/booking/` حاليًا كهيكل فارغ من `data/domain/presentation` — بلا أي ملفات Dart بعد. الشكل المخطَّط (Clean Architecture، وفق القضيتين #45/#47 وأعراف المستودع):

- **Presentation**: a bookings-list page with Upcoming/Past tabs backed by a Cubit/Bloc per tab query (`GET /bookings?status=`), and a booking-detail page rendering the status timeline, payment method, reference, contact actions, and cancel/reschedule actions. Exact page/cubit names are TBD — see epic [app #45](https://github.com/YoussefSalem582/Osta-App/issues/45). Empty and error tab states use the shared `EmptyState`/`ErrorState`/`LoadingState`.
- **Realtime**: a `RealtimeService` wrapping `pusher_channels_flutter` ([app #47](https://github.com/YoussefSalem582/Osta-App/issues/47)) subscribes to `private-bookings.{id}` after authorizing via `POST /broadcasting/auth` (Sanctum, [backend #50](https://github.com/YoussefSalem582/osta_backend/issues/50)). The shipped event is `BookingStatusUpdated` with old/new status and a server timestamp ([backend #51](https://github.com/YoussefSalem582/osta_backend/issues/51); the app epic refers to it as `BookingStatusChanged`). The service implements backoff reconnect, a polling fallback to `GET /bookings/{id}`, and reconcile-on-rejoin; events are bound into the booking-detail Bloc so the timeline updates live. Status enum: `pending | confirmed | in_progress | completed | cancelled`.
- **Data flow**: repositories in `data/` call the envelope-aware `ApiClient` (`lib/core/network/api_client.dart`), which returns `ApiResult<T>` (with `PaginationMeta` for the paginated list) or throws typed `ApiException`s. Repositories catch those and **throw** a sealed `Failure` (`lib/core/error/failure.dart`); the Cubit/Bloc handles them with plain `try`/`catch`. No `Either`, no `.fold()`, no `Result<T>` — fpdart is deferred (see [ROADMAP](../../docs/ROADMAP.md), Phase 5).
- **DI**: repositories, cubits, and the `RealtimeService` are registered **manually** with `get_it` — one hand-written `registerLazySingleton` line each in `configureDependencies()` (`lib/core/di/injection.dart`), following the existing `ApiClient`/`ThemeModeController` pattern. No `injectable`, no `build_runner`; codegen-based DI is deferred (see [ROADMAP](../../docs/ROADMAP.md), Phases 1–3).
- **Routing**: bookings routes live inside the planned customer shell (`StatefulShellRoute`, epic [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)). Today's router only knows `/splash` and `/role` — exact booking paths are TBD — see epic. Bookings are created upstream by the booking funnel ([app #44](https://github.com/YoussefSalem582/Osta-App/issues/44)).

Models here are plain `Equatable` classes with hand-written `fromJson`/`toJson` (like `lib/features/auth/data/models/auth_token_model.dart`) — no `freezed`, no `@JsonSerializable`, no `*.g.dart`/`*.freezed.dart`. Model codegen is deferred (see [ROADMAP](../../docs/ROADMAP.md), Phases 1–3).

> ‏النماذج هنا عبارة عن فئات `Equatable` عادية مع `fromJson`/`toJson` مكتوبة يدويًا (على غرار `lib/features/auth/data/models/auth_token_model.dart`) — بلا `freezed` ولا `@JsonSerializable` ولا ملفات `*.g.dart`/`*.freezed.dart`. توليد كود النماذج مؤجَّل (راجع [ROADMAP](../../docs/ROADMAP.md)، المراحل 1–3).

## API endpoints / نقاط نهاية الـ API

The endpoints below back the tabs, the detail screen, cancel/reschedule, and realtime — the backend contract is unchanged and shipped.

> ‏نقاط النهاية التالية تُغذّي التبويبات وشاشة التفاصيل والإلغاء/إعادة الجدولة والتحديث اللحظي — عقد الخلفية لم يتغيّر وهو مكتمل.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/bookings?status=upcoming\|past` | Upcoming/Past tabs (paginated) | [app #45](https://github.com/YoussefSalem582/Osta-App/issues/45) / [backend #45](https://github.com/YoussefSalem582/osta_backend/issues/45) | Planned |
| GET | `/bookings/{id}` | Booking detail; also the polling fallback for realtime | [app #45](https://github.com/YoussefSalem582/Osta-App/issues/45), [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47) / [backend #45](https://github.com/YoussefSalem582/osta_backend/issues/45) | Planned |
| POST | `/bookings/{id}/cancel` | Cancel with reason (records `cancelled_by`, refund eligibility via cancellation window) | [app #45](https://github.com/YoussefSalem582/Osta-App/issues/45) / [backend #44](https://github.com/YoussefSalem582/osta_backend/issues/44) | Planned |
| PATCH | `/bookings/{id}/reschedule` | Reschedule `{scheduled_at}` (server re-runs availability) | [app #45](https://github.com/YoussefSalem582/Osta-App/issues/45) / [backend #44](https://github.com/YoussefSalem582/osta_backend/issues/44) | Planned |
| POST | `/broadcasting/auth` | Private-channel authorization (Sanctum; not under `/api/v1`) | [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47) / [backend #50](https://github.com/YoussefSalem582/osta_backend/issues/50) | Planned |
| WS | `private-bookings.{id}` | `BookingStatusUpdated` push (old/new status) | [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47) / [backend #51](https://github.com/YoussefSalem582/osta_backend/issues/51) | Planned |

The backend serves the detail via `BookingResource` / `BookingDetailResource` (items snapshot, status, `scheduled_at`, center + vehicle summaries) inside the standard `{success, data, meta?}` envelope.

> ‏تقدّم الخلفية التفاصيل عبر `BookingResource` / `BookingDetailResource` (لقطة العناصر، والحالة، و`scheduled_at`، وملخّصات المركز والمركبة) داخل الغلاف القياسي `{success, data, meta?}`.

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages** (from the epics, not yet in `pubspec.yaml`):

> ‏**الحزم المخطَّطة** (من القضايا، لم تُضَف بعد إلى `pubspec.yaml`):

- `pusher_channels_flutter` — Reverb (Pusher protocol) client inside `RealtimeService` ([app #47](https://github.com/YoussefSalem582/Osta-App/issues/47)).
- `url_launcher` — call-the-center action from booking detail (already planned across sibling epics, e.g. [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42)).

**Already available and to be reused:**

> ‏**متوفّرة بالفعل وسيُعاد استخدامها:**

- Shared UI (`lib/shared/ui/`): `AppCard` (booking cards), `AppButton` (cancel/reschedule actions), `AppTopBar`, `AppBottomSheet` (action sheets), `EmptyState` / `ErrorState` / `LoadingState` for tab states.
- `PaginationMeta` (`lib/core/network/api_client.dart`) for the paginated list.
- Formatters (`lib/shared/formatters/app_formatters.dart`): `EgpFormatter` for booking totals, `NumberFormatter` (ar_EG Arabic-Indic digits).
- `context.l10n` (`lib/shared/extensions/context_ext.dart`) — no hardcoded strings; ARB keys in `lib/l10n/`.

## Testing expectations / توقّعات الاختبار

- **Golden tests** ([app #45](https://github.com/YoussefSalem582/Osta-App/issues/45)): empty and error states, in RTL and dark mode, following the design-system pattern from epic [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).
- **Realtime coverage** ([app #47](https://github.com/YoussefSalem582/Osta-App/issues/47)): the reconnect/polling-fallback/reconcile behavior is Bloc-bound and should be unit-testable; the exact test matrix is TBD — see epic.
- Repository unit tests can reuse the existing network fakes (`test/core/network/fakes.dart`).

> ‏تُغطّي اختبارات golden الحالتين الفارغة والخطأ في وضعَي RTL والداكن، وتغطّي اختبارات الوحدة سلوك إعادة الاتصال والرجوع الدوري والمزامنة في الـ Bloc، مع إمكانية إعادة استخدام fakes الشبكة الموجودة.

## Related docs / روابط ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Features index](README.md)
- Sibling features: [Booking funnel](booking-funnel.md) (creates the bookings shown here) · [Payments](payments.md) (payment method on detail) · [Home dashboard](home-dashboard.md) (ActiveBookingCard deep-links here) · [Center profile](center-profile.md) (contact-the-center context)
