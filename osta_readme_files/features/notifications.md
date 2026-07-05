> [INDEX](../INDEX.md) > [Features](README.md) > Notifications

# 🔔 Notifications Inbox & FCM Push / صندوق الإشعارات والتنبيهات الفورية

## Overview / نظرة عامة

OSTA's notifications feature (epic [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52), milestone M7) delivers an in-app inbox with read/unread state plus FCM push notifications to **both** shells — CUSTOMER and BUSINESS. Push covers booking status changes, shop enquiries, and replies, and tapping a notification deep-links to the relevant screen whether the app is in the foreground, background, or terminated. The backend side ([backend #59](https://github.com/YoussefSalem582/osta_backend/issues/59)) is already merged: device-token registration, a paginated notifications inbox, mark-as-read, bilingual templates, and fan-out over mail + FCM + database. On the app side nothing is built yet — `lib/features/notifications/` contains only empty `data/`, `domain/`, and `presentation/` directories.

> ‏ميزة الإشعارات في أُسطى (الملف [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52)، مرحلة M7) توفّر صندوق إشعارات داخل التطبيق بحالة مقروء/غير مقروء، بالإضافة إلى تنبيهات فورية عبر FCM لكلا الواجهتين — العميل ومقدّم الخدمة. تغطي التنبيهات تغييرات حالة الحجز واستفسارات المتجر والردود، وعند الضغط على الإشعار ينتقل المستخدم مباشرة إلى الشاشة المناسبة سواء كان التطبيق في المقدمة أو الخلفية أو مغلقًا. جانب الخادم ([backend #59](https://github.com/YoussefSalem582/osta_backend/issues/59)) مكتمل ومدمج بالفعل، أما جانب التطبيق فلم يُبنَ بعد — مجلد الميزة ما زال فارغًا.

## Status & Issues / الحالة والمهام

The table below tracks the app epic and its ready backend dependency.

> ‏الجدول التالي يتتبّع ملف التطبيق واعتماده على الخادم الجاهز.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52) | Notifications + FCM push | Open | M7 | p2 | youssef | [backend #59](https://github.com/YoussefSalem582/osta_backend/issues/59) — **ready** (closed: FCM devices + notifications inbox merged) |

Backend #59 shipped a custom `FcmChannel` (Firebase Admin HTTP v1), queued fan-out to mail + FCM + database, bilingual notification templates, and dead-token pruning — so the app work is unblocked.

> ‏سلّم الخادم #59 قناة `FcmChannel` مخصّصة (Firebase Admin HTTP v1) مع توزيع مُصفوف عبر البريد وFCM وقاعدة البيانات، وقوالب إشعارات ثنائية اللغة، وتنظيف الرموز الميتة — لذا فإن عمل التطبيق غير محجوب.

## Screens / Mockups / الشاشات والتصاميم

| Screen | Mockup |
|---|---|
| Notifications inbox & push | ![Notifications and push](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/18-notifications-and-push.png) |

## Planned architecture / البنية المخطّطة

Everything below is **planned / specified by epic [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52)** — `lib/features/notifications/` is currently a stub (empty `data/`, `domain/`, `presentation/` directories, no Dart files).

> ‏كل ما يلي **مخطّط / محدّد بواسطة الملف [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52)** — مجلد `lib/features/notifications/` حاليًا مجرّد هيكل فارغ (مجلدات `data/` و`domain/` و`presentation/` بدون أي ملفات Dart).

Following the repo's Clean Architecture layering (data → domain ← presentation) and BLoC/Cubit conventions:

> ‏اتباعًا لطبقات العمارة النظيفة في المستودع (data → domain ← presentation) وأعراف BLoC/Cubit:

- **Presentation** — a notifications inbox page listing items with read/unread state, driven by a notifications Cubit/Bloc (`flutter_bloc`). The inbox serves both role shells (customer and business). An unread badge can surface on the shell nav via the existing `AppBottomNavItem` badge support.
- **Domain** — a plain repository contract (an abstract class) whose methods **throw** a `sealed Failure` from `core/error/failure.dart` on error and return the plain domain type on success. No `Either`, no `Result<T>`, no `fpdart` — callers use ordinary `try`/`catch`.
- **Data** — a repository implementation calling the shared envelope-aware `ApiClient` (`core/network/api_client.dart`), which yields `ApiResult<T>` with `PaginationMeta` for the paginated inbox and maps errors to the typed `ApiException` hierarchy. The repository catches those `ApiException`s and rethrows them as a `Failure` (`NetworkFailure` / `ServerFailure` / `UnknownFailure`). Notification models are plain `class ... extends Equatable` with hand-written `fromJson` / `toJson` / `props` matching the backend payload `{id, type, title, body, data, read_at, created_at}` — no `freezed`, no `@JsonSerializable`, no generated `*.g.dart` / `*.freezed.dart`. (Codegen for models is deferred — see [ROADMAP](../../docs/ROADMAP.md).)
- **Push pipeline** — `firebase_messaging` obtains the FCM device token, which the app registers with `POST /devices {token, platform}`; `flutter_local_notifications` displays notifications while the app is foregrounded. Tap handlers cover all three app states (foreground / background / terminated) and deep-link through `go_router` to the relevant screen (e.g. booking status → booking detail, enquiry/reply → shop). Exact deep-link route mapping: TBD — see epic.
- **DI** — the repository, Cubit, and push services are registered by hand in `configureDependencies()` (`core/di/injection.dart`) with a `getIt.registerLazySingleton(...)` line each. No `injectable`, no annotations, no `build_runner` step. (Automatic DI codegen is deferred — see [ROADMAP](../../docs/ROADMAP.md).)
- **Routing** — the inbox route and deep-link targets hook into `core/router/app_router.dart`; today the router only defines `/splash` and `/role` (role paths are `static const path` on the page widgets, and the role shells are themselves planned under [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)).

> ‏تفصيلًا للطبقات: **العرض (Presentation)** صفحة صندوق إشعارات تعرض العناصر بحالة مقروء/غير مقروء يقودها Cubit/Bloc عبر `flutter_bloc`، ويخدم الصندوق واجهتَي العميل ومقدّم الخدمة، مع إمكانية إظهار شارة غير المقروء على شريط التنقّل عبر `AppBottomNavItem`. **النطاق (Domain)** عقد مستودع بسيط (صنف مجرّد) ترمي دواله `sealed Failure` عند الخطأ وتعيد النوع البسيط عند النجاح — بلا `Either` أو `Result<T>` أو `fpdart`، ويعتمد المستدعون على `try`/`catch` العادي. **البيانات (Data)** تنفيذ المستودع يستدعي `ApiClient` المدرك للمغلّف الذي يُنتج `ApiResult<T>` مع `PaginationMeta` للصندوق المُصفَّح، ويلتقط `ApiException` ثم يعيد رميه كـ `Failure`؛ ونماذج الإشعارات أصناف بسيطة ترث `Equatable` مع `fromJson` / `toJson` / `props` مكتوبة يدويًا — بلا `freezed` أو توليد كود (توليد كود النماذج مؤجّل، انظر [ROADMAP](../../docs/ROADMAP.md)). **خط الدفع (Push)** يجلب `firebase_messaging` رمز الجهاز فيسجّله التطبيق عبر `POST /devices`، ويعرض `flutter_local_notifications` الإشعارات في المقدمة، وتغطي معالِجات الضغط الحالات الثلاث وتنتقل عبر `go_router` للشاشة المناسبة. **الحقن (DI)** تُسجَّل الخدمات يدويًا في `configureDependencies()` بسطر `registerLazySingleton` لكل خدمة — بلا `injectable` أو `build_runner` (التوليد الآلي مؤجّل، انظر [ROADMAP](../../docs/ROADMAP.md)). **التوجيه (Routing)** تتصل مسارات الصندوق بـ `core/router/app_router.dart` الذي يعرّف اليوم `/splash` و`/role` فقط.

## API endpoints / نقاط نهاية الـ API

All under base `/api/v1`, Sanctum bearer auth, standard `{success, data, meta?}` envelope. Backend implementation is merged (backend #59); the app has not wired any of them yet.

> ‏كلها تحت المسار الأساسي `/api/v1`، بمصادقة Sanctum bearer ومغلّف قياسي `{success, data, meta?}`. تنفيذ الخادم مدمج (backend #59)، لكن التطبيق لم يربط أيًّا منها بعد.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/notifications` | Paginated inbox `{id, type, title, body, data, read_at, created_at}` | [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52) / [backend #59](https://github.com/YoussefSalem582/osta_backend/issues/59) | Planned |
| POST | `/notifications/{id}/read` | Mark a notification as read | [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52) / [backend #59](https://github.com/YoussefSalem582/osta_backend/issues/59) | Planned |
| POST | `/devices` | Register FCM device token `{token, platform}` | [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52) / [backend #59](https://github.com/YoussefSalem582/osta_backend/issues/59) | Planned |
| DELETE | `/devices/{token}` | Deregister a device token (backend supports dead-token pruning) | [backend #59](https://github.com/YoussefSalem582/osta_backend/issues/59) | Planned |

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages** (from the epic; not yet in `pubspec.yaml`):

> ‏حزم مخطّطة (من الملف؛ ليست بعد في `pubspec.yaml`):

| Package | Role |
|---|---|
| `firebase_core` | Firebase bootstrap |
| `firebase_messaging` | FCM token + push message handling (foreground/background/terminated) |
| `flutter_local_notifications` | Displaying notifications while the app is in the foreground |

**Existing shared components to reuse** (`lib/shared/ui/`):

> ‏مكوّنات مشتركة قائمة لإعادة الاستخدام (`lib/shared/ui/`):

- `AppTopBar` — RTL-safe top bar for the inbox page.
- `AppBottomNavBar` / `AppBottomNavItem` — badge support for unread counts on the shell nav.
- `AppCard` — notification list item container.
- `EmptyState` / `ErrorState` / `LoadingState` (`status_states.dart`) — inbox empty, error, and loading states.
- `context.l10n` (`shared/extensions/context_ext.dart`) — all strings via ARB localization (Arabic default, RTL-first).

## Testing expectations / توقّعات الاختبار

Epic #52 does not enumerate a test matrix — specifics TBD, see the epic. Repo conventions that apply:

> ‏لا يُعدّد الملف #52 مصفوفة اختبار — التفاصيل لاحقًا، انظر الملف. الأعراف السارية في المستودع:

- **Unit** — repository and Cubit tests exercising `ApiClient` envelope parsing, pagination, and error mapping (asserting the repository throws the right `Failure`), following the existing patterns in `test/core/network/` (hand-written fakes in `test/core/network/fakes.dart`, `http_mock_adapter`). No mockito/mocktail.
- **Widget** — inbox rendering with read/unread items plus empty/error/loading states in both locales.
- **Golden** — light/dark × RTL/LTR per the design-system pattern established by epic [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).

## Related docs / مستندات ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Tooling roadmap](../../docs/ROADMAP.md) — phased reintroduction of deferred tooling (codegen, DI generation, functional errors, build flavors, CI matrix)
- Sibling features: [Booking](my-bookings.md) (status pushes reference booking detail), [Shop](shop.md) (enquiry/reply pushes)
