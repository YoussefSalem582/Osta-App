> [INDEX](../INDEX.md) > [Features](README.md) > Home dashboard (hybrid feed)

# 🏠 Home Dashboard — Hybrid Feed / الشاشة الرئيسية — واجهة هجينة

## Overview / نظرة عامة

The customer Home tab is a hybrid feed and the default landing screen after login and the required add-car gate. It aggregates the most useful next actions in one scroll: the customer's active booking (if any), a prominent "book a service" call-to-action, a horizontal strip of nearby service centers, shop highlights (featured products), and a shortcut to the user's cars. The full-screen map is deliberately demoted to a floating action button in the customer navigation — discovery lives on the map screen, while Home stays action-oriented. Specified by epic [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51); the feature folder `lib/features/customer/home/` is currently an empty stub, so everything below is planned, not built.

> ‏تبويب "الرئيسية" للعميل هو واجهة هجينة وشاشة الهبوط الافتراضية بعد تسجيل الدخول وإضافة السيارة الإلزامية. يجمع أهم الإجراءات التالية في شاشة واحدة: الحجز النشط الحالي (إن وُجد)، وزر بارز لحجز خدمة، وشريط أفقي لمراكز الخدمة القريبة، وأبرز منتجات المتجر، واختصار لسيارات المستخدم. الخريطة الكاملة أصبحت زرًا عائمًا في شريط التنقل بدلًا من تبويب مستقل. هذه الميزة محددة في القضية [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51)، ومجلد الميزة ما زال فارغًا — كل ما يلي مخطَّط وغير مُنفَّذ بعد.

## Status & Issues / الحالة والقضايا

The issue below tracks the Home feed; the four backend endpoints it aggregates are already shipped and marked ready.

> ‏القضية التالية تتابع واجهة الرئيسية؛ ونقاط النهاية الأربع التي تجمعها مُنفَّذة بالفعل ومُعلَّمة كجاهزة.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51) | Home dashboard (hybrid feed) | Open | Home | p1 | adel | [backend #45](https://github.com/YoussefSalem582/osta_backend/issues/45) (bookings list), [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) (nearby discovery), [backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52) (products browse), [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) (vehicles) — all closed, **ready** |

No dedicated backend epic mirrors Home: the feed is a pure aggregation of endpoints already shipped by the four closed backend epics above, so the app work is unblocked.

> ‏لا يوجد epic خلفي مخصص للرئيسية: الواجهة مجرد تجميع لنقاط نهاية سبق تسليمها في الـ epics الأربعة المغلقة أعلاه، لذا عمل التطبيق غير محجوب.

## Screens / Mockups / الشاشات والنماذج

### Home tab / تبويب الرئيسية

![Home tab](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/07-home-tab.png)

## Planned architecture / البنية المخطَّطة

`lib/features/customer/home/` exists as an empty `data/domain/presentation` stub today — no Dart files yet. Planned shape (Clean Architecture, per epic #51 and repo conventions):

> ‏مجلد `lib/features/customer/home/` موجود اليوم كهيكل فارغ `data/domain/presentation` بلا أي ملفات Dart. الشكل المخطَّط (بنية نظيفة، حسب الـ epic ‏#51 وأعراف المستودع):

- **Presentation**: a `HomePage` inside the customer shell composed of independent feed sections — `ActiveBookingCard`, `BookServiceCta`, `NearbyCentersStrip`, shop highlights, and a my-cars shortcut — each backed by Cubit/Bloc state so one failing section degrades gracefully (shared `ErrorState`/`EmptyState`/`LoadingState`) without blanking the whole feed. Exact cubit split is TBD — see epic.

> ‏**العرض**: صفحة `HomePage` داخل غلاف العميل، مؤلَّفة من أقسام مستقلة — `ActiveBookingCard` و`BookServiceCta` و`NearbyCentersStrip` وأبرز منتجات المتجر واختصار سياراتي — كل قسم مدعوم بحالة Cubit/Bloc خاصة به، بحيث يتدهور القسم الفاشل بلطف (عبر `ErrorState`/`EmptyState`/`LoadingState` المشتركة) دون إفراغ الواجهة كلها. تقسيم الـ cubit النهائي لم يُحسم — راجع الـ epic.

- **Data flow**: repositories in `data/` call the envelope-aware `ApiClient` (`lib/core/network/api_client.dart`), which returns `ApiResult<T>` or throws typed `ApiException`s. Repositories catch those and rethrow a `sealed class Failure` (`lib/core/error/failure.dart` — `NetworkFailure`/`ServerFailure`/`UnknownFailure`); cubits handle results with plain `try`/`catch`. No `Either`, no `.fold()`, no `Result<T>` typedef — the functional-error stack (`fpdart`) is deferred (see [ROADMAP](../../docs/ROADMAP.md), Phase 5).

> ‏**تدفق البيانات**: المستودعات في `data/` تستدعي `ApiClient` المدرك للمغلَّف (`lib/core/network/api_client.dart`)، الذي يُرجع `ApiResult<T>` أو يرمي `ApiException` مُصنَّفًا. تلتقط المستودعات هذه الاستثناءات وتعيد رمي `sealed class Failure` (`lib/core/error/failure.dart` — `NetworkFailure`/`ServerFailure`/`UnknownFailure`)، وتتعامل الـ cubits مع النتائج عبر `try`/`catch` عادي. لا `Either` ولا `.fold()` ولا `Result<T>` — مكدس الأخطاء الوظيفي (`fpdart`) مؤجَّل (راجع [ROADMAP](../../docs/ROADMAP.md)، المرحلة 5).

- **DI**: cubits and repositories are registered by hand through `get_it` — a `registerLazySingleton` line each in `configureDependencies()` (`lib/core/di/injection.dart`, global `getIt`), the same manual pattern as the existing `ThemeModeController`/`ApiClient` registrations. No annotations and no `build_runner`; the `injectable` codegen path is deferred (see [ROADMAP](../../docs/ROADMAP.md), Phases 1–3).

> ‏**حقن التبعيات**: تُسجَّل الـ cubits والمستودعات يدويًا عبر `get_it` — سطر `registerLazySingleton` لكل منها داخل `configureDependencies()` (`lib/core/di/injection.dart`، الـ `getIt` العام)، بنفس النمط اليدوي لتسجيلات `ThemeModeController`/`ApiClient` الحالية. بلا تعليقات توضيحية وبلا `build_runner`؛ مسار توليد `injectable` مؤجَّل (راجع [ROADMAP](../../docs/ROADMAP.md)، المراحل 1–3).

- **Models**: response models are plain `class X extends Equatable` with hand-written `fromJson`/`toJson`/`props` (pattern: `lib/features/auth/data/models/auth_token_model.dart`). No `@freezed`, no `@JsonSerializable`, no `*.g.dart`/`*.freezed.dart` — code generation is deferred (see [ROADMAP](../../docs/ROADMAP.md), Phases 1–3); only l10n is generated.

> ‏**النماذج**: نماذج الاستجابة عبارة عن `class X extends Equatable` بسيطة مع `fromJson`/`toJson`/`props` مكتوبة يدويًا (النمط: `lib/features/auth/data/models/auth_token_model.dart`). بلا `@freezed` ولا `@JsonSerializable` ولا `*.g.dart`/`*.freezed.dart` — توليد الشيفرة مؤجَّل (راجع [ROADMAP](../../docs/ROADMAP.md)، المراحل 1–3)؛ الشيء الوحيد المُولَّد هو l10n.

- **Routing**: `/home` becomes the customer shell's default branch under the planned `StatefulShellRoute` (epic [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)), reached only after login ([app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)) and the required car-onboarding gate ([app #39](https://github.com/YoussefSalem582/Osta-App/issues/39)). Today's `AppRouter` only knows `/splash` and `/role` (paths are `static const path` on the page widgets). The map opens from a center FAB in the customer bottom nav ([app #41](https://github.com/YoussefSalem582/Osta-App/issues/41)).

> ‏**التوجيه**: يصبح `/home` الفرع الافتراضي لغلاف العميل ضمن `StatefulShellRoute` المخطَّط (الـ epic ‏[app #34](https://github.com/YoussefSalem582/Osta-App/issues/34))، ولا يُوصَل إليه إلا بعد تسجيل الدخول (‏[app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)) وبوابة إضافة السيارة الإلزامية (‏[app #39](https://github.com/YoussefSalem582/Osta-App/issues/39)). الـ `AppRouter` الحالي لا يعرف سوى `/splash` و`/role` (المسارات معرَّفة كـ `static const path` على ودجت الصفحات). الخريطة تُفتح من زر عائم مركزي في شريط التنقل السفلي للعميل (‏[app #41](https://github.com/YoussefSalem582/Osta-App/issues/41)).

## API endpoints / نقاط نهاية الـ API

The endpoints below are the four already-shipped reads the feed aggregates.

> ‏نقاط النهاية التالية هي القراءات الأربع المُنفَّذة بالفعل التي تجمعها الواجهة.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/bookings?status=active` | Active booking card | [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51) / [backend #45](https://github.com/YoussefSalem582/osta_backend/issues/45) | Planned |
| GET | `/service-centers/nearby` | Nearby centers strip | [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51) / [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) | Planned |
| GET | `/products?featured=1` | Shop highlights carousel | [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51) / [backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| GET | `/vehicles` | My-cars shortcut (cars list) | [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51) / [backend #54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |

Contract notes: the shipped backend paths differ slightly from the epic's shorthand — discovery is served at `GET /centers/nearby` (backend #41), the bookings listing documents `status=upcoming|past` (backend #45), and the products browse (backend #52) documents `q`/`category` filters without a `featured` flag. Final query-param alignment is TBD — see epic [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51).

> ‏ملاحظات على العقد: المسارات الخلفية المُنفَّذة تختلف قليلًا عن اختصار الـ epic — الاكتشاف يُقدَّم على `GET /centers/nearby` (backend #41)، وقائمة الحجوزات توثِّق `status=upcoming|past` (backend #45)، وتصفح المنتجات (backend #52) يوثِّق مرشِّحات `q`/`category` بلا علامة `featured`. مواءمة معاملات الاستعلام النهائية لم تُحسم — راجع الـ epic ‏[app #51](https://github.com/YoussefSalem582/Osta-App/issues/51).

## Packages & shared widgets / الحزم والودجت المشتركة

**Planned packages** (from the epic, not yet in `pubspec.yaml`):

> ‏**حزم مخطَّطة** (من الـ epic، ليست في `pubspec.yaml` بعد):

- `carousel_slider` — shop highlights / horizontal strips.

**Already available and to be reused:**

> ‏**متاحة بالفعل ويُعاد استخدامها:**

- `cached_network_image` (already a dependency) for center and product imagery.
- Shared UI (`lib/shared/ui/`): `AppCard`, `AppButton`, `AppTopBar`, `AppBottomNavBar` (+ `AppBottomNavItem`, where the map FAB sits), `EmptyState` / `ErrorState` / `LoadingState`.
- Formatters (`lib/shared/formatters/app_formatters.dart`): `EgpFormatter` for product prices, `NumberFormatter` (ar_EG Arabic-Indic digits).
- `context.l10n` (`lib/shared/extensions/context_ext.dart`) — no hardcoded strings; ARB keys in `lib/l10n/`.

## Testing expectations / توقعات الاختبار

Per epic [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51):

> ‏حسب الـ epic ‏[app #51](https://github.com/YoussefSalem582/Osta-App/issues/51):

- **Widget tests per feed section** — each section renders its loaded, empty, and error states independently.
- **Golden tests** — RTL/LTR × light/dark matrix, following the design-system pattern established in epic [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).
- Existing network fakes (`test/core/network/fakes.dart`) can back repository unit tests.

## Related docs / وثائق ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Tooling roadmap](../../docs/ROADMAP.md)
- [Features index](README.md)
- Sibling features feeding the Home feed: [Booking funnel](booking-funnel.md) · [Map screen](map-discovery.md) · [My Garage](garage.md) · [Shop](shop.md)
