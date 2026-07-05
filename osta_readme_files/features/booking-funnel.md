> [INDEX](../INDEX.md) > [Features](README.md) > Booking Funnel

# 📅 Booking Funnel (Cash MVP) — مسار الحجز

## Overview / نظرة عامة

The booking funnel takes a customer from a chosen service to a confirmed pay-at-center booking in four steps: pick a service → pick a live slot from the center's availability → a 10-minute hold with a countdown → review the booking, attach a vehicle, and confirm with `payment_method = pay_at_center` (cash MVP — online payments arrive later with [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46)). The slot hold is enforced server-side (`hold_expires_at = now + 10m`, released by a delayed job), and the confirm step needs a duplicate-submit guard. Specified by epic [app #44](https://github.com/YoussefSalem582/Osta-App/issues/44) — nothing is built yet; `lib/features/customer/booking/` is an empty stub.

> ‏يأخذ مسار الحجز العميل من خدمة مختارة إلى حجز مؤكد بالدفع في المركز عبر أربع خطوات: اختيار الخدمة ← اختيار موعد متاح مباشرةً من مواعيد المركز ← حجز مؤقت لمدة ١٠ دقائق مع عدّاد تنازلي ← مراجعة الحجز وربط السيارة والتأكيد بطريقة الدفع «ادفع في المركز» (النسخة الأولية نقدًا — الدفع الإلكتروني يأتي لاحقًا). يُفرض الحجز المؤقت من جانب الخادم ويُحرَّر تلقائيًا بعد انتهاء المهلة، وتحتاج خطوة التأكيد إلى حماية من الإرسال المكرر. الميزة محددة في الـ epic رقم ‎#44 — لم يُبنَ منها شيء بعد؛ مجلد الميزة لا يزال فارغًا.

## Status & Issues / الحالة والمهام

> ‏الجدول التالي يلخّص حالة المهمة على مستوى التطبيق والخادم.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #44](https://github.com/YoussefSalem582/Osta-App/issues/44) | Booking funnel (cash MVP) | OPEN | M3 | p0 | roaa | [backend #43](https://github.com/YoussefSalem582/osta_backend/issues/43) ✅ closed — **ready** (booking creation + 10-min hold, 409 `slot_taken`) · [backend #44](https://github.com/YoussefSalem582/osta_backend/issues/44) ✅ closed — **ready** (confirm / reschedule / cancel state machine) |

Related backend context: slot availability comes from the discovery domain ([backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42), closed) and the vehicle picker from vehicles CRUD ([backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54), closed). The whole backend M3 booking milestone is merged, so the app work is unblocked.

> ‏سياق الخادم المرتبط: تأتي المواعيد المتاحة من نطاق الاكتشاف (backend #42، مُغلق) ويأتي اختيار السيارة من إدارة السيارات (backend #54، مُغلق). مرحلة الحجز M3 على الخادم مدموجة بالكامل، لذا عمل التطبيق غير محظور.

## Screens / Mockups / الشاشات والتصاميم

| Screen | Mockup |
|---|---|
| Booking flow & tracking | ![Booking flow and tracking](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/11-booking-flow-and-tracking.png) |
| Package & price | ![Package and price](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/10-package-and-price.png) |

## Planned architecture / البنية المخطّطة

Everything below is **planned** per epic [app #44](https://github.com/YoussefSalem582/Osta-App/issues/44). The feature folder `lib/features/customer/booking/` exists as an empty stub (no dart files); it will also host My bookings ([app #45](https://github.com/YoussefSalem582/Osta-App/issues/45)) and realtime status ([app #47](https://github.com/YoussefSalem582/Osta-App/issues/47)).

> ‏كل ما يلي **مخطّط** حسب الـ epic رقم ‎#44. مجلد الميزة موجود كهيكل فارغ (بدون ملفات dart)، وسيستضيف أيضًا «حجوزاتي» (app #45) والحالة اللحظية (app #47).

- **Layers (Clean Architecture)** — `data → domain ← presentation` inside `lib/features/customer/booking/`:
  - `data/`: plain `Equatable` models with hand-written `fromJson`/`toJson` (no codegen) for availability (`{date, timezone, is_open, slots[{start,end,available}]}`) and the booking payload/response; a repository implementation calling `ApiClient` (`lib/core/network/api_client.dart`), which unwraps the `{success, data, meta?}` envelope into `ApiResult<T>` and throws typed `ApiException`s. The 409 `slot_taken` conflict from `POST /bookings` must surface as a "slot just got taken, pick another" state, and 422 `ValidationException.fieldErrors` maps to the review form.
  - `domain/`: a repository contract whose methods **return the value directly and throw a `sealed Failure`** (`core/error/failure.dart`) on error — no `Either`, no `Result<T>`.
  - `presentation/`: a funnel Bloc/Cubit driving the step state (service → slot → hold countdown → review → confirmed) with plain `try`/`catch` around repository calls, a client-side countdown ticking against the server's `hold_expires_at`, and a **duplicate-submit guard** on the confirm action (disable + loading while the request is in flight). Exact cubit split is TBD — see epic.

> ‏الطبقات (Clean Architecture) داخل مجلد الميزة: طبقة `data` تحوي نماذج `Equatable` بسيطة مع `fromJson`/`toJson` مكتوبة يدويًا (بدون توليد كود) للمواعيد وحمولة الحجز، إضافةً إلى تنفيذ مستودع يستدعي `ApiClient` الذي يفكّ المُغلّف إلى `ApiResult<T>` ويرمي استثناءات `ApiException` مُصنّفة. تظاهر حالة تعارض 409 `slot_taken` كحالة «اتحجز دلوقتي، اختَر غيره»، وتُربَط أخطاء التحقق 422 بنموذج المراجعة. طبقة `domain` عبارة عن عقد مستودع تُرجِع دوالُّه القيمة مباشرةً وترمي `Failure` مُغلقة عند الخطأ — بدون `Either` وبدون `Result<T>`. طبقة `presentation` بها Bloc/Cubit يقود حالة الخطوات باستخدام `try`/`catch` بسيط، وعدّاد تنازلي على جانب العميل يقارن بـ `hold_expires_at`، وحماية من الإرسال المكرر على زر التأكيد.

- **Error handling**: repositories throw a `sealed class Failure implements Exception` (`NetworkFailure` / `ServerFailure` / `UnknownFailure`); the network layer throws typed `ApiException`s, the repository catches those and rethrows as a `Failure`, and the cubit catches `Failure` with plain `try`/`catch`. No `fpdart`, no `Either`, no `.fold()` — that functional layer is **deferred** ([ROADMAP Phase 5](../../docs/ROADMAP.md)).
- **DI**: repository and cubits registered by hand in `configureDependencies()` (`core/di/injection.dart`) with `getIt.registerLazySingleton<...>` / `registerFactory<...>` lines — **manual `get_it`, no `injectable`/`build_runner`**. Codegen DI is deferred (see [ROADMAP](../../docs/ROADMAP.md)).
- **Routing**: `go_router` routes under the customer shell (shells themselves are planned in [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)); today the router only has `/splash` and `/role`. Entry points: the "Book" action on the center profile ([app #42](https://github.com/YoussefSalem582/Osta-App/issues/42)) and map marker dialog ([app #41](https://github.com/YoussefSalem582/Osta-App/issues/41)); on success the flow hands off to My bookings (#45). Route paths TBD — see epic.
- **Localization**: all strings via `context.l10n` (ARB, Arabic default, RTL-first); prices with `EgpFormatter` and the countdown/slot times with `NumberFormatter` (Arabic-Indic digits under `ar`).

> ‏معالجة الأخطاء: يرمي المستودع `Failure` مُغلقة (`NetworkFailure` / `ServerFailure` / `UnknownFailure`)، وتُلتقَط استثناءات `ApiException` وتُحوَّل إلى `Failure`، ويلتقطها الـ cubit بـ `try`/`catch` بسيط — بدون `fpdart` أو `Either` أو `.fold()`؛ تلك الطبقة الوظيفية **مؤجّلة** (ROADMAP المرحلة 5). حقن التبعيات يُسجَّل يدويًا في `configureDependencies()` عبر `get_it` بدون `injectable` أو `build_runner`. المسارات تحت واجهة العميل عبر `go_router`؛ اليوم لا يملك الموجّه إلا `/splash` و `/role`. كل النصوص عبر `context.l10n` بالعربية افتراضيًا ومن اليمين لليسار، والأسعار بـ `EgpFormatter` والأوقات بـ `NumberFormatter`.

## API endpoints / نقاط النهاية

Base `/api/v1`, Sanctum bearer, `{success, data, meta?}` envelope. All backend work is merged; nothing is wired in the app yet. Note: the app epic sketches the create payload as `{service_id, slot, vehicle_id, payment_method=pay_at_center}`; the shipped backend contract ([backend #43](https://github.com/YoussefSalem582/osta_backend/issues/43)) is `{service_center_id, vehicle_id, service_ids[], slot_start}` with pay-at-center cash as the MVP default — follow the backend contract.

> ‏القاعدة `/api/v1` بمصادقة Sanctum ومُغلّف `{success, data, meta?}`. كل عمل الخادم مدموج ولم يُربَط شيء في التطبيق بعد. عند اختلاف حمولة الإنشاء في الـ epic عن العقد المُسلَّم، اتبع عقد الخادم.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/centers/{center}/availability?date=YYYY-MM-DD` | Live slot picker: `{date, timezone, is_open, slots[{start,end,available}]}` | [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) | Planned |
| GET | `/vehicles` | Vehicle picker on the review step (attach vehicle) | [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| POST | `/bookings` | Create booking → 201 with `status=pending`, `hold_expires_at=now+10m`; services snapshotted; 409 `slot_taken` on conflict | [backend #43](https://github.com/YoussefSalem582/osta_backend/issues/43) | Planned |
| POST | `/bookings/{id}/confirm` | Confirm the held booking (pay-at-center) | [backend #44](https://github.com/YoussefSalem582/osta_backend/issues/44) | Planned |

Cancel and reschedule (`POST /bookings/{id}/cancel`, `PATCH /bookings/{id}/reschedule`, also [backend #44](https://github.com/YoussefSalem582/osta_backend/issues/44)) belong to My bookings ([app #45](https://github.com/YoussefSalem582/Osta-App/issues/45)).

> ‏الإلغاء وإعادة الجدولة يخصّان «حجوزاتي» (app #45).

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages** (from epic [app #44](https://github.com/YoussefSalem582/Osta-App/issues/44), not yet in `pubspec.yaml`):

> ‏حزم مخطّطة من الـ epic، لم تُضَف بعد إلى `pubspec.yaml`.

| Package | Use |
|---|---|
| `table_calendar` | Date picker feeding the availability query |

**Existing shared components to reuse** (`lib/shared/`):

> ‏مكوّنات مشتركة موجودة يُعاد استخدامها من `lib/shared/`.

- `AppTopBar` (RTL-safe app bar), `AppCard` (service / slot / review summary cards), `AppButton` (confirm CTA — its built-in loading state doubles as the duplicate-submit guard), `AppBottomSheet` (slot / vehicle pickers)
- `EmptyState` / `ErrorState` / `LoadingState` (`shared/ui/status_states.dart`) for the availability and vehicles async states
- `EgpFormatter` / `NumberFormatter` (`shared/formatters/app_formatters.dart`) for prices and slot times
- `context.l10n` extension (`shared/extensions/context_ext.dart`)

## Testing expectations / توقّعات الاختبار

From the epic and repo conventions — all TBD until implementation:

> ‏من الـ epic وأعراف المستودع — الكل مؤجّل حتى التنفيذ.

- **Unit**: repository/cubit tests mapping envelope responses to states — 409 `slot_taken` → conflict state, hold countdown reaching zero → expired state, 422 field errors on the review form. Reuse the fakes pattern in `test/core/network/fakes.dart` (hand-written fakes + `http_mock_adapter`; no mockito/mocktail).
- **Widget**: full step flow renders; confirm button disables while submitting (duplicate-submit guard); expired hold blocks confirm.
- **Golden**: light/dark × RTL/LTR per the design-system pattern established by [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).

## Related docs / وثائق ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Tooling roadmap (deferred advanced tooling)](../../docs/ROADMAP.md)
- Sibling features: [Center profile](center-profile.md) · [Map & discovery](map-discovery.md) · [Car onboarding](car-onboarding.md) · [Home dashboard](home-dashboard.md)
