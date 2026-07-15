> [INDEX](../INDEX.md) > [Features](README.md) > Map, discovery, filters & search

# 🗺️ Map, Discovery, Filters & Search / الخريطة والاستكشاف والفلاتر والبحث

## Overview / نظرة عامة

The discovery surface lets a customer find nearby service centers on a full-screen Google Map, launched from the center FAB in the customer bottom navigation. Markers come from the nearby endpoint, a search bar and category chips sit on top of the map, and tapping a marker opens a bottom dialog with a center summary plus **Book** and **Details** actions. A filter sheet (shared between the Map and List views) narrows results by service type, max price, minimum rating, open-now and free text — results are always sorted rating-descending, with `type ∈ workshop | dealership | mobile | tire_shop | car_wash`. **The map screen ([app #41](https://github.com/YoussefSalem582/Osta-App/issues/41)) is built** as of 2026-07-15 — `lib/features/customer/map/` is a real feature wired to the live `nearby`/`search` endpoints. The **filter sheet ([app #43](https://github.com/YoussefSalem582/Osta-App/issues/43)) is still planned**; today's map ships only the four category chips, not the type/price/rating/open-now sheet.

> ‏تتيح واجهة الاستكشاف للعميل العثور على مراكز الخدمة القريبة على خريطة Google بملء الشاشة، تُفتح من الزر العائم الأوسط في شريط التنقل السفلي. تأتي العلامات من نقطة نهاية «القريب مني»، ويعلو الخريطة شريط بحث وشرائح تصنيف، وعند الضغط على علامة يظهر حوار سفلي بملخص المركز مع زرّي «احجز» و«التفاصيل». وتضيّق ورقة الفلاتر (المشتركة بين الخريطة والقائمة) النتائج حسب نوع الخدمة والحد الأقصى للسعر والحد الأدنى للتقييم و«مفتوح الآن» والبحث الحر — مع ترتيب النتائج دائمًا تنازليًا حسب التقييم. كل ما في هذا المستند **مخطَّط له**: مجلد الميزة ما يزال فارغًا، بينما نقاط نهاية الاستكشاف في الخلفية مدموجة بالفعل.

## Status & Issues / الحالة والمهام

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41) | Map screen | **Built 2026-07-15** | M2 | p0 | adel | [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) closed — **ready** |
| [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43) | Filters & search | Open | M2 | p1 | adel | [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) closed — **ready** |

Backend M2 Discovery ([backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) nearby + search, [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) center profile used by the marker-tap dialog) is fully merged, so the app side is **not blocked** — implementation can start against the live contract. Sibling app epic: [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42) (center profile, opened from the **Details** action).

> ‏نقاط نهاية الاستكشاف في الخلفية لمرحلة M2 مدموجة بالكامل (القريب مني والبحث في [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41)، وملف المركز في [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) الذي يستخدمه حوار الضغط على العلامة)، لذا فالجانب التطبيقي **غير محجوب** — ويمكن بدء التنفيذ مقابل العقد الحيّ. الملحمة الشقيقة في التطبيق: [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42) (ملف المركز، يُفتح من إجراء «التفاصيل»).

## Screens / Mockups / الشاشات والنماذج

### Map screen (markers, search bar, category chips, marker dialog) / شاشة الخريطة

Both epics share one mockup — [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43)'s filter chips are shown on the same screen.

> ‏الملحمتان تتشاركان نموذجًا واحدًا — تظهر شرائح الفلاتر الخاصة بـ [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43) على الشاشة نفسها.

![Map screen](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/08-map-screen.png)

## Architecture as built / البنية المنفَّذة

> **Built 2026-07-15** ([app #41](https://github.com/YoussefSalem582/Osta-App/issues/41)). What actually shipped, and where it knowingly departs from the plan below:
>
> - **Presentation** — `MapScreen` (`presentation/pages/`) + `MapBloc`/`MapEvent`/`MapState` (`presentation/bloc/`) + `MapCategoryChips` / `PlaceDialog` (`presentation/widgets/`). Reached from the customer center FAB via `RoleShell.centerBody`, **not** a `GoRouter` route — the bottom nav stays visible, as the mockup shows. `RoleShell` gained an opt-in `centerFullBleed` so the map alone drops the app bar (business `Bookings`, the other `centerBody` caller, keeps its bar + title).
> - **State** — **one** `MapState` class with a `MapStatus` enum + `copyWith`, not the plan's two cubits and not `GarageState`'s class-per-state: the map's position/centers/query/category change together and each status must retain the others. The filter-sheet cubit arrives with [#43](https://github.com/YoussefSalem582/Osta-App/issues/43).
> - **Data** — `CenterSummary` (plain `Equatable`, hand-written `fromJson`, **no** `toJson` — nothing writes a center back) + `CentersRepository`, which calls `ApiClient` and lets the sealed `ApiException` **throw**; `MapBloc` owns the `try`/`catch`. No `fpdart`, no `Either`, no `Result<T>`, no codegen — as planned. The wire contract was **verified 2026-07-16** against `osta_backend`'s `ServiceCenterResource` directly (not guessed): coordinates are nested under `location: {latitude, longitude}` (not flat `lat`/`lng`), so `fromJson` reads that sub-object; every other optional field stays nullable and tolerant of the plausible key spellings (`distance_meters`/`distance`, …) since those genuinely do vary by response. Same pass found `PaginationMeta` (shared, not map-specific) parsing the wrong shape and the category chips hitting the wrong query param — see `CHANGELOG.md` 2026-07-15/16 *Fixed* entries.
> - **DI** — two hand-written `registerLazySingleton` lines (`CentersRepository`, `LocationService`) in `configureDependencies()`. The repo is an **instance** with constructor injection (the AGENTS.md-canonical auth pattern), **not** the garage's static-method shape — the epic's mandated repo/bloc/permission tests need the seam. `MapBloc` is built inline by the screen, garage-style.
> - **Device** — a `LocationService` abstraction (`data/location_service.dart`) over `geolocator` only: `permission_handler` was **dropped as redundant** (geolocator already covers request/denied/deniedForever/openAppSettings). Clustering (`google_maps_cluster_manager_2`), `geocoding` and the mockup's price-pill markers are **deferred**; default green pins ship.
> - **Native key** — `--dart-define` can't reach the native layer, so the Maps key comes from git-ignored files and is **never committed**: Android `local.properties` → manifest placeholder; iOS `Secrets.xcconfig` → `Info.plist` → `AppDelegate`. ⚠️ Absent key: Android shows blank tiles, **iOS crashes** on the map tab (the Maps iOS SDK throws an uncaught `GMSServicesException` when `GMSMapView` is built) — `AppDelegate` asserts at launch naming the fix, so set up `Secrets.xcconfig` before running iOS. iOS deployment target raised to 15.0 (Maps SDK 9.x floor).
> - **Not built** — light/dark map styles (the epic asks for them; the map uses the default style today), and **Book/Details are coming-soon toasts** because the booking funnel and center profile ([#42](https://github.com/YoussefSalem582/Osta-App/issues/42)) have no route yet.

The original plan, following the repo's Clean Architecture + BLoC conventions and its deliberately plain-Dart, no-codegen style (advanced tooling deferred — see [ROADMAP](../../docs/ROADMAP.md)):

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
| GET | `/centers/nearby?lat&lng&service` | Markers near the user (nearest-first, `distance_meters`; backend also accepts `radius`, `price_max`, `min_rating`, `open_now`, `per_page`) — the category chips send their slug as `service`, matched against each center's `services.category` (`FiltersDiscoveryQuery::applyServiceFilter`); confirmed 2026-07-16 against `osta_backend` source, an earlier build sent `category` and silently filtered nothing | [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41) / [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) | **Connected** (`CentersRepository.nearby`) |
| GET | `/centers/search?q&service` (also `q&type` per filters epic) | Search bar + category chips (ilike on name/description/city/district; rating-ordered) | [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41), [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43) / [backend #41](https://github.com/YoussefSalem582/osta_backend/issues/41) | **Connected** (`CentersRepository.search`) |
| GET | `/centers?type&price_max&min_rating&open_now&sort=rating_desc` | Filtered Map + List results (as written in the app epic; backend exposes these filters on `/centers/nearby` and `/centers/search` — exact path alignment TBD, see epic) | [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43) | **Planned** |
| GET | `/centers/{id}` | Marker-tap bottom dialog summary (Book / Details) | [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41) / [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) | **Not needed by #41** — the dialog renders the summary already in the marker list; this belongs to the center profile ([#42](https://github.com/YoussefSalem582/Osta-App/issues/42)) |

Legend: **Connected** = already called from `lib/core/network` (only auth login/refresh/social exchange today) · **Planned** = epic open, not yet wired · **Blocked** = backend epic not merged.

## Packages & shared widgets / الحزم والودجت المشتركة

**Packages** — as resolved by [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41) on 2026-07-15:

> ‏الحزم كما استقرّت في الملحمة #41 بتاريخ 2026-07-15:

| Package | State | Why |
|---|---|---|
| `google_maps_flutter` | ✅ added | Full-screen map + markers (light/dark map styles still to do) |
| `geolocator` | ✅ added | Current position, **and** the whole permission flow |
| `permission_handler` | ❌ dropped | Redundant — `geolocator` already does request / denied / deniedForever / `openAppSettings` |
| `google_maps_cluster_manager_2` | ⏸ deferred | Clustering is polish; default pins ship |
| `geocoding` | ⏸ deferred | Nothing reverse-geocodes yet — the backend returns names + coords |

**Existing shared code to reuse** (already in the repo):

> ‏كود مشترك موجود يُعاد استخدامه (موجود بالفعل في المستودع):

- `AppTextField` — search bar input; `AppBottomSheet` — marker-tap dialog and the filter sheet; `AppCard` — center summary card; `AppButton` — Book / Details / Apply-filters actions.
- `EmptyState` / `ErrorState` / `LoadingState` (`shared/ui/status_states.dart`) — no-results, failed-request and loading surfaces.
- `EgpFormatter` / `NumberFormatter` (`shared/formatters/app_formatters.dart`) — price-max values and ratings with Arabic-Indic digits.
- `cached_network_image` (already a dependency) — center thumbnails in the summary dialog.
- `context.l10n` (`shared/extensions/context_ext.dart`) — all strings via ARB; no hardcoded text ([app #30](https://github.com/YoussefSalem582/Osta-App/issues/30)).

## Testing expectations / توقعات الاختبار

**Shipped with [#41](https://github.com/YoussefSalem582/Osta-App/issues/41)** (2026-07-15) — 3 files / 23 cases in `test/features/customer/map/`, the first tests since the suite was deleted on 2026-07-11, which **re-activates CI's guarded `flutter test` step**:

- `center_summary_test.dart` — `fromJson` across the documented payload, the alternate key spellings, Laravel's string/int encodings, an all-optional-missing payload, and value equality.
- `map_bloc_test.dart` — nearby load, empty-vs-error, **permission denied / denied-forever / services-off render a state rather than crash**, search debounce collapsing keystrokes into one call, an emptied box falling back to `nearby`, category slug + toggle-off, category combined with search, and both `retry` paths. Hand-written fakes (`implements CentersRepository` / `LocationService`) — no `bloc_test`, no mocktail, no new dev-dependency.
- `place_dialog_test.dart` — the summary in EN + the mockup's AR copy, omitted fields dropped rather than blank, closed-vs-open, and the Book/Details callbacks.

**Not covered**: the `MapScreen` widget itself — `GoogleMap` needs a platform view the test harness can't render — so marker rendering and the marker-tap → dialog wiring are unverified by test. No golden tests yet.

> ‏**شُحِنت مع #41** (2026-07-15) — 3 ملفّات و23 حالة، وهي أول اختبارات منذ حذف المجموعة في 2026-07-11، ووجودها **يُعيد تفعيل خطوة `flutter test`**: تحليل النموذج (الحمولة الموثَّقة، التهجئات البديلة، ترميزات لارافيل، الحمولة الناقصة، تكافؤ القيمة)؛ والكيوبت (التحميل، الفراغ مقابل الخطأ، **رفض الإذن والرفض النهائي وتوقّف الخدمة كحالات لا انهيار**، تأجيل البحث، العودة إلى `nearby`، الفئة وإلغاؤها، الفئة مع البحث، ومسارا إعادة المحاولة) ببدائل مكتوبة يدويًّا بلا أي اعتماد جديد؛ وحوار المكان (بالإنجليزية والعربية، وإسقاط الحقول الغائبة، ومفتوح/مغلق، والنداءات). **غير مُغطّى**: ودجت `MapScreen` نفسها لأن `GoogleMap` يحتاج عرضًا أصليًّا — فعرض العلامات وفتح الحوار عند الضغط غير مُتحقَّق منهما بالاختبار. ولا اختبارات ذهبية بعد.

The rest below remains the standing convention for follow-up work:

> ‏وما يلي يبقى العرف المتَّبع للعمل اللاحق:

- **Widget tests** for the search bar, category chips, filter sheet (selection → query params) and marker-tap dialog, including empty/error states in both locales.
- **Golden tests** per the design-system pattern from [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29): light/dark × RTL/LTR for the filter sheet and center summary card.
- **Unit tests** for the discovery repository — envelope parsing, filter-to-query-param mapping, `ApiException` → `Failure` mapping — using the fakes pattern in `test/core/network/fakes.dart`.
- All gated by CI: the single **format · analyze · test** job (`flutter pub get` → `flutter gen-l10n` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`). No `build_runner` step.

## Related docs / مستندات ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Features index](README.md)
- Sibling feature docs: [Service center profile](center-profile.md) · [Home dashboard](home-dashboard.md) · [Booking funnel](booking-funnel.md)
