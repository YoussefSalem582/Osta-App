> [INDEX](../INDEX.md) > [Features](README.md) > Map, discovery, filters & search

# 🗺️ Map, Discovery, Filters & Search / الخريطة والاستكشاف والفلاتر والبحث

## Overview / نظرة عامة

The discovery surface lets a customer find nearby service centers on a full-screen Google Map, launched from the center FAB in the customer bottom navigation. Markers come from the nearby endpoint, a search bar and category chips sit on top of the map, and tapping a marker opens a bottom dialog with a center summary plus **Book** and **Details** actions. A filter sheet (shared between the Map and List views) narrows results by service type, max price, minimum rating, open-now and free text — results are always sorted rating-descending, with `type ∈ workshop | dealership | mobile | tire_shop | car_wash`. Everything in this doc is **planned**: the feature folder `lib/features/customer/map/` is currently an empty stub, while the backend discovery endpoints are already merged.

> ‏تتيح واجهة الاستكشاف للعميل العثور على مراكز الخدمة القريبة على خريطة Google بملء الشاشة، تُفتح من الزر العائم الأوسط في شريط التنقل السفلي. تأتي العلامات من نقطة نهاية «القريب مني»، ويعلو الخريطة شريط بحث وشرائح تصنيف، وعند الضغط على علامة يظهر حوار سفلي بملخص المركز مع زرّي «احجز» و«التفاصيل». وتضيّق ورقة الفلاتر (المشتركة بين الخريطة والقائمة) النتائج حسب نوع الخدمة والحد الأقصى للسعر والحد الأدنى للتقييم و«مفتوح الآن» والبحث الحر — مع ترتيب النتائج دائمًا تنازليًا حسب التقييم. كل ما في هذا المستند **مخطَّط له**: مجلد الميزة ما يزال فارغًا، بينما نقاط نهاية الاستكشاف في الخلفية مدموجة بالفعل.

## Status & Issues / الحالة والمهام

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41) | Map screen | Open | M2 | p0 | adel | [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) closed — **ready** |
| [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43) | Filters & search | Open | M2 | p1 | adel | [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) closed — **ready** |

Backend M2 Discovery ([backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) nearby + search, [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) center profile used by the marker-tap dialog) is fully merged, so the app side is **not blocked** — implementation can start against the live contract. Sibling app epic: [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42) (center profile, opened from the **Details** action).

> ‏نقاط نهاية الاستكشاف في الخلفية لمرحلة M2 مدموجة بالكامل (القريب مني والبحث في [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41)، وملف المركز في [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) الذي يستخدمه حوار الضغط على العلامة)، لذا فالجانب التطبيقي **غير محجوب** — ويمكن بدء التنفيذ مقابل العقد الحيّ. الملحمة الشقيقة في التطبيق: [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42) (ملف المركز، يُفتح من إجراء «التفاصيل»).

## Screens / Mockups / الشاشات والنماذج

### Map screen (markers, search bar, category chips, marker dialog) / شاشة الخريطة

Both epics share one mockup — [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43)'s filter chips are shown on the same screen.

> ‏الملحمتان تتشاركان نموذجًا واحدًا — تظهر شرائح الفلاتر الخاصة بـ [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43) على الشاشة نفسها.

![Map screen](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/08-map-screen.png)

## Planned architecture / البنية المخطَّطة

Nothing is built yet — `lib/features/customer/map/` exists only as empty `data/domain/presentation` stub directories. The plan, following the repo's Clean Architecture + BLoC conventions and its deliberately plain-Dart, no-codegen style (advanced tooling deferred — see [ROADMAP](../../docs/ROADMAP.md)):

> ‏لم يُبنَ شيء بعد — المجلد `lib/features/customer/map/` موجود فقط كمجلدات فارغة `data/domain/presentation`. والخطة تتبع أعراف المستودع في الـ Clean Architecture والـ BLoC، وأسلوبه المتعمَّد في كتابة Dart بسيطة بلا توليد كود (الأدوات المتقدمة مؤجَّلة — راجع [ROADMAP](../../docs/ROADMAP.md)):

- **Presentation** — full-screen map page reached from the center FAB in the customer `AppBottomNavBar` (the Home epic [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51) demotes the map to that FAB). State handled by `flutter_bloc` cubits (exact names TBD — see epics): one for the map/marker/search state, one for the filter-sheet selection applied to both Map and List results.
- **Domain / data** — a discovery repository that **throws** a sealed `Failure` on error and returns plain result objects on success (no `fpdart`, no `Either`, no `Result<T>`), mapping filter selections to query parameters. Models are plain `class ... extends Equatable` with hand-written `fromJson`/`toJson` — no `freezed`, no `json_serializable`, no generated `*.g.dart`.
- **Data flow** — repository → `ApiClient` in `lib/core/network/` (envelope-aware `get<T>` returning `ApiResult<T>` with `PaginationMeta`, typed `ApiException`s, bearer + 401 refresh handled by `AuthInterceptor`). Repositories catch `ApiException` and convert to a `Failure`; the cubit uses plain `try`/`catch`. No feature-level Dio usage.
- **DI** — one hand-written `registerLazySingleton` line per new service in `configureDependencies()` (`lib/core/di/injection.dart`, global `getIt`). Manual `get_it` registration, same pattern as the existing singletons — no `injectable`, no `build_runner`.
- **Routing** — a customer-shell route under the planned `StatefulShellRoute` from [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34). Today's `GoRouter` only knows `/splash` and `/role` (route paths are `static const path` on the page widgets); the map route path is TBD — see epic.
- **Device/platform** — location permission + current position via `geolocator` and `permission_handler`; marker clustering via `google_maps_cluster_manager_2`; light/dark map styles per theme mode ([app #41](https://github.com/YoussefSalem582/Osta-App/issues/41)).

> ‏**العرض** — صفحة خريطة بملء الشاشة يُوصَل إليها من الزر العائم الأوسط في `AppBottomNavBar` الخاص بالعميل. تُدار الحالة بـ cubits من `flutter_bloc`: واحدة لحالة الخريطة/العلامة/البحث، وأخرى لاختيار ورقة الفلاتر المطبَّق على نتائج الخريطة والقائمة معًا. **النطاق/البيانات** — مستودع استكشاف **يرمي** `Failure` مغلقة عند الخطأ ويُعيد كائنات نتيجة عادية عند النجاح (بلا `fpdart` وبلا `Either` وبلا `Result<T>`)، ونماذجه فئات عادية ترث `Equatable` مع `fromJson`/`toJson` مكتوبة يدويًا بلا توليد كود. **تدفق البيانات** — المستودع يمر عبر `ApiClient`، ويلتقط `ApiException` ويحوّلها إلى `Failure`، وتستعمل الـ cubit `try`/`catch` مباشرةً. **حقن التبعيات** — سطر `registerLazySingleton` واحد مكتوب يدويًا لكل خدمة جديدة داخل `configureDependencies()`. **التوجيه** — مسار ضمن `StatefulShellRoute` المخطَّط له؛ حاليًا يعرف `GoRouter` المسارين `/splash` و`/role` فقط.

## API endpoints / نقاط نهاية الـ API

All backend discovery endpoints are merged (backend M2 closed); nothing is wired in the app yet.

> ‏كل نقاط نهاية الاستكشاف في الخلفية مدموجة (أُغلقت مرحلة M2)، ولم يُربَط أي منها في التطبيق بعد.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/centers/nearby?lat&lng&category` | Markers near the user (nearest-first, `distance_meters`; backend also accepts `radius`, `service`, `price_max`, `min_rating`, `open_now`, `per_page`) | [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41) / [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) | **Planned** |
| GET | `/centers/search?q&category` (also `q&type` per filters epic) | Search bar + category chips (ilike on name/description/city/district; rating-ordered) | [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41), [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43) / [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) | **Planned** |
| GET | `/centers?type&price_max&min_rating&open_now&sort=rating_desc` | Filtered Map + List results (as written in the app epic; backend exposes these filters on `/centers/nearby` and `/centers/search` — exact path alignment TBD, see epic) | [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43) | **Planned** |
| GET | `/centers/{id}` | Marker-tap bottom dialog summary (Book / Details) | [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41) / [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) | **Planned** |

Legend: **Connected** = already called from `lib/core/network` (only auth login/refresh/social exchange today) · **Planned** = epic open, not yet wired · **Blocked** = backend epic not merged.

## Packages & shared widgets / الحزم والودجت المشتركة

**Planned packages** (from [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41), not yet in `pubspec.yaml`):

> ‏حزم مخطَّط لها (من [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41))، غير مضافة بعد إلى `pubspec.yaml`:

| Package | Why |
|---|---|
| `google_maps_flutter` | Full-screen map with light/dark styles |
| `geolocator` | Current position for `/centers/nearby` |
| `permission_handler` | Location permission flow |
| `google_maps_cluster_manager_2` | Marker clustering |

**Existing shared code to reuse** (already in the repo):

> ‏كود مشترك موجود يُعاد استخدامه (موجود بالفعل في المستودع):

- `AppTextField` — search bar input; `AppBottomSheet` — marker-tap dialog and the filter sheet; `AppCard` — center summary card; `AppButton` — Book / Details / Apply-filters actions.
- `EmptyState` / `ErrorState` / `LoadingState` (`shared/ui/status_states.dart`) — no-results, failed-request and loading surfaces.
- `EgpFormatter` / `NumberFormatter` (`shared/formatters/app_formatters.dart`) — price-max values and ratings with Arabic-Indic digits.
- `cached_network_image` (already a dependency) — center thumbnails in the summary dialog.
- `context.l10n` (`shared/extensions/context_ext.dart`) — all strings via ARB; no hardcoded text ([app #30](https://github.com/YoussefSalem582/Osta-App/issues/30)).

## Testing expectations / توقعات الاختبار

The epics do not enumerate an explicit test list; repo conventions apply:

> ‏لا تُعدّد الملاحم قائمة اختبارات صريحة؛ وتُطبَّق أعراف المستودع:

- **Widget tests** for the search bar, category chips, filter sheet (selection → query params) and marker-tap dialog, including empty/error states in both locales.
- **Golden tests** per the design-system pattern from [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29): light/dark × RTL/LTR for the filter sheet and center summary card.
- **Unit tests** for the discovery repository — envelope parsing, filter-to-query-param mapping, `ApiException` → `Failure` mapping — using the fakes pattern in `test/core/network/fakes.dart`.
- All gated by CI: the single **format · analyze · test** job (`flutter pub get` → `flutter gen-l10n` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`). No `build_runner` step.

## Related docs / مستندات ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Features index](README.md)
- Sibling feature docs: [Service center profile](center-profile.md) · [Home dashboard](home-dashboard.md) · [Booking funnel](booking-funnel.md)
