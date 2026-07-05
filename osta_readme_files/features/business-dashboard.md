> [INDEX](../INDEX.md) > [Features](README.md) > Business dashboard

# 📊 Business dashboard (provider shell home) / لوحة تحكم الأعمال

## Overview / نظرة عامة

The business dashboard is the landing screen of the provider (BUSINESS) shell — routed as `/dashboard` once role-aware routing ([app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)) sends `me.type = business` into the ProviderShell. It shows today's booking counters (pending / confirmed / in_progress / completed), a revenue snapshot in EGP, an actionable new-booking list with accept/reject, and a day timeline. It updates live over the Reverb websocket channel `centers.{id}` (`BookingCreated` event) using `pusher_channels_flutter`. Specified by epic [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54); nothing is built yet — `lib/features/business/dashboard/` is an empty stub.

> ‏لوحة تحكم الأعمال هي الشاشة الرئيسية لواجهة مقدّم الخدمة (BUSINESS)، ويتم الوصول إليها عبر المسار `/dashboard` بعد التوجيه حسب الدور. تعرض عدّادات حجوزات اليوم (قيد الانتظار / مؤكَّدة / جارية / مكتملة)، وملخّص الإيرادات بالجنيه المصري، وقائمة الحجوزات الجديدة مع إمكانية القبول أو الرفض، بالإضافة إلى جدول زمني لليوم. تتحدّث الشاشة لحظيًا عبر قناة Reverb ‏`centers.{id}`. الميزة موصوفة في الـ epic ‏[app #54](https://github.com/YoussefSalem582/Osta-App/issues/54) ولم يتم بناؤها بعد — مجلد الميزة حاليًا فارغ.

## Status & Issues / الحالة والمهام

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54) | Business dashboard | Open | M4 | p0 | haneen | [backend #51](https://github.com/YoussefSalem582/osta_backend/issues/51) (broadcast events + B2B dashboard, closed) + [backend #50](https://github.com/YoussefSalem582/osta_backend/issues/50) (Reverb setup + channel auth, closed) — **ready** |

Booking accept/reject actions reuse the B2B booking-ops API from [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) (closed — also ready), shared with the [Business bookings management](business-bookings.md) epic [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55).

> ‏تُعيد إجراءات قبول ورفض الحجز استخدام واجهة عمليات الحجوزات B2B من [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) (مغلق — جاهز أيضًا)، وهي مشتركة مع الـ epic ‏[app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) الخاص بإدارة حجوزات الأعمال.

## Screens / Mockups / الشاشات والتصاميم

**Business dashboard**

![Business dashboard](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/24-business-dashboard.png)

## Planned architecture / البنية المخطَّطة

Everything below is **planned** — `lib/features/business/dashboard/` currently contains no Dart files.

> ‏كل ما يلي **مخطَّط له** فقط — مجلد `lib/features/business/dashboard/` لا يحتوي حاليًا على أي ملفات Dart.

- **Clean Architecture layers** (repo standard, data → domain ← presentation): a data source calling the existing envelope-aware `ApiClient` (`lib/core/network/api_client.dart`), a repository that **throws** a `sealed Failure` (`lib/core/error/failure.dart`) on error while callers use plain `try`/`catch`, and presentation Cubits/Blocs (`flutter_bloc` 9) for dashboard state — counters + revenue snapshot, the actionable new-booking list, and the day timeline. Exact class names TBD — see epic.
- **Realtime**: subscribe to private channel `centers.{id}` for `BookingCreated` via `pusher_channels_flutter`, authenticated through `POST /broadcasting/auth` (Sanctum). The realtime layer follows the same pattern as [Realtime booking status](my-bookings.md) ([app #47](https://github.com/YoussefSalem582/Osta-App/issues/47)): backoff reconnect, polling fallback, reconcile on rejoin, events bound into the Bloc.
- **Data flow**: REST fetch on load (dashboard counters, revenue, booking list) → websocket events prepend new bookings live → accept/reject mutations go through `ApiClient` and refresh the affected list item.
- **DI**: register the data source / repository / cubits by **hand** in `configureDependencies()` (`lib/core/di/injection.dart`) with `get_it` — one `registerLazySingleton` line each, same as the existing network registrations. No `injectable`, no `build_runner` (deferred — see [ROADMAP](../../docs/ROADMAP.md)).
- **Routing**: dashboard is the ProviderShell's initial tab at `/dashboard`, mounted under the planned `StatefulShellRoute` from role-aware routing ([app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)). Today `app_router.dart` only defines `/splash` and `/role` — no shells exist yet.

> ‏طبقات **Clean Architecture** (المعيار المتّبع في المستودع، data → domain ← presentation): مصدر بيانات يستدعي `ApiClient` القائم والمُدرِك للمُغلَّف، ومستودع **يرمي** ‏`sealed Failure` عند الخطأ بينما يستخدم المستدعون ‏`try`/`catch` مباشرةً، وطبقة عرض بـ Cubits/Blocs لحالة اللوحة. لا يوجد `Either` ولا `Result<T>` ولا `.fold()`. أما التسجيل في حاوية الاعتمادات فيتم **يدويًا** في ‏`configureDependencies()` بسطر `registerLazySingleton` لكل خدمة، بدون `injectable` أو `build_runner` (مؤجَّلة — راجع [ROADMAP](../../docs/ROADMAP.md)). واللوحة هي التبويب الأول لواجهة مقدّم الخدمة عند المسار `/dashboard`، والموجَّه حاليًا يعرّف `/splash` و`/role` فقط دون أي أطراف (shells) بعد.

## API endpoints / نقاط نهاية الـ API

Base `/api/v1`, Sanctum bearer, `{success, data, meta?}` envelope.

> ‏القاعدة `/api/v1`، مع توثيق Sanctum عبر bearer، والاستجابة داخل المُغلَّف `{success, data, meta?}`.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/business/dashboard` | Today counters + revenue snapshot (`{counts: {today, pending, completed}, revenue}`) | [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54) / [backend #51](https://github.com/YoussefSalem582/osta_backend/issues/51) | Planned |
| GET | `/business/bookings?date=&status=&per_page=` | New-booking list + day timeline data | [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54) / [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/accept` | Accept a pending booking from the dashboard | [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54) / [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/reject` | Reject a pending booking (with reason) | [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54) / [backend #46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| GET | `/business/kpis` | KPI figures (listed in app epic; not in the backend endpoint catalogue — TBD, see epic) | [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54) | Planned |
| POST | `/broadcasting/auth` (not under `/api/v1`) | Sanctum auth for private websocket channels | [backend #50](https://github.com/YoussefSalem582/osta_backend/issues/50) | Planned |
| WS | `private-centers.{id}` → `BookingCreated` | Live new-booking push to the center dashboard | [backend #50](https://github.com/YoussefSalem582/osta_backend/issues/50) / [backend #51](https://github.com/YoussefSalem582/osta_backend/issues/51) | Planned |

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages** (from the epic, not yet in `pubspec.yaml`):

> ‏حزم **مخطَّط لها** (من الـ epic، غير مضافة بعد إلى `pubspec.yaml`):

| Package | Why |
|---|---|
| `pusher_channels_flutter` | Reverb (Pusher protocol) client for the `centers.{id}` live channel |

**Existing shared components to reuse** (`lib/shared/`):

> ‏مكوّنات مشتركة قائمة يُعاد استخدامها من `lib/shared/`:

- `AppTopBar` + `AppBottomNavBar` — provider shell chrome (RTL-safe, badge support).
- `AppCard` — counter tiles, revenue snapshot, booking list items.
- `AppButton` — accept/reject actions (primary/secondary variants with loading state).
- `EmptyState` / `ErrorState` / `LoadingState` (`status_states.dart`) — feed states.
- `EgpFormatter` / `NumberFormatter` (`shared/formatters/app_formatters.dart`) — EGP revenue and counters with Arabic-Indic digits under `ar_EG`.
- `context.l10n` — all strings via ARB (Arabic default, RTL-first).

## Testing expectations / متطلّبات الاختبار

The epic does not enumerate a test matrix ("TBD — see epic [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54)"). Per repo conventions:

> ‏الـ epic لا يعدّد مصفوفة اختبارات محدّدة ("TBD — راجع الـ epic ‏[app #54](https://github.com/YoussefSalem582/Osta-App/issues/54)"). ووفق أعراف المستودع:

- **Unit**: cubit tests for counters/revenue/booking-list state, including websocket-event handling and the polling fallback path.
- **Widget**: per dashboard section (counters, revenue snapshot, new-booking list with accept/reject, day timeline) plus empty/error states — pattern used by the sibling home-feed epic #51.
- **Golden**: light/dark × RTL/LTR, following the design-system pattern from [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).

## Related docs / وثائق ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Business bookings management](business-bookings.md) — accept/reject/status/assign flows the dashboard links into
- [Realtime booking status](my-bookings.md) — shared Reverb/websocket infrastructure
- [Business onboarding & registration](business-onboarding.md) — how a center reaches the dashboard for the first time
- [Tooling roadmap](../../docs/ROADMAP.md) — phased plan for the deferred codegen / flavors / CI matrix
