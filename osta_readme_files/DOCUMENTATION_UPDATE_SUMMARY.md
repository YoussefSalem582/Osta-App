# Documentation Update Summary

> [INDEX](INDEX.md) > Documentation Update Summary
>
> Dated log of documentation changes, newest first. Add an entry here after every meaningful change (see [`../AGENTS.md`](../AGENTS.md) § Mandatory Documentation).

## 2026-07-16 — Register feature audited against the backend (#35, #37, #39, #53)

Every request **and response** contract in the register flow was checked against the Laravel source. The register form itself was already sound — it collects every field #35 asks for, and the auth envelope, token-pair keys, `data.user.type`, `CatalogPreset`, `GET /me` and all `BusinessProfileInput` keys match exactly. **Five wire bugs sat either side of it**, none of them loud.

**API drift resolved** — [`guides/09_api_endpoints.md`](guides/09_api_endpoints.md)

- The ⚠️ on `/auth/password/{forgot,reset}` is **gone: the code is fixed**. The previous entry flagged the mismatch but left the code alone pending verification against the deployed server; that verification is done (the flat paths exist at no backend commit), so `ApiEndpoints` now sends the nested paths and both recovery screens resolve.
- Added the two contracts that are easy to get wrong, because both are invisible from the backend suite:
  - **`/auth/refresh` takes the refresh token as `Bearer`, with an empty body.** It is behind `auth:sanctum` + `ability:refresh` and reads `$request->user()`; the token *is* the credential. The app sent it as a body field with no header, so every user was logged out at access-token expiry.
  - **Multipart only parses on POST.** A real `PUT` with a file leaves `$_POST` and `$_FILES` empty; where rules are `sometimes` that validates clean and saves nothing. `PUT /business/profile` therefore discarded the whole step-1 profile whenever a logo was attached.
- Marked `/auth/refresh`'s auth requirement inline in the table.

**Why the backend suite is green on all of this** — `$this->put(['logo' => UploadedFile::fake()])` injects into Symfony's file bag and never builds a multipart body. The test cannot see the bug. `test/core/network/wire_contract_test.dart` pins these from the client side instead, and the refresh + multipart cases are mutation-checked.

**Issue prose that contradicts the code** — noted so nobody "fixes" the code toward it: #39 names `{brand, model, model_year, plate, kilometers}` and a Riverpod provider (the backend is `{make, model, year, plate_number, current_mileage}`; this app is bloc/get_it); #53 names three business types the backend enum doesn't have.

**Mandatory**

- [`../CHANGELOG.md`](../CHANGELOG.md) and [`CURRENT_STATUS.md`](CURRENT_STATUS.md) — full entries.

## 2026-07-16 — `lib/features/` reorganised into business / customer / shared

Docs updated for the role-bucket refactor and the dead-code sweep that rode with it.

**Structure**

- [`../AGENTS.md`](../AGENTS.md) § Feature Architecture — replaced "customer/business sub-areas nested" with the three-bucket table, the no-cross-role-imports rule and the test that enforces it, the `features/shop/` exception, and the `lib/shared/` vs `lib/features/shared/` distinction.
- [`guides/01_folder_structure.md`](guides/01_folder_structure.md) — the `features/` tree was **badly stale**: it claimed `business/` and `customer/` had "no dart files" while both held ~60. Rewritten to the real tree with epic links per folder. The `test/` row claimed 11 files naming ones that don't exist; now 16, matching reality.
- [`INDEX.md`](INDEX.md) — feature map repointed at the buckets.

**Corrections found while editing** (stale on a different axis than the refactor)

- [`../CLAUDE.md`](../CLAUDE.md) and [`../AGENTS.md`](../AGENTS.md) both described errors as a `sealed Failure`. **There is no `Failure` type** — it was deleted 2026-07-10. The real type is `sealed ApiException` (`core/network/api_exception.dart`). CLAUDE.md's own tool-use rules were instructing agents to use a class that doesn't exist.
- `AGENTS.md` § Shared UI listed `AppBottomSheet` and `LoadingState`, both deleted 2026-07-10, and missed `AppToaster`, `BrandScaffold` and `OrDivider`. Now lists what `lib/shared/ui/` actually exports, plus the new `AppPill` and `AppSegmentedToggle`.
- Both files said "no `build_runner` step"; true, but the codegen packages were still declared. They are now removed, and the docs say so.
- `AGENTS.md` referenced `test/core/theme/contrast_test.dart`, which did not exist. It does now.

**API drift** — [`guides/09_api_endpoints.md`](guides/09_api_endpoints.md)

- `POST /forgot-password` / `/reset-password` were documented and **are what the app sends**. The backend registers `password/forgot` and `password/reset` inside `Route::prefix('auth')` under `Route::prefix('v1')` — real paths `/api/v1/auth/password/{forgot,reset}`. `git log -S"forgot-password" -- routes/` in the backend returns nothing, so the flat paths never existed. Documented with a ⚠️; **the code was not changed** — a live auth path deserves verification against the deployed server rather than a drive-by edit inside a refactor.
- Marked `/legal/*` as having no route or controller (it read "Backend route shipped").
- Added the undocumented-but-live `POST /telemetry/broadcast-latency`, `PATCH /business/bookings/{id}/assign-roster-mechanic`, and the `POST` halves of the reviews endpoints.

**Mandatory**

- [`../CHANGELOG.md`](../CHANGELOG.md) and [`CURRENT_STATUS.md`](CURRENT_STATUS.md) — full entries.

## 2026-07-16 — Map empty state when GPS is outside Egypt

iOS Simulator defaults to San Francisco; `GET /centers/nearby` returns `200` with an empty list when no centers exist in range. `CentersRepository.fetchNearby` sends `radius=25000` (25 km). Map empty overlay uses one friendly user-facing message (removed simulator/coordinate hints).

## 2026-07-16 — Post-auth wizard skips provider intro

After business register/login, `resolveRedirect` now opens `/business-identity` directly instead of `/provider-onboarding`. Merchants already saw the logged-out carousel; the intro screen stays routable but is no longer forced.

## 2026-07-16 — Merchant onboarding carousel under `lib/features/onboarding`

Added `MerchantOnboardingPage` (`/onboarding/business`) as the business twin of the customer `OnboardingPage` (`/onboarding`). Guard routes by role: customer → `/onboarding`, business → `/onboarding/business`, then auth. Post-auth center setup remains the provider wizard. Auth-choose back returns to the matching carousel via `resetOnboarding()`.

## 2026-07-16 — Role-split first-run + role-aware auth titles

Customer and business first-run paths split; login/register titles distinguish the chosen role.

## 2026-07-16 — Business onboarding & registration wired (app #53)

Wired the post-auth business wizard to the live B2B endpoints. Before: presentation-only screens; Activate only flipped an in-memory `businessOnboarded` flag; Skip jumped straight to catalog; wizard re-showed every cold start.

**What landed** — `BusinessOnboardingRepository` (`PUT /business/profile` multipart, `GET /business/catalog/presets`, `POST /business/catalog`) + `BusinessOnboardingCubit` shared via a `ShellRoute` across intro → identity → catalog. Identity step: form validation, `image_picker` logo, full-screen `MapPinPickerSheet` (Google Map + center pin, reuses `LocationService`). Catalog step: 12 API presets, category chips, ≥1 required, Activate persists completion. `SessionStore` now persists `business_onboarded` (cleared on sign-out). Skip → identity. Docs + endpoint catalogue updated. 15 new tests; suite **42/42**.

Touched: `lib/features/business/onboarding/**`, `lib/core/{session,router,di}`, ARB keys, `CHANGELOG.md`, `features/business-onboarding.md`, `guides/09_api_endpoints.md`, `CURRENT_STATUS.md`.

## 2026-07-16 — Bottom nav FAB white gap removed

`AppBottomNavBar` no longer pads the stack taller for the center FAB (that reserved strip painted the scaffold surface white behind the button). The FAB now overlaps upward with a negative top offset; `RoleShell` sets `extendBody: true` so full-bleed bodies (map) paint behind the protrusion.

Touched: `lib/shared/ui/app_bottom_nav_bar.dart`, `lib/features/shell/presentation/role_shell.dart`, `CHANGELOG.md`.

## 2026-07-15 — Map screen built (epic #41)

Built the M2 Discovery map surface ([app #41](https://github.com/YoussefSalem582/Osta-App/issues/41)). `lib/features/customer/map/` was three empty stub directories; the customer center FAB fired a "coming soon" toast.

**Feature** — a full-screen Google Map rendered **inside** the shell (bottom nav stays visible, center FAB reads as active — matching the mockup). Resolves the user's position, calls `GET /centers/nearby` (nearest-first), renders each center with coordinates as a tappable marker, and opens a `PlaceDialog` bottom sheet on tap (thumbnail, name, rating, distance, open-now, **Book** + **Details**). Search is debounced 350 ms and swaps to `GET /centers/search`; four category chips (oil · brakes · AC · tires) pass a `category` filter to whichever endpoint is active and clear on re-tap. Permission-denied, denied-forever (opens OS settings rather than re-prompting in a loop), location-services-off, empty and network-error each render their own surface floated over the map.

**Structure** — `CenterSummary` (hand-written `Equatable` + `fromJson`, no codegen), `CentersRepository` (through `ApiClient`; lets the sealed `ApiException` propagate — the bloc owns the `try`/`catch`), a `LocationService` seam over `geolocator`, and `MapBloc`/`MapEvent`/`MapState`. Two hand-written DI lines. The `/centers/nearby` · `/centers/search` · `/centers/{id}` endpoints already existed in `ApiEndpoints` — nothing was added there.

**Documented deviations** (all deliberate):

- **One state class + status enum**, not `GarageState`'s class-per-state — the map's position/centers/query/category change together, and every status must retain the others.
- **Instance repo + constructor injection**, not the garage's static `GetIt.instance<ApiClient>()` methods — the epic mandates repo/bloc/permission unit tests, which the static shape can't support. This matches the AGENTS.md-canonical auth pattern.
- **`MapBloc` (events), not a Cubit** — converted after the initial cut to match the mandated BLoC pattern the auth blocs already use (`AGENTS.md` §118): `MapStarted`/`SearchChanged`/`CategorySelected`/`RetryRequested` sealed events replace the old public methods. Debounce and stale-response protection are unchanged (`_searchGeneration`/`_loadGeneration` counters). The manual `isClosed`-guarded `_emit` the Cubit needed is gone — `Bloc.close()` cancels in-flight emitters itself, so a handler resuming after close silently no-ops instead of throwing; the regression test now exercises that framework guarantee instead of hand-rolled code.
- **`LocationService` abstraction with one implementation** — the platform seam the permission tests need.
- **Book/Details show the coming-soon toast** — the booking funnel and center profile ([#42](https://github.com/YoussefSalem582/Osta-App/issues/42)) have no route yet.
- **`CenterSummary` tolerates alternate key spellings** (`lat`/`latitude`, `distance_meters`/`distance`, …) and has no `toJson` — the epic documents the fields but not the JSON, the endpoints need a bearer token, so the wire contract is **unverified**; tighten it once a real payload is captured. Nothing writes a center back.
- **Deferred**: `google_maps_cluster_manager_2` (clustering), `geocoding`, and the mockup's price-pill markers (`CenterSummary.price` is parsed and waiting; default green pins ship). `permission_handler` was **dropped entirely** — `geolocator` already covers request/denied/deniedForever/openAppSettings.

**Shared widget** — `RoleShell` gained `centerFullBleed` (default `false`). The epic and mockup call for a full-screen map with no app bar, but `centerBody`'s existing caller (business `Bookings`) needs its bar and `centerLabel` title, so the behavior is opt-in rather than a redefinition.

**Native config** — the Maps key is consumed by the native layer, which `--dart-define` cannot reach, so the `BASE_URL` convention doesn't extend to it and **no key is committed**: Android reads `MAPS_API_KEY` from the git-ignored `local.properties` into a manifest placeholder; iOS reads a git-ignored `ios/Flutter/Secrets.xcconfig` (optional `#include?`, so a fresh clone still builds) → `Info.plist` `GMSApiKey` → `AppDelegate`. ⚠️ **The two platforms fail differently when the key is missing**, which the self-review caught: Android renders blank tiles, but the Maps iOS SDK throws an uncaught `GMSServicesException` the moment `GMSMapView` is constructed — iOS **crashes** on the map tab. `AppDelegate` therefore asserts at launch with the fix spelled out rather than skipping silently. `Secrets.xcconfig` is mandatory before running iOS. Added `ACCESS_FINE_LOCATION`/`ACCESS_COARSE_LOCATION` and `NSLocationWhenInUseUsageDescription` (an Info.plist string has no `context.l10n` path — localize via `InfoPlist.strings` if it ever needs to be). iOS deployment target 13 → 15 across the 3 pbxproj configs + the Podfile (Google Maps SDK 9.x floor). Android `minSdk` 24 already cleared every requirement.

**l10n** — 18 keys added to both `app_en.arb` / `app_ar.arb` (Arabic copy taken from the mockup: `دوّر على مركز صيانة...`, `مفتوح الآن`, `احجز`, `التفاصيل`), reusing the existing `retry` / `errorNetwork` / `comingSoonBody`. Parity intact.

**Tests** — `test/` returns with 3 files / 25 cases, which **re-activates CI's guarded `flutter test` step** (it had been skipping an empty suite since 2026-07-11). `MapScreen` itself is not widget-tested: `GoogleMap` needs a platform view the harness can't render.

**Self-review** — an adversarial pass over the diff (each finding independently verified against the code, 2 claims refuted) caught **8 real defects, all fixed before landing**, none of which `flutter analyze` can see:

1. **Stale-response race** — `_load()` had no request sequencing, so tapping chip A then B could leave B lit while A's markers showed, permanently. Fixed with a `_loadGeneration` counter; regression test included.
2. **`emit()` after `close()`** — leaving the map mid-request threw `StateError` on the Cubit, and the `on Object catch` blocks re-emitted and threw *again*, uncaught (`start()` is unawaited). Fixed at the time with an `isClosed`-guarded `_emit`; regression test included. Superseded by the later Cubit→Bloc conversion — `Bloc.close()` cancels in-flight emitters itself, so this class of bug can no longer occur here.
3. **Camera stuck on the fallback** — the one-shot camera move was dropped whenever the GPS fix beat `onMapCreated`, which is the common ordering. `onMapCreated` now applies a known position.
4. **Status overlay blanketed the map** — `EmptyState`/`ErrorState` centre into whatever they're given, so the card stretched over the map and swallowed every pan/zoom. Now shrink-wrapped.
5. **`MarkerId('')` collisions** — centers with no id collapsed to one marker (the plugin silently drops duplicates). Now falls back to a per-index id.
6. **Book/Details looked dead** — the coming-soon toast rendered *behind* the still-open bottom sheet. The sheet now closes first.
7. **iOS crash on a missing key** — documented as "blank tiles"; it is actually an uncaught `GMSServicesException`. Corrected everywhere and made to assert at launch.
8. **GPS in release logs** — see the *Fixed* entry in `CHANGELOG.md`; the leak lives in `core/network/dio_client.dart` but this feature is what would have triggered it.

Both regression tests were confirmed to **fail without their fix and pass with it**, so they are not tautological.

**Verification** — `dart format --set-exit-if-changed` clean, `flutter analyze` reports **no issues in the new code** (the 14 remaining are pre-existing in garage/profile/wallet), 25/25 tests pass. `add_car_screen.dart` carries a **formatting-only** diff: it was already failing `dart format` on `develop`, and the repo-wide format run fixed it.

**Confirmed on a real device (iOS Simulator, default location)** — `GMSServices.provideAPIKey` succeeded (no `GMSServicesException` crash, so `Secrets.xcconfig` is wired correctly), and `GET /centers/nearby` returned `200 OK`. That run also surfaced a real bug the static review missed: the map showed **"can't reach the server" on a successful response**. Immediate cause — `ApiClient._parseEnvelope` called `parse(body['data'])` outside any `try`/`catch`, so a parse-time exception propagated as an untyped `Object` instead of an `ApiException`; `MapScreen._errorMessage`'s fallback then mapped every non-`ApiException`/`NetworkException` error to the network-unreachable string. Fixed: `_parseEnvelope` now wraps `parse()` and rethrows a `ServerException` carrying the real cause, and the map's fallback got its own `errorGeneric` string instead of borrowing `errorNetwork`'s.

**Actual root cause, confirmed by reading `osta_backend` directly** — not the map at all: `PaginationMeta.fromJson` read pagination fields flat off `meta`, but `ApiResponse::paginated()` (`osta_backend/app/Http/Support/ApiResponse.php:47`) nests them under `meta.pagination`. Since `_parseEnvelope` parses `meta` unconditionally on every list response, `json['current_page'] as int` cast `null` to `int` and threw on **every paginated endpoint in the app**, not just centers — this had been broken since `PaginationMeta` was written and nothing caught it (zero test coverage on `ApiClient` until today). Fixed by reading `meta['pagination']` with a flat-`meta` fallback; added `test/core/network/api_client_test.dart`. Two more mismatches found the same way, both map-specific: the category chips sent `?category=` but the backend only reads `?service=` (silently filtered nothing), and `ServiceCenterResource` nests coordinates as `location: {latitude, longitude}` instead of flat keys (every marker was silently missing its position). Both fixed; see the `CHANGELOG.md` *Fixed* entries for the full writeup. The map's "wire contract is unverified" caveat (`map-discovery.md`) is now resolved — verified against the actual backend source, not guessed.

> ‏**بناء شاشة الخريطة (الملحمة #41)** (2026-07-15) — كان مجلّد الخريطة فارغًا والزرّ العائم يُظهر «قريبًا». صارت خريطة بملء الشاشة داخل الواجهة (يبقى الشريط السفلي): تحديد الموقع ← `GET /centers/nearby` ← علامات قابلة للضغط ← حوار سفلي (صورة، اسم، تقييم، مسافة، «مفتوح الآن»، احجز، التفاصيل)، مع بحث مؤجَّل 350 مللي يستدعي `GET /centers/search`، ورقائق فئات تمرّر `category` وتُلغى بإعادة الضغط، ومعالجة رفض الإذن والرفض النهائي (يفتح الإعدادات) وتوقّف الخدمة والفراغ وخطأ الشبكة. البنية: نموذج مكتوب يدويًّا بلا توليد كود، ومستودع عبر `ApiClient` يترك الاستثناء يُرمى، وطبقة موقع فوق `geolocator`، وكيوبت بصنف حالة واحد؛ وسطران في حقن التبعيات؛ والنقاط موجودة أصلًا. الانحرافات المتعمَّدة: صنف حالة واحد بدل صنف لكل حالة، ومستودع بحقن بالمُنشئ (لا ثابت) لأجل الاختبارات، وطبقة موقع بتطبيق واحد للاختبار، وزرّا «احجز/التفاصيل» يُظهران «قريبًا» لغياب مساريهما، ونموذج متسامح مع تهجئات المفاتيح لأن العقد غير مُتحقَّق منه، وتأجيل التجميع والترميز العكسي وعلامات السعر، وإسقاط `permission_handler`. واكتسبت `RoleShell` مُعامل `centerFullBleed` اختياريًّا حتى لا تتأثّر حجوزات النشاط. ومفتاح الخرائط لا يُلتزم أبدًا: أندرويد من `local.properties` المستثنى، وiOS من `Secrets.xcconfig` المستثنى ← `Info.plist` ← `AppDelegate`، ويتحوّل غيابه إلى بلاطات فارغة؛ وأُضيفت أذونات الموقع، ورُفع حدّ نشر iOS إلى 15. وأُضيف 18 مفتاحًا للغتين بنصوص النموذج العربية. وعاد مجلّد `test/` بـ23 اختبارًا فأُعيد تفعيل خطوة `flutter test`. التنسيق نظيف والتحليل بلا مشاكل في الشيفرة الجديدة و23 اختبارًا تنجح. **ولم تُبنَ نسختا أندرويد وiOS في هذه الجلسة** — رُوجعت الإعدادات الأصلية ثابتًا لا تصريفًا.

## 2026-07-11 — Test suite removed

Deleted the entire `test/` directory at the user's request — all 18 `_test.dart` files plus the shared `fakes.dart` helper (the 127-test suite: `core/network`, `core/session`, `core/router`, `core/theme`, the `features/auth` blocs + validators + repository, `shared/formatters`, `shared/ui`, and the top-level `widget_test.dart` / `auth_token_model_test.dart`).

CI was adjusted so it no longer fails on the now-empty suite: the `flutter test` step in `.github/workflows/ci.yml` is guarded with `find test -name '*_test.dart'` — it runs the suite when present and prints a skip message otherwise, so it also auto-recovers if tests are restored. The `format · analyze · test` job **name and id are unchanged**, so any required-status-check configuration keeps matching.

**Trade-off:** this removes the automated regression safety net. `flutter analyze` still gates CI, but there is no behavioral coverage until tests return. `git restore test` brings the suite back.

> ‏**إزالة مجموعة الاختبارات** (2026-07-11) — حُذف مجلّد `test/` بالكامل بناءً على طلب المستخدم: 18 ملفّ اختبار وملفّ `fakes.dart` المساعد (127 اختبارًا تغطّي الشبكة والجلسة والموجّه والثيم وكتل المصادقة ومدقّقاتها ومستودعها والمنسّقات وواجهة المستخدم المشتركة واختبارات المستوى الأعلى). وعُدّل CI حتى لا يفشل على مجموعة فارغة: صار تشغيل `flutter test` في `.github/workflows/ci.yml` محميًّا عبر `find` فيعمل عند وجود اختبارات ويطبع رسالة تخطٍّ خلاف ذلك، ويتعافى تلقائيًّا إذا أُعيدت. اسم المهمّة ومعرّفها بلا تغيير فتبقى فحوص الحالة المطلوبة مطابقة. **المقايضة:** يزول تغطية الانحدار الآلية؛ ويبقى `flutter analyze` حارسًا لكن دون تغطية سلوكية حتى تعود الاختبارات. ويعيدها `git restore test`.

## 2026-07-11 — Network layer consolidated (10 files → 4)

`lib/core/network/` had grown to 10 single-responsibility files, several of them tiny value/plumbing types (10-37 lines) that existed only to be consumed by a neighbor. Folded them into their natural owners, keeping 4 files:

- **`api_client.dart`** now also holds `ApiResult<T>` and `PaginationMeta` (the client's own return / envelope types) — `api_result.dart` and `pagination_meta.dart` deleted.
- **`dio_client.dart`** now also holds `AuthEvents`, `TokenPair` / `parseTokenPair`, `AuthInterceptor`, and `SocialTokenExchange` (the Dio transport + Sanctum auth plumbing) — `auth_events.dart`, `auth_interceptor.dart`, `token_pair.dart`, `social_token_exchange.dart` deleted.
- **`api_exception.dart`** and **`api_endpoints.dart`** are unchanged.

The one non-mechanical bit: `api_client.dart` referenced `AuthInterceptor.noAuthKey`, and `dio_client.dart` needs `ApiClient` (for `SocialTokenExchange`), which would make the two files import each other. Moved the `noAuthKey` constant onto `ApiClient`, so the dependency is now one-directional (`dio_client.dart` → `api_client.dart`).

Updated imports across 3 lib files (`di/injection.dart`, `session/session_controller.dart`, `auth/shared/data/auth_repository_impl.dart`) and 5 test files, and repointed the docs that cited the deleted paths (`guides/01_folder_structure.md`, `docs/OSTA_plan.md`, and the `auth` / `business-onboarding` / `role-selection-and-routing` / `my-bookings` / `business-bookings` feature docs). Test file names are unchanged. Pure refactor, no behavior change. `dart format` clean, `flutter analyze` → **No issues found**, all 127 tests pass.

> ‏**دمج طبقة الشبكة (10 ملفّات ← 4)** (2026-07-11) — كان `lib/core/network/` قد تضخّم إلى 10 ملفّات أحادية المسؤولية، عدّة منها أنواع صغيرة (10-37 سطرًا) لا تُستعمل إلا من جارها. دُمجت في مالكها الطبيعي مع الإبقاء على 4 ملفّات: صار `api_client.dart` يضمّ `ApiResult<T>` و`PaginationMeta`، وصار `dio_client.dart` يضمّ `AuthEvents` و`TokenPair`/`parseTokenPair` و`AuthInterceptor` و`SocialTokenExchange`، بينما بقي `api_exception.dart` و`api_endpoints.dart` كما هما. النقطة غير الآلية الوحيدة: نُقل ثابت `noAuthKey` إلى `ApiClient` حتى يصير الاعتماد أحادي الاتجاه (`dio_client.dart` ← `api_client.dart`) بلا استيراد متبادل. حُدِّثت الاستيرادات في 3 ملفّات lib و5 اختبارات، وأُعيد توجيه الوثائق التي أشارت إلى المسارات المحذوفة، وبقيت أسماء ملفّات الاختبار كما هي. إعادة هيكلة صرفة بلا تغيير سلوك؛ التنسيق نظيف، والتحليل بلا مشاكل، و127 اختبارًا تنجح.

## 2026-07-10 — Dead-code removal, home localization, theme-token wiring

Three cleanups from one "read the project, remove dead code, make sure it's localized and wired to the theme" pass.

**Dead code (analyzer already clean).** `flutter analyze` reported no issues, so the dead code here is the kind Dart's `unused_*` / `dead_code` lints can't see: whole unimported files and unused *public* API. Deleted 4 files — `core/error/failure.dart` (a `sealed Failure` hierarchy nothing imports; the app throws `AuthFailure` / `ApiException`), `shared/ui/app_bottom_sheet.dart`, `features/onboarding/.../social_button.dart`, and `business/bookings/.../app_bar.dart` (a duplicate `AppbarWidget`; the bookings screen uses the dashboard's `AppBarWidget`) — plus 3 orphaned public widgets living inside otherwise-used files (`LoadingState` in `status_states.dart`, `ProfileSectionHeader` in `profile_item.dart`, `ComingSoon` in `coming_soon.dart`; each referenced nowhere, live siblings kept), and a commented-out `ComponentGalleryPage` route (the class doesn't exist). Every target confirmed unreferenced by repo-wide + `test/` grep.

**Home localization (chrome only).** The `features/home/` widgets and the splash tagline were the last hardcoded-Arabic UI. Added 8 keys to both ARB files — `splashTagline`, `homeGreeting`, `homeBookServiceCta` / `Title` / `Subtitle`, `homeNearbyCenters`, `homeFromShop`, `homeActiveBookingBadge` — reused the existing `statusPending` for the in-progress badge, ran `flutter gen-l10n`, and wired each label through `context.l10n`. The mock/sample data in those widgets (fake center/product names, prices, the placeholder user name) is deliberately left hardcoded: it stands in for backend responses, so localizing it now is throwaway work. ARB parity intact (both files 277 keys).

**Theme-token wiring (full sweep).** The "never bypass design tokens" rule is documentation-only — no lint backs it — so ~200 raw values had drifted into the newer feature screens. Swept `business/dashboard`, `business/bookings`, `business/services`, `business/onboarding`, `customer/garage`, `customer/profile`, `customer/booking` and `home`: raw `Color(0x…)` / `Colors.*` → the matching semantic role (`colorScheme.surface` / `onSurface` / `onSurfaceVariant` / `primary` / `error` / `primaryContainer`, or `context.appColors.success` / `warning` / `accent` / `onAccent`), magic-number `EdgeInsets` / `SizedBox` gaps → `AppSpacing.*`, `BorderRadius.circular(N)` → `AppRadii.*`, inline `TextStyle(fontSize:)` → `textTheme.*`; off-scale numbers rounded to the nearest token. The payoff is dark mode: screens that hardcoded `Colors.white` / light hex stayed light before and now recolor with the scheme. Genuinely token-less spots are left and marked `// ponytail:` — the multi-color profile list icons, a dark-green chip label, the info-blue stat, and the black business center action — as are `BoxShadow` colors (no shadow token) and `fontSize` on emoji glyphs. Rounding the two home cards' padding up (`12` → `md`) overflowed their fixed-height list by 6px, so it was dropped to `AppSpacing.sm` instead.

Net across all three: 52 files, +398 / −525 lines, 5 files deleted. `flutter analyze` → **No issues found**; all 127 tests pass. Not covered here (needs a device): a manual light/dark + EN/AR pass on the swept screens.

> ‏**إزالة الشيفرة الميتة، وترجمة الرئيسية، وربط ألوان الثيم** (2026-07-10) — ثلاث تنظيفات من تمريرة واحدة. **الشيفرة الميتة:** كان `flutter analyze` نظيفًا، فالميت هنا ما لا تراه فواحص Dart: ملفّات غير مستورَدة وواجهات عامّة غير مستعمَلة. حُذفت 4 ملفّات (`failure.dart` غير المستورَد، `app_bottom_sheet.dart`، `social_button.dart`، ونسخة `app_bar.dart` المكرّرة في الحجوزات) و3 ودجات عامّة يتيمة (`LoadingState`/`ProfileSectionHeader`/`ComingSoon`) ومسار معرض معطّل — كلّها مؤكَّدة بالبحث الشامل. **الترجمة (الواجهة فقط):** أُضيفت 8 مفاتيح للغتين لودجات `features/home/` وشعار البداية، مع إعادة استخدام `statusPending`، ورُبطت عبر `context.l10n`؛ وتُركت البيانات التجريبية على حالها لأن الخادم سيستبدلها. **ربط الثيم (تمريرة كاملة):** بما أن قاعدة الرموز غير مفروضة بأي فاحص، تسرّبت ~200 قيمة خام إلى الشاشات الأحدث؛ حُوِّلت الألوان الخام إلى `colorScheme`/`context.appColors`، والمسافات إلى `AppSpacing`، والأنصاف إلى `AppRadii`، والأنماط إلى `textTheme`، مع تقريب القيم خارج السلّم لأقرب رمز — فصار الوضع الداكن يُعيد التلوين صحيحًا. تُركت الألوان بلا رمز (أيقونات الملف الملوّنة، نصّ الشريحة الأخضر، الأزرق الإعلامي، زرّ النشاط الأسود) والظلال وحجم الإيموجي مع تعليقات `// ponytail:`. وأدّى تقريب حشو بطاقتَي الرئيسية إلى تجاوز 6 بكسل فخُفّض إلى `AppSpacing.sm`. الإجمالي: 52 ملفًّا، +398/−525، و5 ملفّات محذوفة. التحليل: لا مشاكل، و127 اختبارًا تنجح.

## 2026-07-10 — Business dashboard routed (the last commit left it orphaned)

Commit `05361d0` added a whole business dashboard and never wired it to the router: `HomeScreen` — a `Scaffold` with its own raw Material bottom nav (Board / Catalog / Store / More) and a center FAB — plus standalone `TechScreen` and `Bookings`. Nothing built them, nothing linked them; all three were dead code.

**Why the shared shell won, not `HomeScreen`.** The app already had a business shell (`BusinessShellPage`, on the shared `RoleShell` → `AppBottomNavBar` — the *same* rounded bottom bar the customer shell uses, differing only by a black center action). `HomeScreen` was a second, parallel shell with its own plain `BottomNavigationBar`. Two shells for one role, and the odd one out visually. Kept `RoleShell` (consistent nav across both roles, and it already carries the switch-role / sign-out overflow menu) and folded the new *content* into it; deleted `HomeScreen`.

`BusinessShellPage` had two placeholder tabs (Dashboard, More) and two real ones (Catalog → `BusinessServicesPage`, Store → `BusinessShopPage`). The new screens fill the gaps exactly:

- **Dashboard tab → `BoardScreen`**, **More tab → `MoreScreen`**. Both shipped with their own `Scaffold` + `AppBar`; stripped to scaffold-less bodies (a `ColoredBox`/`SingleChildScrollView` and a bare `SingleChildScrollView`) so they embed under the shell's one app bar and nav — the same "strip Scaffold to embed" pattern the customer shell already uses for `MyBookingsView`/`ProfileView`. `BoardScreen`'s `AppBarWidget` (shop-name header) is kept as body content.
- Catalog/Store keep the **real** pages — `HomeScreen`'s `CatalogScreen`/`StoreScreen` were empty stubs duplicating them, so both stub files were **deleted**.
- `MoreScreen`'s `switchRole` row was **dropped** — it duplicated `RoleShell`'s overflow menu (which also has sign-out). No `SessionController` wiring needed in the screen.

**`TechScreen`** got a real route (`/business/technicians`), added to `resolveRedirect`'s `inAppScreens` allow-list (so an authed business user isn't bounced back to the shell), reached from a new tappable `MoreScreen` row — `Setting` gained an optional `onTap` (wrapped in an `InkWell`). It keeps its own `Scaffold` (pushed over the shell, so it gets a back button).

**`Bookings`** is the business booking screen the black center FAB opens — but pushing it as a route covered the shell and hid the bottom nav. So instead of a route, `RoleShell` gained an optional `centerBody` (+ `centerLabel` for the app-bar title): when the center action fires and a `centerBody` is set, the shell swaps its body to that widget and **keeps the bottom nav**; tapping any tab clears it. `Bookings` was stripped to a scaffold-less body (its `AppBarWidget` header kept as content) and passed as the business shell's `centerBody`. The customer shell is unaffected — with no `centerBody`, the center action still fires `onCenterTap` as before. The standalone `/business/bookings` route + its `AppRoutes` constant and allow-list entry were removed (nothing pushes it now).

**Renames** (fixing `file_names` lints in the touched feature): `techScreen.dart` → `tech_screen.dart`, and the four camelCase bookings widgets `appBar` / `customRow` / `driverTitle` / `selectedType` → snake_case, importers updated.

Net: `BoardScreen`, `MoreScreen`, `TechScreen`, `Bookings` all reachable through the shared shell (with its bottom nav visible on every one, `Bookings` included); three duplicate files gone (`HomeScreen`, `CatalogScreen`, `StoreScreen`). `flutter analyze` → **No issues found** (the 6 pre-existing `file_names` infos are gone too); all 127 tests pass.

> ‏**توجيه لوحة النشاط (تركها آخر التزام يتيمة)** (2026-07-10) — أضاف `05361d0` لوحة نشاط كاملة دون ربطها بالموجّه: `HomeScreen` (واجهة بشريط Material سفلي خاص وزرّ عائم) و`TechScreen` و`Bookings` مستقلّتين — شيفرة ميتة. كان لدى التطبيق واجهة نشاط على `RoleShell`/`AppBottomNavBar` المشتركة (نفس الشريط السفلي لواجهة العميل، بزرّ مركزي أسود)، و`HomeScreen` واجهة موازية بشريط خاص. أُبقيت `RoleShell` (تنقّل موحّد، وتتضمّن قائمتها تبديل الدور وتسجيل الخروج) وأُدمِج المحتوى الجديد فيها، وحُذف `HomeScreen`. مُلئ تبويبا `BusinessShellPage` النائبان: **اللوحة ← `BoardScreen`**، **المزيد ← `MoreScreen`** (بعد تجريدهما من `Scaffold`/`AppBar` ليندمجا كأجسام تبويب، على نمط `MyBookingsView`/`ProfileView`). ويبقى تبويبا الكتالوج والمتجر على الصفحتين الحقيقيتين — وكان `CatalogScreen`/`StoreScreen` نسختين وهميّتين فحُذفتا. وأُسقِط صفّ `switchRole` من `MoreScreen` لتكراره قائمة `RoleShell`. ووُجِّهت `TechScreen` و`Bookings` إلى `/business/technicians` و`/business/bookings`، مُدرَجتين في `inAppScreens`، ويُوصَل إليهما من صفَّي `MoreScreen` (اكتسب `Setting` مُعامل `onTap`). وأُعيدت تسمية الملفّات إلى snake_case. النتيجة: كل الشاشات قابلة للوصول، وثلاثة ملفّات مكرّرة حُذفت. التحليل: لا مشاكل، و127 اختبارًا تنجح.

## 2026-07-10 — Build restored: 317 analyzer errors from one commit

`flutter analyze` on `my_branch` reported **317 errors across 47 files**. Every one traced to commit `05361d0` ("Refactor localization strings, remove unused keys, and update app button implementation").

**Four root causes, all reverted from `HEAD^`:**

1. **The ARB files were emptied.** `lib/l10n/app_en.arb` and `app_ar.arb` went from 276 keys to 23, on the premise the removed strings were unused. They were not — `navHome`, `roleSelection*`, `onboarding*`, `businessShop*`, `showPassword`/`hidePassword` and ~250 others are referenced across 40+ widgets, and account for **305 of the 317 errors**. Restored both files, keeping the one key the commit legitimately added (`retry`).
2. **`app_router.dart` was gutted.** It lost the `AppRouter(SessionController)` constructor, the `refreshListenable`, the `resolveRedirect` guard, and **15 of its 17 routes** (auth, shells, garage, profile, bookings…). The dropped constructor turned `injection.dart`'s `AppRouter(getIt())` into an arity error.
3. **A duplicate `AppRoutes`.** The new `core/router/routes.dart` declared a second `AppRoutes` class, colliding with `core/router/app_routes.dart` (`ambiguous_import`). Nothing but the gutted router imported it, and none of its route constants were referenced anywhere — deleted.
4. **`splash_page.dart` pointed at a file that doesn't exist.** It imported `features/role/presentation/role_selection_page.dart` (the page lives under `presentation/page/`) and replaced `SessionController.bootstrap()` with a hard `context.go(RoleSelectionPage.path)` — which would have skipped the persisted-session launch path even if it compiled.

Separately, the same commit added the business dashboard screens (`board_screen`, `bookings`, `more_screen`, `techScreen`, `home_screen` and their widgets) referencing **30 `context.l10n` keys that were never added to either ARB**. Added all 30 (EN + AR). Three more — `changingRoles`, `store`, `more` — were exact duplicates of the existing `switchRole`, `navStore`, `navMore`, so the call sites were repointed rather than the keys duplicated.

`AppButton.style` was restored (the commit removed the parameter; `profile_screen.dart` still passes it). Finally, `dart fix --apply` cleared the unused imports the commit introduced, and `ItemType`/`Setting` — `@immutable` widgets declaring mutable fields — got `final` fields and `const` constructors.

`flutter analyze` is clean (6 pre-existing `file_names` infos remain: `appBar.dart`, `customRow.dart`, `driverTitle.dart`, `selectedType.dart`, `techScreen.dart`, `profile_Item.dart` — renaming them touches their importers and was left for a separate pass). All 127 tests pass.

## 2026-07-10 — Docs CI made to pass, which exposed 27 dead links

The `docs` workflow had **never** passed since it was added, so nobody had seen what it was trying to say.

**Why it was red.** `markdownlint-cli2` ran with no config file, so markdownlint's defaults applied — including `MD013`, an 80-character line limit. This repo pairs every English paragraph with an Arabic mirror written as one long line (wrapping it breaks RTL reading order), so the limit alone accounted for 2669 of **4304 errors across 101 files**. Separately, `link-check` passed `--exclude-mail`, which current `lychee` rejects: the job exited with `error: unexpected argument '--exclude-mail' found` before checking a single link.

**The config.** Added `.markdownlint.jsonc` disabling exactly six rules, each one something this repo does on purpose:

| Rule | Why it's off |
| --- | --- |
| `MD013` line-length | Arabic mirror paragraphs are deliberately one long line |
| `MD060` table-column-style | Tables are written compact (`\|---\|---\|`) |
| `MD033` no-inline-html | The README needs a centered `<div>`/`<img>` header |
| `MD041` first-line-heading | ...so its first line is that `<div>`, not an H1 |
| `MD024` no-duplicate-heading | Keep a Changelog repeats `### Fixed` per release |
| `MD028` no-blanks-blockquote | The English-then-blockquoted-Arabic pattern |
| `MD036` no-emphasis-as-heading | Feature docs caption each mockup with a bold line |

Everything else stays **on**, so the job still catches real breakage. Then `--fix` cleaned the mechanical violations (blank lines, list markers, trailing whitespace) across 29 files, 11 bare code fences were labelled `text`, and the vendored `.claude/skills/` tree was excluded from the glob — it is upstream code we don't reformat.

**What the lint then found.** With `MD051` finally running, it reported 27 broken link fragments — and it was right. The headings in `AGENTS.md` are bilingual:

```text
## Project Overview / نظرة عامة
```

GitHub slugs that to `#project-overview--نظرة-عامة`. The table of contents linked `#project-overview`. **All 18 TOC links in the canonical `AGENTS.md`, and 9 more in `CURRENT_STATUS.md`, silently went nowhere.**

Repointed all 27 with `github-slugger`, the library GitHub itself uses. That mattered: a hand-rolled slugger written first looked correct but dropped Arabic combining marks (`اقرأ هذا أولًا` → `...أولا`), which would have replaced 27 dead links with 27 different dead links. Verified against the real library before committing.

`markdownlint` now reports **0 errors** over 87 files. `dart format`, `flutter analyze` and 127 tests pass.

> ‏لم ينجح خطّ `docs` قطّ منذ إضافته. السبب: `markdownlint-cli2` يعمل بلا ملفّ إعداد، فيُطبَّق حدّ الثمانين حرفًا الافتراضي — وفقرات المرآة العربية سطر طويل واحد عن قصد — فبلغت الأخطاء 4304 في 101 ملفّ؛ كما يمرّر `link-check` وسيطًا `--exclude-mail` يرفضه `lychee` الحالي فيموت قبل فحص أي رابط. أُضيف `.markdownlint.jsonc` يعطّل ستّ قواعد فقط، كلٌّ منها ممارسة مقصودة في هذا المستودع، وتبقى البقيّة مُفعَّلة. ثمّ أُصلحت الانتهاكات الآلية في 29 ملفًّا، ووُسمت 11 كتلة شيفرة، واستُثنيت `.claude/skills/` المستورَدة. وحين عمل الفحص أخيرًا كشفت `MD051` عن 27 مرسًى ميتًا — وكانت مُحقّة: عناوين `AGENTS.md` ثنائية اللغة، فمرساها `#project-overview--نظرة-عامة` لا `#project-overview`، وكانت **كل روابط جدول المحتويات الثمانية عشر** وتسعة في `CURRENT_STATUS.md` لا تؤدّي إلى شيء. صُحِّحت جميعًا عبر `github-slugger` نفسه الذي يستعمله GitHub — وقد كان ذلك مهمًّا: أسقط مولّدٌ يدويّ كُتب أوّلًا علاماتِ التشكيل العربية، فكان سيستبدل بالروابط الميتة روابط ميتة أخرى. الآن صفر أخطاء.

Touched: `.markdownlint.jsonc` (new), `.github/workflows/docs.yml`, `AGENTS.md`, `CONTRIBUTING.md`, `CURRENT_STATUS.md`, `INDEX.md`, `docs/ARCHITECTURE.md`, the `guides/`, `features/`, `reference/`, `decisions/` sets, the `.agents/`/`.cursor/` shims, and three `my_bookings` widgets (`dart format`).

## 2026-07-10 — README rebuilt around the brand assets

The root `README.md` shipped no imagery at all, and three of its statements no longer matched the code.

**Brand assets.** Added a centered header (the `app_icon.png` tile over the title, with the mascot beneath) and a **Brand assets** section documenting all five files in `assets/images/`:

| Asset | `AppImages` | Used by |
| --- | --- | --- |
| `app_icon.png` | — | Launcher icon (`flutter_launcher_icons`) |
| `app_icon_foreground.png` | — | Android adaptive foreground + Android 12 splash |
| `logo.png` | `logo` | Native + in-app splash, `BrandScaffold` band on the inner auth screens, `RoleShell` top bar (tinted brand green) |
| `full_logo.png` | `fullLogo` | Landing screens — language pick, auth-choose, first onboarding slide |
| `osta.png` | `mascot` | Second onboarding slide |

The "Used by" column was read out of `lib/` (grep for `AppImages.`), not assumed — an earlier draft claimed the mascot backed the empty states, which it does not.

**Asset choice matters on GitHub.** `logo.png` and `full_logo.png` are RGBA **white on transparent** (verified from the PNG colour-type byte), so they render on the brand green and on dark surfaces but vanish on white — including GitHub's light theme. The header therefore uses `app_icon.png`, the one opaque asset (white wordmark on `#0E7A3B`), which reads in both themes. The section says so explicitly, and points at `RoleShell`'s `Image.asset(..., color: AppColors.brandGreen)` as the tinting escape hatch.

**Corrections.** (1) `BASE_URL` **defaults to the live backend** (`AppConfig`'s `defaultValue`), but the README described it as defaulting to "the dev API" and put a `--dart-define` in the quick-start — telling newcomers to pass a flag they don't need; the quick-start is now a bare `flutter run`. (2) The first-run flow is `splash → language → role → onboarding → auth-choose → auth → role shell` (read off `resolveRedirect`), not "a splash screen, then the first-run role selection". (3) The `lib/` tree omitted `core/session/`, `core/constants/`, and the `home/`, `language/`, `onboarding/` and `shell/` features.

Also added a Documentation table (pointing at `AGENTS.md`, the relocated `osta_readme_files/docs/ARCHITECTURE.md`, `INDEX.md`, `DELIVERY_PLAN.md`, `docs/ROADMAP.md`, `CONTRIBUTING.md`) and Flutter/Dart/lints/l10n badges. A resolver over every `.md` reports zero broken relative links, and all six `<img>` paths exist.

> ‏لم يكن في `README.md` أي صورة، وثلاثٌ من عباراته لم تعد تطابق الكود. أُضيف رأسٌ موسوم وقسم **أصول العلامة** يوثّق ملفّات `assets/images/` الخمسة وثوابتها في `AppImages` واستخدامها الفعلي — وقد قُرئ عمود الاستخدام من `lib/` لا افتراضًا (ادّعت مسوّدة سابقة أنّ التميمة تُستخدَم في الحالات الفارغة، وهذا غير صحيح). و`logo.png` و`full_logo.png` أبيضان على خلفية شفافة (تُحُقّق من بايت نوع اللون في PNG)، فيختفيان على الأبيض وعلى سمة GitHub الفاتحة؛ لذلك يستخدم الرأس `app_icon.png` المعتم وحده. **التصحيحات:** `BASE_URL` قيمته الافتراضية الخادم الحيّ (لا "واجهة dev")، فصار البدء `flutter run` مجرّدًا؛ ومسار أول تشغيل هو `splash ← اللغة ← الدور ← onboarding ← اختيار المصادقة ← المصادقة ← الواجهة`؛ وشجرة `lib/` أغفلت `core/session/` و`core/constants/` ومزايا `home/` و`language/` و`onboarding/` و`shell/`. وأُضيف جدول توثيق وشارات. كل الروابط ومسارات الصور تعمل.

Touched: `README.md`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-09 — Customer shell: one app bar per tab (Screen + View split)

A folder reorg (`presentation/` → `presentation/pages/`) reverted the earlier scaffold-strip: `MyBookingsScreen` and `ProfileScreen` were full pages again — `Scaffold` + `AppTopBar` — while `CustomerShellPage` still used them as tab **bodies** inside its own `Scaffold`. Result: the **Bookings** and **More** tabs each rendered a **second app bar**. The reorg also left two files declaring `MyBookingsScreen` (`presentation/` and `presentation/pages/`), which is an ambiguous-import compile error.

Deleted the stale `presentation/my_bookings_screen.dart` — the root cause, not an import-prefix problem; it was already broken (it imported a since-deleted `presentation/widgets/booking_item.dart`), so nothing referenced it that still compiled.

Split the two screens along the pattern the booking feature already established (`LiveBookingScreen` wraps `BookingView`):

| Routed screen | Scaffold-less view | Used by |
| --- | --- | --- |
| `MyBookingsScreen` (`/my-bookings`) | `MyBookingsView` | shell **Bookings** tab |
| `ProfileScreen` (`/profile`) | `ProfileView` | shell **More** tab |

The `Screen` is a thin `StatelessWidget` — `Scaffold` + `AppTopBar` + the `View` as its body — so the standalone route keeps its app bar and back button. The `View` holds the content only; `MyBookingsView` carries the `StatefulWidget`/`selectedTab` state that used to live on the screen. The shell embeds the views, so it keeps exactly one `AppBar` and one `AppBottomNavBar`.

Added a regression test in `test/widget_test.dart` — *"customer shell tabs render their bodies under one app bar"* — which taps through **Bookings → More → Home** asserting one `AppBar` + one `AppBottomNavBar` per tab. Verified it isn't vacuous: swapping `ProfileView` back to `ProfileScreen` fails it with `Found 2 widgets with type "AppBar"`. `flutter analyze` clean; all 127 tests pass.

> ‏أعادت إعادةُ تنظيم المجلّدات (`presentation/` ← `presentation/pages/`) غلافَي `Scaffold` و`AppTopBar` إلى `MyBookingsScreen` و`ProfileScreen`، بينما ظلّت `CustomerShellPage` تستعملهما كأجسام تبويب داخل `Scaffold` الخاص بها — فظهر **شريط تطبيق ثانٍ** في تبويبَي الحجوزات والمزيد. كما خلّفت ملفّين يعرّفان `MyBookingsScreen`، وهو خطأ استيراد ملتبس. حُذفت النسخة القديمة في `presentation/` (السبب الجذري؛ كانت معطوبة أصلًا إذ تستورد ودجت محذوفة) بدل استخدام `as prefix`. فُصلت الشاشتان على نمط `LiveBookingScreen`/`BookingView` القائم: تحتفظ الشاشة الموجَّهة بـ`Scaffold` و`AppTopBar` وتضع الـ`View` جسمًا لها، بينما تحمل `MyBookingsView`/`ProfileView` (بلا Scaffold) المحتوى وحده — وهما ما تُضمّنه الواجهة، فيبقى شريط واحد وشريط تنقّل واحد. انتقلت حالة `selectedTab` إلى `MyBookingsView`. أُضيف اختبار انحدار يتنقّل بين التبويبات ويتحقّق من ذلك (وتأكّدنا أنّه غير فارغ: إرجاع `ProfileScreen` مكانه يُسقطه). التحليل نظيف و127 اختبارًا تنجح.

Touched: `lib/features/customer/booking/presentation/pages/my_bookings_screen.dart`, `lib/features/customer/profile/presentation/pages/profile_screen.dart`, `lib/features/customer/shell/presentation/customer_shell_page.dart`, `test/widget_test.dart`, deleted `lib/features/customer/booking/presentation/my_bookings_screen.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-09 — Booking flow: Bookings tab shows the list, tapping a booking opens the detail page

The customer **Bookings** tab was wired to `BookingView` — the scaffold-less body of the live-status **detail** screen (`LiveBookingScreen`, `/booking-status`) — so it dropped the user straight into a single booking's status, and the built list (upcoming/past tabs, status badges, per-card tap) was orphaned.

Restored the intended flow: the Bookings tab now renders the bookings list, and each booking card `push`es `AppRoutes.bookingStatus` (`/booking-status` → `LiveBookingScreen`, which wraps `BookingView` with an `AppTopBar` showing the booking code) — so it's **list → detail** with a back button. `BookingView` remains the detail page's body. No route or guard changes (`/booking-status` was already registered and allow-listed). `flutter analyze` clean; all 127 tests pass.

> ‏كان تبويب **الحجوزات** موصولًا بـ`BookingView` — جسم شاشة **تفاصيل** الحالة الحيّة (`LiveBookingScreen`, `/booking-status`) — فيُنزل المستخدم مباشرةً في حالة حجز واحد، وتبقى شاشة القائمة معزولة. أُعيد التدفّق المقصود: يعرض التبويب الآن القائمة، وكل بطاقة تفتح `/booking-status` عبر `push` (قائمة ← تفاصيل مع زر رجوع). لا تغييرات في المسارات أو الحارس. التحليل نظيف و127 اختبارًا تنجح.

Touched: `lib/features/customer/booking/presentation/pages/my_bookings_screen.dart`, `lib/features/customer/shell/presentation/customer_shell_page.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-09 — Business shell embeds the business screens as its tabs (one shared nav, black center FAB)

The `business` landing reuses the customer shell's **UI** — the shared `RoleShell` (rounded bar + raised center action) — with a **black** center action (vs the customer's brand green), and its tabs render the **business's own** screens inline.

Made the FAB colour configurable: added an optional `centerColor` to `AppBottomNavBar` (threaded to the private `_CenterFab`, which previously hardcoded `AppColors.brandGreen`) and to `RoleShell`, both defaulting to `AppColors.brandGreen` so the customer shell is unchanged. `BusinessShellPage` passes `Colors.black`.

`BusinessShellPage`'s tabs are provider-domain — **Dashboard · Catalog · Store · More**. **Catalog** and **Store** show `BusinessServicesPage` and `BusinessShopPage` as tab **bodies** (the `AppBottomNavItem.body` slot), so there is one shared bottom nav instead of a per-screen one. To make them embeddable, both pages were **stripped of their own `Scaffold`, the black calendar `FloatingActionButton`, and the 5-tab `AppBottomNavBar`** (the duplicate provider nav in the screenshot) — they're now scaffold-less content widgets (`Column` of header + scroll/grid) with no `static const path`. Dashboard and More are placeholders (`EmptyState`, via the shell default) until built.

Because the provider pages are no longer navigated to, the standalone `/business-services` + `/business-shop` `GoRoute`s and the `AppRoutes.{businessServices,businessShop}` constants were removed, along with their guard allow-list entries and the redirect-test reachability assertion. `shellFor(business)` and the onboarding-wizard **Activate** still land at `/business`.

`flutter analyze` clean; all 126 tests pass.

> ‏يستخدم هبوط `business` **واجهة** العميل نفسها (`RoleShell`) بزرٍّ مركزي **أسود**، وتعرض تبويباته شاشات **النشاط نفسه** ضمنيًا. جُعل لون الزرّ قابلًا للضبط عبر `centerColor` في `AppBottomNavBar` و`RoleShell` (افتراضه الأخضر). التبويبات: **لوحة · كتالوج · متجر · المزيد**؛ يعرض **الكتالوج** و**المتجر** صفحتي `BusinessServicesPage` و`BusinessShopPage` كأجسام تبويب عبر `AppBottomNavItem.body` — شريط تنقّل واحد مشترك بدل واحد لكل شاشة. لذلك جُرِّدت الصفحتان من `Scaffold` وزرّ التقويم الأسود وشريط التنقّل الخماسي (الشريط المكرّر في الصورة) وأصبحتا ودجتي محتوى بلا Scaffold ولا `path`. حُذفت مسارات `/business-services` و`/business-shop` وثوابتها ومدخلات الحارس. التحليل نظيف و126 اختبارًا تنجح.

Touched: `lib/shared/ui/app_bottom_nav_bar.dart`, `lib/features/shell/presentation/role_shell.dart`, `lib/features/business/shell/presentation/business_shell_page.dart`, `lib/features/business/services/presentation/pages/business_services_page.dart` (scaffold-less), `lib/features/shop/presentation/pages/business_shop_page.dart` (scaffold-less), `lib/core/router/app_routes.dart`, `lib/core/router/session_redirect.dart`, `lib/core/router/app_router.dart`, `test/core/router/session_redirect_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-09 — Customer + business shells render real screens instead of placeholders

Testing the app surfaced that the authenticated shells showed generic `EmptyState` placeholders where real screens should be.

**Root cause (customer Home):** a bad merge in `RoleShell` (`lib/features/shell/presentation/role_shell.dart`) left commented-out `<<<<<<<`/`=======`/`>>>>>>>` markers and **deleted the `pages`/`IndexedStack` render path**, leaving only `body: tab.body ?? EmptyState`. So `CustomerShellPage`'s `pages: [HomePage(), …]` list was silently ignored and the Home tab rendered a placeholder. Fixed by removing the dead `pages` field from `RoleShell` and putting `HomePage` on the Home tab's `body` (scaffold-less — the correct embed mechanism, alongside the existing `BookingView`/`ProfileView` bodies), then deleting the stale `pages` list and its now-unused imports (`my_bookings_screen`, `status_states`).

**Layout bug:** rendering `HomePage` for the first time exposed a `RenderFlex overflowed by 11 pixels` in the merged `CenterCard` (`home/presentation/widgets/center_card.dart`) — the distance/rating `Row` in a 146px card. Wrapped the distance `Text` in `Expanded` + `TextOverflow.ellipsis`.

**Business shell:** the `business` role landed in `BusinessShellPage` — a `RoleShell` with three empty tabs (dashboard/bookings/profile, no bodies → all placeholders). The real provider UI already existed as `BusinessServicesPage` (a full 5-tab shell: Dashboard·Catalog·Calendar·Store·More + FAB) and its peer `BusinessShopPage`, both routed but **unreachable** (the guard bounced authenticated business to `/business`). Retired `BusinessShellPage`: `shellFor(business)` and the onboarding-wizard **Activate** now target `/business-services`, and `/business-shop` (reached from the Store tab) is allowed in the guard. Added `AppRoutes.{businessServices,businessShop}`, removed `AppRoutes.businessShell` and the `BusinessShellPage` file/route. Updated the redirect tests (`businessShell` → `businessServices`, plus a store-reachability assertion).

> ‏كشف تشغيل التطبيق أنّ الواجهات المُصادَقة تعرض عناصر `EmptyState` نائبة بدل الشاشات الحقيقية. **السبب (Home العميل):** دمج خاطئ في `RoleShell` حذف مسار `pages`/`IndexedStack` فتُجوهلت قائمة `pages` في `CustomerShellPage`؛ أُصلح بنقل `HomePage` إلى `body` وحذف حقل `pages` الميت والاستيرادات غير المستخدمة. **خطأ تخطيط:** تجاوز `RenderFlex` بمقدار 11px في `CenterCard` — لُفّ نصّ المسافة بـ`Expanded` مع ellipsis. **واجهة النشاط:** كان دور `business` يهبط في `BusinessShellPage` الفارغة بينما واجهة المزوّد الحقيقية `BusinessServicesPage` (خمسة تبويبات) و`BusinessShopPage` غير قابلتين للوصول؛ وُجّه `shellFor(business)` وزرّ التفعيل إلى `/business-services` وسُمح بـ`/business-shop`، وحُذفت `BusinessShellPage`. حُدّثت اختبارات إعادة التوجيه. التحليل نظيف و126 اختبارًا تنجح.

Touched: `lib/features/shell/presentation/role_shell.dart`, `lib/features/customer/shell/presentation/customer_shell_page.dart`, `lib/features/home/presentation/widgets/center_card.dart`, `lib/core/router/app_routes.dart`, `lib/core/router/session_redirect.dart`, `lib/core/router/app_router.dart`, `lib/features/business/shell/presentation/business_shell_page.dart` (deleted), `test/core/router/session_redirect_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-09 — Integrate the merged Home screen (PR #85) and clean up its merge fallout

Pulling PR #85 (customer Home feature, `lib/features/home/`) into `develop` left three defects: (1) `app_router.dart` gained a **duplicate `splash_page` import** plus a scrambled import block (from the merge); (2) `HomeBottomNav` was route-registered at `/home` but `resolveRedirect` never allows `/home` for any state, so the entire Home feature was **unreachable**; and (3) `lib/features/home/widgets/home_bottom_nav.dart` was a byte-for-byte **dead duplicate** of `lib/features/home/presentation/widgets/home_bottom_nav.dart` (a folder-reorg leftover — the CHANGELOG's "Home/onboarding reorganized to Clean Architecture" move didn't delete the old copy).

Rather than make the redundant `HomeBottomNav` reachable, integrated the actual deliverable: the built `HomePage` (a self-contained scroll of `HomeHeader` + `ActiveBookingCard` + `BookServiceCard` + `NearbyCentersSection` + `ShopSection`) now renders as index 0 of `CustomerShellPage`, replacing the `EmptyState` "until the Home screen is built" placeholder — so it appears inside the existing branded, localized customer shell. Deleted the `/home` route and **both** `HomeBottomNav` files (it re-implemented a lower-quality shell: hardcoded Arabic nav labels and three `'data'` placeholder tabs, duplicating what `CustomerShellPage` already does with `l10n`), removed the now-dead `HomePage.path` constant, and cleaned commented-out `<<<<<<<`/`=======`/`>>>>>>>` merge-conflict markers left in `customer_shell_page.dart`. `flutter analyze` clean; all 126 tests pass (the relaunch widget test now pumps the shell with `HomePage` at index 0, exercising the new widgets end-to-end).

Not touched: the unused `SocialButton` widget (`lib/features/onboarding/presentation/widgets/social_button.dart`, also added by #85) — dead but harmless; left in place.

> ‏خلّف دمج PR #85 (ميزة Home للعميل) ثلاثة عيوب: استيراد `splash_page` مكرّر وكتلة استيراد مشوّشة في `app_router.dart`؛ و`HomeBottomNav` مُسجَّل على `/home` بينما الحارس لا يسمح به أبدًا فكانت الميزة **غير قابلة للوصول**؛ وملف `home/widgets/home_bottom_nav.dart` نسخة ميتة مطابقة تمامًا للنسخة في `presentation/widgets/`. بدل جعل `HomeBottomNav` الزائد قابلًا للوصول، دُمج المُنتَج الفعلي: `HomePage` المبني يظهر الآن كالفهرس 0 في `CustomerShellPage` بدل العنصر النائب، داخل واجهة العميل المُنمَّطة والمُترجَمة. حُذف مسار `/home` وكلا ملفّي `HomeBottomNav` (نسخة أسوأ: نصوص عربية ثابتة وتبويبات `'data'`) و`HomePage.path` الميت، ونُظّفت علامات تعارض الدمج المُعلَّقة في `customer_shell_page.dart`. التحليل نظيف و126 اختبارًا تنجح. لم يُمَسّ: ودجت `SocialButton` غير المستخدَم — تُرك كما هو.

Touched: `lib/core/router/app_router.dart`, `lib/features/customer/shell/presentation/customer_shell_page.dart`, `lib/features/home/presentation/pages/home_page.dart`, `lib/features/home/presentation/widgets/home_bottom_nav.dart` (deleted), `lib/features/home/widgets/home_bottom_nav.dart` (deleted), `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-09 — Show the business onboarding wizard after a business registration

The business onboarding wizard (`ProviderOnboardingPage` → `BusinessIdentityPage` → `BusinessCatalogPage`, under `lib/features/business/onboarding/`) existed and was route-registered, and its internal step-to-step navigation was wired — but nothing routed *into* it: after registering with `account_type = business`, `SessionController.onAuthenticated` set `activeRole = business` + `hasToken`, and `resolveRedirect` sent the user straight to the `/business` shell, so the wizard was dead. Now an authenticated `business` user is gated through it first.

Added `SessionState.businessOnboarded` (in-memory, never persisted — reset on every `bootstrap`/`clearingRole`, exactly like `onboardingAcknowledged`/`languageAcknowledged`/`roleAcknowledged`) and `SessionController.completeBusinessOnboarding()`. New guard branch in `session_redirect.dart`: `role == business && !businessOnboarded` forces the wizard set (`/provider-onboarding` → `/business-identity` → `/business-catalog`) until done, then falls through to the normal shell logic. `BusinessCatalogPage`'s **Activate** callback (in `app_router.dart`) now calls `completeBusinessOnboarding()` and `context.go('/business')`; once the flag flips the guard permits the shell. Because the flag is in-memory, the wizard re-runs each launch until the business user finishes it that session (per the chosen behavior). The customer flow is untouched.

> ‏كان مُرشد تأهيل النشاط التجاري (`ProviderOnboardingPage` → `BusinessIdentityPage` → `BusinessCatalogPage`) مُسجَّلًا بالمسارات وتنقّله الداخلي موصولًا، لكن لا شيء يقود إليه: بعد التسجيل كـ`business` كان `resolveRedirect` يُنزل المستخدم مباشرةً في واجهة `/business`، فيبقى المُرشد ميتًا. الآن يُجبَر مستخدم `business` المُصادَق على المرور به أولًا. أُضيف عَلَم `SessionState.businessOnboarded` (في الذاكرة، غير مُخزَّن، يُصفَّر كل إقلاع) و`completeBusinessOnboarding()`، وفرعٌ في الحارس يُلزم مجموعة المُرشد حتى الإكمال ثم يُكمل لمنطق الواجهة. زرّ **التفعيل** في الكتالوج يقلب العَلَم ويذهب إلى `/business`. لأنّ العَلَم في الذاكرة، يُعاد المُرشد كل إقلاع حتى يُنهيه في الجلسة. مسار العميل بلا تغيير.

Touched: `lib/core/session/session_state.dart`, `lib/core/session/session_controller.dart`, `lib/core/router/app_routes.dart`, `lib/core/router/session_redirect.dart`, `lib/core/router/app_router.dart`, `test/core/router/session_redirect_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-09 — Route the built role-selection screen; clear all analyzer lints

The polished `RoleSelectionPage` (`lib/features/role/presentation/page/`) — 4 `RoleCard`s + `InfoBanner` — existed but was never registered and its role cards had empty `onTap: () {}` stubs, so it was dead UI. Wired the two live cards to `SessionController.chooseRole` (`customer`/`business`) — the redirect guard drives navigation, so no explicit push — repointed the `/role` route from `RoleChooserPage` to `RoleSelectionPage`, and deleted the now-superseded `RoleChooserPage`. `test/widget_test.dart` updated to the new role strings (`Who are you?` / `Customer`). Separately cleared the remaining 18 `flutter analyze` lints: removed a dead `flutter/material` import in the widget test, renamed `profile_Item.dart` → `profile_item.dart` (`file_names`), sorted both `pubspec.yaml` dependency blocks alphabetically, wrapped over-long doc/decorative comments, dropped a redundant `AppCard` padding argument, fixed an `unnecessary_underscores` and a missing EOL newline, and ran `dart format`. `flutter analyze` clean; all 123 tests pass.

> ‏كانت `RoleSelectionPage` (أربع `RoleCard` مع `InfoBanner`) مبنيّةً لكن غير موصولة بمسار وبطاقاتها تحمل `onTap: () {}` فارغة. وُصلت البطاقتان الفاعلتان بـ `SessionController.chooseRole`، ووُجّه مسار `/role` إليها بدل `RoleChooserPage` التي حُذفت، وحُدّث `test/widget_test.dart`. كما أُزيلت الـ18 تحذيرًا المتبقّية من `flutter analyze` (استيراد ميت، إعادة تسمية `profile_Item.dart`، ترتيب حزم `pubspec.yaml`، لفّ تعليقات طويلة، حذف padding زائد، `dart format`). التحليل نظيف و123 اختبارًا تنجح.

Touched: `lib/features/role/presentation/page/role_selection_page.dart`, `lib/core/router/app_router.dart`, `lib/features/role/presentation/role_chooser_page.dart` (deleted), `lib/features/customer/profile/presentation/widgets/profile_item.dart` (renamed), `lib/features/business/**`, `lib/features/role/presentation/widgets/role_card.dart`, `lib/features/customer/booking/presentation/my_bookings_screen.dart`, `test/widget_test.dart`, `pubspec.yaml`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Business Services & Shop screens with direct `AppBottomNavBar` & `ServiceToggleCard` consolidation

Implemented the two exact screens from user mockups (`BusinessServicesPage` with `ServicesFilterToggle`, shared `ServiceToggleCard`, and `DiscountPromotionBanner` under `lib/features/business/services/presentation/`; and `BusinessShopPage` with `ShopProductCard` under `lib/features/shop/presentation/`). Removed the entire `lib/features/shell/` folder (`ProviderShell`) since it is no longer needed, and instead directly attached the shared `AppBottomNavBar` (`AppBottomNavItem`) and center docked `FloatingActionButton` onto the `Scaffold` of both `BusinessServicesPage` (`/business-services`) and `BusinessShopPage` (`/business-shop`). Consolidated `ServiceToggleCard` across both `BusinessCatalogPage` (`onboarding`) and `BusinessServicesPage` (`services`) to eliminate widget/code duplication, replacing hardcoded hex switch colors with dynamic design tokens (`theme.colorScheme.primary` and `outlineVariant`). Registered `/business-services` and `/business-shop` in `AppRouter` and added exact localized strings (`shellNavCalendar` + navigation/services keys) across `app_ar.arb` and `app_en.arb`.

> ‏تم تنفيذ الشاشتين المطابقتين لتصاميم المستخدم (`BusinessServicesPage` مع مكونات التبديل وعروض الخصم تحت `lib/features/business/services/presentation/`؛ و`BusinessShopPage` مع بطاقة المنتج وحالة التفعيل تحت `lib/features/shop/presentation/`). وتم مسح مجلد `lib/features/shell/` بالكامل وحذف الصفحة الحاضنة `ProviderShell` لعدم الحاجة إليها وإرفاق شريط التنقل السفلي المشترك `AppBottomNavBar` (`AppBottomNavItem`) وزر التقويم العائم مباشرة في شاشتي الكتالوج والأسعار والمتجر. وتم توحيد مكوّن بطاقة الخدمة `ServiceToggleCard` ليعمل كمكوّن مشترك بين شاشة تأهيل الكتالوج وشاشة الكتالوج والأسعار لتجنب تكرار الكود مع استبدال الألوان الثابتة برموز ألوان التصميم الديناميكية. وتم تسجيل مساري الشاشتين في موجه التطبيق وإضافة جميع مفاتيح الترجمة في ملفي العربية والإنجليزية.

Touched: `lib/features/business/services/presentation/**`, `lib/features/business/onboarding/presentation/widgets/service_toggle_card.dart`, `lib/features/shop/presentation/**`, `lib/shared/ui/app_bottom_nav_bar.dart`, `lib/core/router/app_router.dart`, `lib/l10n/app_{en,ar}.arb`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-07 — Business onboarding screens, widgets & routing implemented

## 2026-07-09 — Point BASE_URL at the live backend (osta.technology92.com)

The backend is now deployed at **`https://osta.technology92.com`** — admin panel at `/admin`, REST API under `/api/v1`. Verified live: `GET https://osta.technology92.com/api/v1/auth/check-username?username=test` → `{"success":true,"data":{"available":true}}` (the standard `{success,data}` envelope; the app's `Prefix = /api/v1` and error-code contract hold). The previous default host `api.osta.dev` was a placeholder that does not resolve (DNS `fetch failed`).

Replaced `api.osta.dev` → `osta.technology92.com` across the whole repo: the functional change is `AppConfig.baseUrl`'s compile default (`lib/core/config/app_config.dart`, `defaultValue: 'https://osta.technology92.com/api/v1'`), so `flutter run` with no `--dart-define` now reaches a working backend; `--dart-define=BASE_URL=…` still overrides per environment. All doc/run-command references were updated for consistency — `README.md`, `ARCHITECTURE.md`, `OSTA_plan.md`, `OSTA_TODO.md`, `CLAUDE.md`, `.agents/rules/project-scope.md`, and the `osta_readme_files/guides/` set (01, 02, 03, 04, 06, 08, 09) + `reference/{ONBOARDING,COMMON_PITFALLS}.md`. `flutter analyze` clean.

> ‏أصبح الـ backend منشورًا على **`https://osta.technology92.com`** (الإدارة `/admin`، الـ API `/api/v1`). مُتحقَّق: `GET /api/v1/auth/check-username` يُعيد `{"success":true,"data":{"available":true}}`. كان المضيف السابق `api.osta.dev` نائبًا لا يُحلَّل (DNS يفشل). استُبدل `api.osta.dev` بـ `osta.technology92.com` في كامل المستودع؛ التغيير الوظيفي هو الافتراضي المُصرَّف في `AppConfig.baseUrl`، فيصل `flutter run` الآن إلى backend فعلي دون `--dart-define`. حُدِّثت كل مراجع التوثيق وأوامر التشغيل. التحليل نظيف.

## 2026-07-07 — Business onboarding screens, widgets & routing implemented

Implemented the three business onboarding screens (`ProviderOnboardingPage`, `BusinessIdentityPage`, `BusinessCatalogPage`) and their reusable widgets in `lib/features/business/onboarding/presentation/`. Aligned `BusinessIdentityPage` 100% with exact user mockup (exact Arabic strings/numerals, separated phone field and `+20 🇪🇬` box, bottom-left camera icon in `LogoUploadBox`, bottom-right map CTA in `LocationPickerCard`, and placing map card above dropdowns). Registered static paths and wizard navigation routes (`/provider-onboarding` → `/business-identity` → `/business-catalog`) in `AppRouter`.

> ‏تم تنفيذ شاشات تأهيل النشاط التجاري الثلاث ومكوناتها القابلة لإعادة الاستخدام في `lib/features/business/onboarding/presentation/`. وتمت مطابقة شاشة الهوية `BusinessIdentityPage` بنسبة 100% مع تصميم المستخدم (النصوص والأرقام العربية، فصل حقل الهاتف عن مربع كود الدولة `+20 🇪🇬`، ضبط مواقع الأيقونات والأزرار في الخريطة ومربع الشعار، وترتيب الخريطة قبل القوائم المنسدلة). وتم ربط مسارات التنقل في موجه التطبيق `AppRouter`.

Touched: `lib/features/business/onboarding/presentation/**`, `lib/core/router/app_router.dart`, `lib/l10n/app_{en,ar}.arb`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-07 — Role selection screen widgets & RTL alignment

Implemented the role selection screen widgets (`RoleCard`, `ComingSoonBadge`, `InfoBanner`) in `lib/features/role/presentation/widgets/`, enhanced `AppCard` with optional styling properties, fixed `AppColors.gray`, and aligned headers to `start` for RTL support.

> ‏تم تنفيذ ودجات شاشة اختيار الدور (`RoleCard`, `ComingSoonBadge`, `InfoBanner`) في `lib/features/role/presentation/widgets/`، وتطوير `AppCard` بدعم الحدود والألوان، وإصلاح `AppColors.gray`، وضبط محاذاة العناوين إلى `start` لدعم الـ RTL.

Touched: `lib/features/role/presentation/widgets/{role_card,coming_soon,info_banner}.dart`, `lib/features/role/presentation/role_selection_page.dart`, `lib/shared/ui/app_card.dart`, `lib/core/theme/app_colors.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Register avatar upload (image_picker → POST /me/avatar)

Wired the register screen's profile-photo control end to end (it was a "coming soon" stub). Tapping the ring now opens the **system gallery picker** via `image_picker` (`ImagePicker().pickImage(source: gallery, maxWidth: 1024, imageQuality: 85)`) — the picker uses **PHPicker on iOS / the Android Photo Picker**, which run out-of-process, so **no `NSPhotoLibraryUsageDescription` / runtime permission / native manifest change is required**. The chosen file previews inside the dashed ring (`ClipOval(Image.file(...))`), and its path rides along on `RegisterSubmitted.photoPath`.

On submit, `RegisterBloc._onSubmitted` uploads the avatar to **`POST /api/v1/me/avatar`** (multipart, field `avatar`) through a new `AuthRepository.uploadAvatar({required String filePath})` — built as a Dio `FormData` + `MultipartFile.fromFile`, so **no `ApiClient` change** was needed (its `post` already forwards `FormData` as the body; Laravel content-sniffs the bytes for the `image`/`mimes:jpeg,png,jpg`/`max:5120` rules, so the multipart content-type is left to Dio). Ordering matters: the upload runs **after** `register()` has stored the token (so the authenticated call succeeds) and **before** `_session.onAuthenticated(...)` hands off to the router (which tears down the page + bloc). It is **best-effort** — wrapped in its own `try/catch` that swallows failures, because the account already exists and a failed photo shouldn't strand the user (they can set it later from their profile).

> ‏فُعِّل رفع صورة الملف الشخصي في شاشة التسجيل: النقر يفتح منتقي المعرض (`image_picker` عبر PHPicker/Android Photo Picker — دون أي إذن أو تعديل native)، تُعرض الصورة داخل الحلقة، ويُرفَع الملف بعد التسجيل إلى `POST /me/avatar` عبر `AuthRepository.uploadAvatar` (Dio `FormData`، دون تغيير `ApiClient`). يجري الرفع بعد تخزين الرمز وقبل الانتقال، وبأسلوب أفضل جهد (يُبتلَع الفشل حتى لا يُعطّل التسجيل).

Added `image_picker: ^1.1.2` (pubspec). New tests: two `register_bloc` cases (avatar uploaded with the picked path; a failing upload still authenticates); the four `AuthRepository` test fakes (`fakes.dart`, register/login/password-recovery stubs) gained `uploadAvatar`. `flutter analyze` clean; 123 tests pass.

Touched: `lib/features/auth/register/presentation/{register_page.dart, bloc/register_event.dart, bloc/register_bloc.dart}`, `lib/features/auth/shared/{domain/auth_repository.dart, data/auth_repository_impl.dart}`, `pubspec.yaml`, `test/core/network/fakes.dart`, `test/features/auth/{register,login,password_recovery}/*_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Register screen redesign (profile photo + side-by-side names + social row)

Reworked `RegisterPage` (`lib/features/auth/register/presentation/register_page.dart`) to the new design: a tappable **profile-photo placeholder** (`_PhotoPicker` — a dashed brand ring drawn by a small `_DashedRingPainter` `CustomPainter`, a person glyph, a camera badge, and the `authAddPhoto` prompt) at the top of the form card; **first and last name side by side** in a `Row` of `Expanded` fields (RTL puts the first name on the right, matching the design); the primary CTA relabelled from `authSubmit` to `authCreateAccount` ("إنشاء الحساب"); and an **`OrDivider` (`authOr`) + the auth-choose "Continue with Google/Apple" social buttons** below it — the same stacked secondary `AppButton`s (`continueWithGoogle`/`continueWithApple`, `Icons.g_mobiledata`/`Icons.apple`) the auth-choose screen already uses, reused here for a consistent look. Photo upload and social sign-in are stubs — tapping either shows the existing `comingSoon` toast — so **no `image_picker` or social-auth dependency was added**. The auth-choose page's private `_OrDivider` was extracted to a shared **`lib/shared/ui/or_divider.dart`** and reused in both places.

> ‏أُعيد تصميم صفحة التسجيل: عنصر نائب لصورة الملف الشخصي (حلقة منقّطة + أيقونة شخص + شارة كاميرا) أعلى البطاقة، والاسم الأول/الأخير جنبًا إلى جنب في صف (RTL يضع الاسم الأول يمينًا)، وزر أساسي بعنوان `authCreateAccount` («إنشاء الحساب»)، وفاصل `OrDivider` مع صفّ زرّي Apple/Google. رفع الصورة وتسجيل الدخول الاجتماعي عنصران مؤقتان (إشعار «قريبًا») بلا أي اعتمادية جديدة؛ واستُخرج `_OrDivider` إلى ملف مشترك.

New l10n keys (EN + AR): `authCreateAccount`, `authAddPhoto`, `authOr`, `socialApple`, `socialGoogle`. `flutter analyze` clean (no new issues); 120 tests pass.

Touched: `lib/features/auth/register/presentation/register_page.dart`, `lib/features/auth/choose/presentation/auth_choose_page.dart`, `lib/shared/ui/or_divider.dart` (new), `lib/l10n/app_{en,ar}.arb`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Auth feature → sub-features + BLoC + enhanced validation + live username check

Restructured `lib/features/auth/` from a flat `data/domain/presentation` (two `Cubit`s + one combined `AuthPage`) into sub-features: `shared/` (`domain/`, `data/`, `presentation/{validators,widgets}` + `auth_failure.dart`), `login/`, `register/`, `password_recovery/`, `choose/` — each presentation split into `bloc/` + page, putting the auth flow on the mandated **BLoC** pattern (`AGENTS.md` §118). The in-page login/register toggle became separate **`LoginPage`/`RegisterPage`** on their own routes — `AppRoutes.auth` (`/auth`) was renamed `AppRoutes.login` (value unchanged) and `AppRoutes.register` (`/auth/register`) added; the redirect guard's `authSurface` and `app_router` updated to match. `LoginBloc`/`RegisterBloc`/`PasswordRecoveryBloc` replace `AuthCubit`/`PasswordRecoveryCubit` in DI (factories).

**Enhanced validation:** `AuthValidators.email` now uses a real regex; `password` (register/reset) requires ≥8 chars with a letter and a digit (login passes `enforceStrength: false` so legacy short passwords still hit the server 422); forms set `autovalidateMode.onUserInteraction`; a new pure `AuthValidators.strength` scorer drives a `PasswordStrengthMeter` under the register/reset password fields; and the register username field shows a **live availability marker** (spinner/✓/✗) via a debounced `UsernameChanged` event → `AuthRepository.isUsernameAvailable` → new `GET /auth/check-username`, with a page-side stale-guard (`checkedUsername == text`) and silent degrade (marker `unknown`) when the endpoint is unreachable — the register-submit 422 stays the authoritative uniqueness guard. `AppTextField` gained a public `suffixIcon` slot; `mapAuthFailure` centralizes the exception→state mapping.

> ‏أُعيدت هيكلة ميزة المصادقة إلى ميزات فرعية (`shared/`, `login/`, `register/`, `password_recovery/`, `choose/`) بنمط **BLoC**؛ وأصبحت صفحتَي دخول/تسجيل منفصلتين بمسارَيهما (`/auth`, `/auth/register`). قُوّي التحقّق (تعبير بريد حقيقي، كلمة مرور بحرف ورقم للتسجيل/إعادة التعيين، تحقّق مباشر، مقياس قوّة، ومؤشّر توفّر اسم مستخدم مباشر عبر `GET /auth/check-username`).

New l10n keys (EN + AR): `passwordStrengthWeak|Medium|Strong`, `authUsernameAvailable`, `authUsernameTaken`; `validationPassword` reworded. The two cubit tests were ported to `login/`, `register/`, `password_recovery/` bloc tests (plain async via `pumpEventQueue`, no `bloc_test` dep) with username-check + strength coverage; `auth_repository_test` gained `isUsernameAvailable` cases; `session_redirect_test` updated for the split routes. `flutter analyze` clean (no new issues); 120 tests pass.

Touched: `lib/features/auth/**` (restructured), `lib/shared/ui/app_text_field.dart`, `lib/core/di/injection.dart`, `lib/core/router/{app_routes,app_router,session_redirect}.dart`, `lib/core/session/session_controller.dart`, `lib/l10n/app_{en,ar}.arb`, `test/features/auth/**`, `test/core/network/fakes.dart`, `test/core/router/session_redirect_test.dart`, `test/auth_token_model_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`, `osta_readme_files/guides/09_api_endpoints.md`. Paired backend endpoint in `osta_backend`.

## 2026-07-08 — Bottom nav redesign (rounded elevated bar + raised center action)

Rebuilt `AppBottomNavBar` (`lib/shared/ui/app_bottom_nav_bar.dart`): replaced the M3 `NavigationBar` with a rounded, elevated bar (top-rounded `AppRadii.lg`, `AppElevation.high`) of icon+label tabs (selected → brand-green icon + bold label), plus an optional raised circular center action (`centerIcon`/`onCenterTap`) that protrudes above the bar. Tabs split evenly around the center; it's an action, not a tab (never changes the selected index). `RoleShell` threads it through. The customer shell now matches the screenshot — four tabs (Home, Bookings, Store, More) around a green map/location FAB stubbed to a "coming soon" toast; the business shell keeps three tabs, no center. Added `navStore`/`navMore` strings (EN+AR); badges + RTL retained. `navigation_test` + `widget_test` moved off `NavigationBar`; a center-action test added. Analyze clean; 110 tests pass. (State preservation / IndexedStack is not wired yet — the shell body is still a per-index stub, so there is no tab state to preserve.)

> ‏أُعيد بناء `AppBottomNavBar`: استُبدل `NavigationBar` بشريط بحواف دائرية وارتفاع يحوي تبويبات أيقونة+نص (المحدّد بأخضر ونص عريض)، مع زر دائري أوسط مرتفع اختياري يبرز فوق الشريط؛ تنقسم التبويبات حوله وهو إجراء وليس تبويبًا. تعرض واجهة العميل التصميم المطلوب — أربعة تبويبات حول زر خريطة/موقع أخضر (إشعار «قريبًا»)؛ وتبقى واجهة النشاط بثلاثة تبويبات. أُضيف `navStore`/`navMore`؛ ويبقى دعم الشارات وRTL. حُدّثت الاختبارات وأُضيف اختبار للزر الأوسط. (لم يُوصل حفظ حالة التبويبات بعد لأن جسم الواجهة ما زال بديلًا مؤقتًا.)

Touched: `lib/shared/ui/app_bottom_nav_bar.dart`, `lib/features/shell/presentation/role_shell.dart`, `lib/features/customer/shell/presentation/customer_shell_page.dart`, `lib/l10n/app_{en,ar}.arb` (+`navStore`/`navMore`), `test/shared/ui/navigation_test.dart`, `test/widget_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Auth errors as toasts (AppToaster) + localized network error

Added a shared `AppToaster` (`lib/shared/ui/app_toaster.dart`) — a themed `SnackBar` over the root `ScaffoldMessenger` via `AppToaster.messengerKey` (now wired into `MaterialApp`, replacing the private key in `app.dart`); callable from anywhere without a `Scaffold` context. Form-level auth failures (login/register, forgot, reset) now show an error toast instead of inline text: a `BlocListener` fires on `status == failure && fieldErrors.isEmpty`, while per-field 422 errors stay inline. Transport failures (`NetworkException` — connection refused/timeout) are flagged via a new `networkError` bool on `AuthState`/`PasswordRecoveryState` and shown as a localized `errorNetwork` message ("Can't reach the server…", EN + AR) instead of the raw "Network error". The unused `AuthFormError` widget was deleted. Analyze clean; 107 tests pass.

> ‏أُضيف `AppToaster` مشترك يعرض `SnackBar` بالثيم فوق `ScaffoldMessenger` الجذر عبر `AppToaster.messengerKey` (موصول بـ `MaterialApp` بدل المفتاح الخاص في `app.dart`)، ويُستدعى من أي مكان دون سياق `Scaffold`. أخطاء النماذج العامة تظهر الآن كإشعار منبثق بدل النص المضمّن عبر `BlocListener`، وتبقى أخطاء 422 لكل حقل مضمّنة. وتُعلَّم أخطاء النقل (`NetworkException`) بعلم `networkError` وتُعرض برسالة `errorNetwork` مترجمة بدل «Network error». وحُذف `AuthFormError`. التحليل نظيف و107 اختبارات تنجح.

Also added a **debug-only offline login** for the QA / App Review test account: in `kDebugMode` only, `test@osta.com` / `osta123123` skips `/auth/login` and fabricates a local session (`AuthCubit._mockLogin` → `SessionController.onAuthenticated`), so local QA works with the backend down; release compiles it out (the prefill + bypass share `AuthCubit.debugEmail`/`debugPassword`). Covered by `test/features/auth/auth_cubit_test.dart`.

> ‏وأُضيف أيضًا **تسجيل دخول بلا اتصال في وضع التصحيح فقط** لحساب الاختبار: في `kDebugMode` فقط يتخطّى `test@osta.com` / `osta123123` نداء `/auth/login` ويصطنع جلسة محلية، فيعمل الاختبار المحلي والخادم متوقّف؛ ويُحذف في الإصدار. مغطّى باختبار.

Touched: `lib/shared/ui/app_toaster.dart` (new), `lib/app.dart`, `lib/features/auth/presentation/{auth_cubit,password_recovery_cubit,auth_page,forgot_password_page,reset_password_page}.dart`, deleted `lib/features/auth/presentation/widgets/auth_form_error.dart`, `lib/l10n/app_{en,ar}.arb` (+`errorNetwork`), `test/features/auth/auth_cubit_test.dart` (new), `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Auth form fields UX pass (icons, autofill, focus/error rings, +20)

Usability pass on the shared `AppTextField` (`lib/shared/ui/app_text_field.dart`) and the input theme (`lib/core/theme/app_theme.dart`). Text fields now show a brand-green focus ring and an error ring (were borderless), with leading/trailing icons tinting to the brand colour on focus. Every auth field gained a contextual leading icon (mail / lock / person / `@` / reset-code) and OS autofill hints (email, given/family name, new username, current/new password, one-time code, national phone); the login/register form is wrapped in an `AutofillGroup` for password-manager save, and name fields capitalise words. The Egyptian phone field shows an always-visible `+20` dial prefix (with a divider) instead of the old focus-only `prefixText`. `AppTextField` moved from a separate label above the box to a Material **floating label** — the field name is the in-field placeholder in a muted colour and floats to the border in brand green on focus/fill, so the placeholder reads as the field name and is distinct from full-colour typed text (theme sets `hintStyle`/`labelStyle`/`floatingLabelStyle`; the interim example hints + `hint*` strings were dropped). The password eye toggle uses outlined icons + a localized Show/Hide password tooltip (new `showPassword`/`hidePassword` strings). Analyze clean; 107 tests pass (eye-toggle test updated to the outlined icons).

> ‏تحسين قابلية استخدام حقول الإدخال المشتركة وثيم الإدخال: حلقة تركيز خضراء وحلقة خطأ (كانت بلا حدود)، وأيقونات تتلوّن بالأساسي عند التركيز. واكتسب كل حقل مصادقة أيقونة أمامية مناسبة وتلميحات ملء تلقائي (بريد، الاسم الأول/العائلة، اسم مستخدم، كلمة مرور، رمز، هاتف)، مع لفّ نموذج الدخول/التسجيل بـ `AutofillGroup`؛ وتُكبّر حقول الاسم أوّل حرف. ويعرض حقل الهاتف بادئة `+20` ثابتة بفاصل. ويستخدم زر إظهار كلمة المرور أيقونات مفرّغة وتلميحًا مترجمًا (مفتاحان جديدان `showPassword`/`hidePassword`). التحليل نظيف و107 اختبارات تنجح.

Touched: `lib/shared/ui/app_text_field.dart`, `lib/core/theme/app_theme.dart`, `lib/features/auth/presentation/{auth_page,forgot_password_page,reset_password_page}.dart`, `lib/l10n/app_{en,ar}.arb` (+`showPassword`/`hidePassword`), `test/shared/ui/components_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Branded app icon + native splash screen

Replaced the default Flutter launcher icon with the OSTA mark (`assets/images/app_icon.png` — white wordmark + smile on brand green) and added a native OS launch splash matching the in-app `SplashPage` (white OSTA logo on brand green `#0E7A3B`). Uses two one-time native-asset generators added as dev deps — `flutter_launcher_icons` + `flutter_native_splash`, configured in `pubspec.yaml`, run manually (`dart run flutter_launcher_icons` / `dart run flutter_native_splash:create`) — not `build_runner`. Android gets per-density mipmaps + an adaptive icon (background `#0E3725`, padded foreground `assets/images/app_icon_foreground.png` scaled into the safe zone so the launcher mask can't clip it); iOS gets the full `AppIcon.appiconset` + `LaunchImage`/`LaunchScreen`. No Dart/runtime changes; analyze clean, all 107 tests pass.

> ‏استُبدلت أيقونة Flutter الافتراضية بعلامة OSTA (`assets/images/app_icon.png`)، وأُضيفت شاشة إقلاع نظام أصليّة مطابقة لـ `SplashPage` (شعار أبيض على الأخضر `#0E7A3B`). عبر مولّدَي `flutter_launcher_icons` و`flutter_native_splash` (مضافين كتبعيّات تطوير، يُشغَّلان يدويًا، لا `build_runner`). تحصل أندرويد على أيقونات لكل كثافة وأيقونة تكيّفية (خلفية `#0E3725` وطبقة أمامية مبطّنة)، وiOS على مجموعة الأيقونات وشاشة الإقلاع. بلا تغييرات Dart؛ التحليل نظيف و107 اختبارات تنجح.

Touched: `pubspec.yaml` (deps + `flutter_launcher_icons`/`flutter_native_splash` config), `assets/images/app_icon_foreground.png` (new, generated), generated native assets under `android/app/src/main/res/**` (mipmaps, adaptive icon, `colors.xml`, splash drawables + styles) and `ios/Runner/**` (`AppIcon.appiconset`, `LaunchImage`, `LaunchScreen.storyboard`, `Info.plist`), `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Auth + language + role screens UI/UX refactor + branded logo (BrandScaffold)

Refactored the auth, language, and role screens' UI/UX and put the app logo on every one of them. New shared `BrandScaffold` (`lib/shared/ui/brand_scaffold.dart`) renders a collapsing brand-green `SliverAppBar` whose hero band holds the white OSTA logo (shrinks but stays visible as the body scrolls, back button pinned over it, subtle shadow once content scrolls under), a bold centered title, and an optional subtitle; the four auth screens (auth-choose, login/register, forgot, reset) plus the language pick and role chooser now build from it, so the logo carries across the whole logged-out flow (was chooser-only; language/role were flat centered columns). Landing screens (chooser, language, role) show the full lockup (`AppImages.fullLogo`), the inner auth screens the smaller wordmark (`AppImages.logo`) — both white assets that read on `AppColors.brandGreen`. Auth form fields are wrapped in an elevated `AppCard`; language/role keep their selectable `_LanguageCard`/`_RoleCard` bodies. The hardcoded, dark-mode-broken `socialButton` was replaced by the tokenized `AppButton` (secondary + icon) at both call sites and its file deleted; raw `TextStyle(color: error)` form errors became a themed `AuthFormError`. No new strings/deps/routes; auth success sub-views stay icon-led. Analyze clean; all 107 tests pass (incl. the language→role→onboarding→auth-choose flow test).

> ‏أُعيد تصميم واجهة/تجربة شاشات المصادقة واللغة والدور مع وضع شعار التطبيق على كلٍّ منها. يعرض `BrandScaffold` المشترك الجديد (`lib/shared/ui/brand_scaffold.dart`) شريطًا علويًا أخضر متقلّصًا (`SliverAppBar`) يحمل شعار OSTA الأبيض (يصغر لكن يبقى ظاهرًا عند التمرير، وزر الرجوع مثبّت فوقه)، ثم عنوانًا عريضًا متوسّطًا وعنوانًا فرعيًا اختياريًا؛ وتُبنى منه الشاشات الأربع (auth-choose، الدخول/التسجيل، نسيت كلمة المرور، إعادة التعيين) إضافةً إلى شاشتَي اللغة والدور، فامتدّ الشعار عبر تدفّق غير المسجّل كله (كان على شاشة الاختيار فقط، وكانت اللغة/الدور أعمدة مسطّحة). تعرض شاشات الهبوط (الاختيار، اللغة، الدور) الشعار الكامل (`AppImages.fullLogo`)، والشاشات الداخلية النسخة الأصغر (`AppImages.logo`). وأصبحت حقول المصادقة داخل `AppCard`؛ وتحتفظ اللغة/الدور ببطاقاتها القابلة للاختيار. واستُبدل `socialButton` المكسور في الوضع الداكن بـ `AppButton` وحُذف ملفه، وصارت أخطاء النماذج عبر `AuthFormError`. بلا نصوص/حزم/مسارات جديدة. التحليل نظيف وكل الاختبارات (107) تنجح.

Touched: `lib/shared/ui/brand_scaffold.dart` (new, moved+renamed from `features/auth/presentation/widgets/auth_scaffold.dart`), `lib/features/auth/presentation/widgets/auth_form_error.dart` (new), `lib/features/auth/presentation/{auth_choose_page,auth_page,forgot_password_page,reset_password_page}.dart`, `lib/features/onboarding/presentation/language_page.dart`, `lib/features/role/presentation/role_chooser_page.dart`, deleted `lib/features/onboarding/widget/social_button.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Auth-flow reorder + language/role/onboarding every logged-out launch + back chain

Reordered the logged-out flow to `splash → language → role → onboarding → auth-choose → auth → shell` (role now before onboarding). The language, role, and onboarding screens now re-show on **every logged-out launch** — each gated by an in-memory `SessionState` flag (`languageAcknowledged`, `roleAcknowledged`, `onboardingAcknowledged`, reset each cold `bootstrap`) rather than the persisted locale/role; the saved locale + role are the pre-selected defaults (marked with an accent border + check on the cards). The role gate also forces the chooser whenever `activeRole` is null; a held token skips all three. The auth-choose back button returns to onboarding via `SessionController.resetOnboarding()` (role + language stay); login/register back → auth-choose. Onboarding gains a Skip button (top-right, hidden on the last slide) that jumps to auth-choose. The earlier "language not showing" report was not a bug — it was correctly gated by the saved locale; this change makes it (and the role chooser) repeat by request.

> ‏أُعيد ترتيب تدفّق المستخدم غير المسجّل إلى `splash → language → role → onboarding → auth-choose → auth → shell` (أصبح اختيار الدور قبل الـ onboarding). وتظهر شاشات اللغة والدور والـ onboarding الآن **في كل تشغيل طالما غير مسجّل** — كلٌّ محكوم بعلم في الذاكرة (`languageAcknowledged` و`roleAcknowledged` و`onboardingAcknowledged`، تُصفَّر مع كل إقلاع) بدل الاعتماد على اللغة/الدور المحفوظَين؛ ويكون المحفوظ هو الخيار الافتراضي (مُعلَّمًا بإطار وعلامة صح على البطاقات). ويفرض حاجزُ الدور المُختارَ أيضًا كلما كان `activeRole` فارغًا؛ ويتخطّى وجودُ التوكن الثلاثةَ جميعًا. وزرّ الرجوع في auth-choose يعود إلى الـ onboarding عبر `SessionController.resetOnboarding()` (يبقى الدور واللغة). ولم يكن بلاغ «اللغة لا تظهر» عيبًا — كانت محكومة صحيحًا باللغة المحفوظة؛ وهذا التغيير يجعلها (والدور) تتكرّر بناءً على الطلب.

Touched: `lib/core/session/{session_state,session_controller}.dart`, `lib/core/router/session_redirect.dart`, `lib/features/auth/presentation/auth_choose_page.dart`, `lib/features/onboarding/presentation/language_page.dart`, `lib/features/onboarding/page/onboarding_page.dart`, `lib/features/role/presentation/role_chooser_page.dart`, `lib/l10n/app_{en,ar}.arb`, `test/{core/router/session_redirect_test,core/session/session_controller_test,widget_test}.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-07 — Auth-flow enhancements: onboarding gate + redesigned language & auth-choose screens

Reworked the logged-out first-run flow to `splash → language → onboarding → role → auth-choose → auth → shell`. Onboarding is reachable again and re-shows on **every launch while logged out**, gated by a new in-memory `SessionState.onboardingAcknowledged` flag (reset each cold start) checked in `resolveRedirect`; its finish button calls `SessionController.acknowledgeOnboarding()`. The carousel became intro-only + localized. `LanguagePage` was redesigned; a new `AuthChoosePage` (`/auth/choose`, the default unauthenticated landing) offers Sign in / Create account — routing into `AuthPage` via a `?mode=login|register` param (`AuthCubit.setMode`) — plus stubbed Google/Apple social buttons. Guard `authSurface` whitelists `/auth/choose`. Added **back navigation**: auth-choose back clears the role (`switchRole` → role chooser) and login/register back returns to `/auth/choose`; `clearingRole` preserves `onboardingAcknowledged` so back doesn't re-trigger onboarding.

> ‏أُعيد تصميم تدفّق أول تشغيل للمستخدم غير المسجّل إلى `splash → language → onboarding → role → auth-choose → auth → shell`. عادت شاشة الـ onboarding للظهور، وتظهر **في كل تشغيل طالما المستخدم غير مسجّل** عبر علم `onboardingAcknowledged` في الذاكرة (يُصفَّر مع كل إقلاع) يُفحَص في `resolveRedirect`؛ ويستدعي زرّ الإنهاء `SessionController.acknowledgeOnboarding()`. أصبح الكاروسيل تعريفيًا فقط ومترجمًا. وأُعيد تصميم `LanguagePage`، وأُضيفت شاشة `AuthChoosePage` (`/auth/choose`، صفحة الهبوط الافتراضية لغير المسجّل) تعرض «تسجيل الدخول / إنشاء حساب» — وتنتقل إلى `AuthPage` عبر مُعامِل `?mode=login|register` — إضافةً إلى أزرار Google/Apple كعناصر نائبة.

Touched (code + docs): `lib/core/session/{session_state,session_controller}.dart`, `lib/core/router/{app_routes,session_redirect,app_router}.dart`, `lib/features/onboarding/{page/onboarding_page,presentation/language_page,widget/social_button}.dart`, `lib/features/auth/presentation/{auth_choose_page,auth_page,auth_cubit}.dart`, `lib/l10n/app_{en,ar}.arb`, `test/{core/router/session_redirect_test,widget_test}.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-06 — M1 auth email/password surface + password recovery ([#35](https://github.com/YoussefSalem582/Osta-App/issues/35))

Extended the shared auth surface toward the M1 email+password epic (no OTP): register now collects a unique username and a required Egyptian **+20** phone (masked, normalized to E.164), confirms the password, and gates submit behind a Terms/Privacy checkbox; login gains a password visibility toggle and a "forgot password?" link. Added a two-step recovery flow — `ForgotPasswordPage` (`POST /forgot-password`) → `ResetPasswordPage` (`POST /reset-password`) — on a new `PasswordRecoveryCubit` and `/auth/forgot-password` + `/auth/reset-password` routes (whitelisted in `resolveRedirect`). `AuthRepository` gained `logout` (best-effort revoke + always-clear, wired through `SessionController.signOut`), `forgotPassword`, and `resetPassword`; server 422s now surface inline per field via `AuthState.fieldErrors`. Endpoints follow the canonical catalogue.

> ‏تم توسيع واجهة المصادقة نحو ملحمة M1 بالبريد وكلمة المرور (بدون OTP): يجمع التسجيل الآن اسم مستخدم فريدًا ورقم هاتف مصري **+20** إلزاميًا (بقناع، ويُطبَّع إلى E.164) ويؤكّد كلمة المرور ويشترط قبول الشروط والخصوصية؛ ويحصل الدخول على زر إظهار كلمة المرور ورابط «نسيت كلمة المرور؟». وأُضيف تدفّق استعادة من خطوتين — `ForgotPasswordPage` ← `ResetPasswordPage` — على `PasswordRecoveryCubit` جديد ومسارَي `/auth/forgot-password` و`/auth/reset-password`. واكتسب `AuthRepository` الدوال `logout` (إبطال أفضل جهد مع مسح دائم، موصولة بـ `SessionController.signOut`) و`forgotPassword` و`resetPassword`؛ وتظهر أخطاء 422 الآن مضمّنة لكل حقل.

Touched (code + docs): `lib/features/auth/**` (auth page, `auth_cubit`, `auth_validators`, `password_recovery_cubit`, forgot/reset pages, repository), `lib/core/{router,session,di,auth}`, `lib/shared/ui/app_text_field.dart`, `lib/l10n/app_{en,ar}.arb`, matching tests, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-07 — Debug-only login prefill for the QA/App Review test account

`AuthPage` now prefills the email/password fields with the test account (`test@osta.com` / `osta123123`) under `kDebugMode` only — release builds compile the block out. Speeds local sign-in and gives App Review a one-tap login; the account must still exist backend-side (`/auth/login`). Code + docs change.

> ‏يملأ `AuthPage` الآن حقلي البريد وكلمة المرور بحساب الاختبار (`test@osta.com` / `osta123123`) في وضع التصحيح فقط (`kDebugMode`) — تُحذف الكتلة في إصدارات الإنتاج. يُسرّع تسجيل الدخول محليًا ويمنح مراجعة المتجر دخولًا بنقرة واحدة؛ ويجب أن يظل الحساب موجودًا في الخادم (`/auth/login`).

Touched: `lib/features/auth/presentation/auth_page.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-06 — `develop`/`main` branching model adopted

Introduced a long-lived **`develop`** integration branch and made **`main`** release-only: feature/chore branches now cut from `develop` and PR into `develop`; `main` advances **only** through a `develop → main` release PR + SemVer tag (`v0.<n>.0` per milestone, `v1.0.0` = MVP). Retargeted the open first-run PR ([#67](https://github.com/YoussefSalem582/Osta-App/pull/67)) to `develop`.

> ‏اعتُمد نموذج فروع `develop`/`main`: أُنشئ فرع تكامل دائم **`develop`** وأصبح **`main`** للإصدار فقط — تتفرّع فروع الميزات/المهام من `develop` وتُدمج فيه، ولا يتقدّم `main` إلا عبر طلب دمج `develop → main` مع وسم إصدار (`v0.<n>.0` لكل مرحلة و`v1.0.0` عند الـ MVP). وأُعيد توجيه PR أول تشغيل ([#67](https://github.com/YoussefSalem582/Osta-App/pull/67)) إلى `develop`.

Touched: `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `ARCHITECTURE.md`, `OSTA_plan.md` (§13.1–§13.3), `OSTA_TODO.md`, `CURRENT_STATUS.md`, `guides/01_folder_structure.md`, `guides/03_how_to_add_new_feature.md`, `reference/COMMON_PITFALLS.md`, `.cursor/rules/git-commits.mdc`, `.claude/commands/add-feature.md` + `new-screen.md`, `.agents/skills/add-feature/SKILL.md`, `.cursor/skills/add-feature/SKILL.md`, and `.github/workflows/ci.yml` (added `develop` to CI push triggers). Docs + CI-config change.

## 2026-07-06 — First-run flow & 4-role split rebased onto `main`

The first-run flow & 4-role split ([epic #32](https://github.com/YoussefSalem582/Osta-App/issues/32) · [PR #67](https://github.com/YoussefSalem582/Osta-App/pull/67)) was rebased onto current `main` and adapted to the post-[#69](https://github.com/YoussefSalem582/Osta-App/pull/69) plain-Dart conventions: the feature's `injectable`/`freezed`/`fpdart` annotations and the removed dev `/gallery` route were dropped, session/auth dependencies are registered by hand in `configureDependencies()` (`AuthCubit` as a factory, `AppRouter` built with the `SessionController` singleton), and the obsolete gallery redirect test was deleted.

> ‏أُعيد ترتيب فرع تدفّق أول تشغيل وانقسام الأدوار الأربعة ([الملحمة #32](https://github.com/YoussefSalem582/Osta-App/issues/32) · [PR #67](https://github.com/YoussefSalem582/Osta-App/pull/67)) فوق `main` الحالي وجرت مواءمته مع اصطلاحات Dart البسيطة بعد [#69](https://github.com/YoussefSalem582/Osta-App/pull/69): حُذفت تعليقات `injectable`/`freezed`/`fpdart` ومسار `/gallery` التطويري المُزال، وسُجِّلت تبعيات الجلسة والمصادقة يدويًا في `configureDependencies()` (‏`AuthCubit` كمصنع، و`AppRouter` يُبنى بمفرد `SessionController`)، وحُذف اختبار توجيه المعرض المتقادم.

`CHANGELOG.md` and `CURRENT_STATUS.md` updated to match. Code + docs change on the feature branch — no app code merged to `main` yet.

## 2026-07-05 — Branch-naming rule tightened (no tool-generated names)

All docs and AI-agent configs now require **hand-written, descriptive, lowercase kebab-case** branch names (`<type>/<issue>-<slug>`, e.g. `feat/44-booking-funnel`, `fix/auth-401-loop`) and forbid auto-generated/tool-default names (random suffixes, `claude/...`, `cursor/...`, `codex/...`) — rename with `git branch -m <type>/<issue>-<slug>` before opening a PR.

> ‏كل المستندات وإعدادات وكلاء الذكاء الاصطناعي أصبحت تشترط أسماء فروع مكتوبة يدويًا ووصفية بصيغة `<type>/<issue>-<slug>` (مثل `feat/44-booking-funnel`)، وتمنع الأسماء المولَّدة تلقائيًا من الأدوات (لواحق عشوائية أو `claude/...` أو `cursor/...`) — أعد التسمية بـ `git branch -m` قبل فتح الـ PR.

Touched: `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `ARCHITECTURE.md`, `OSTA_plan.md`, `OSTA_TODO.md`, `guides/03_how_to_add_new_feature.md`, `CURRENT_STATUS.md`, `.cursor/rules/git-commits.mdc`, `.claude/commands/{add-feature,new-screen}.md`, `.agents/skills/add-feature/SKILL.md`, `.cursor/skills/add-feature/SKILL.md`. Docs-only change.

## 2026-07-05 — `OSTA_TODO.md` zero-to-production checklist

Added [`../OSTA_TODO.md`](docs/OSTA_TODO.md) — the trackable checkbox roadmap companion to [`../OSTA_plan.md`](docs/OSTA_plan.md) (the plan is the rulebook; the TODO is the what/when).

> ‏أُضيف [`../OSTA_TODO.md`](docs/OSTA_TODO.md) — قائمة مهام قابلة للتتبّع بمربّعات اختيار، مرافقة لـ [`../OSTA_plan.md`](docs/OSTA_plan.md) (الخطة هي كتاب القواعد، وقائمة المهام هي ماذا ومتى).

Phases: 0 foundation (✅ pre-checked) → 1 M0 wrap (l10n #30 + talker/offline/motion chores) → 2–8 the feature milestones with per-epic owners/branches/key ACs and a 🏷️ release tag per phase → **9 production readiness & launch** (platform config, production credentials for Maps/Firebase/social/Paymob/Reverb, signing + store listings with data-safety/privacy labels, release CI, crash-reporting ADR, hardening drills — offline/realtime/push/payments/perf/a11y/security/l10n — beta tracks, staged `v1.0.0` rollout) → 10 post-launch/Phase 2. Cross-linked from `OSTA_plan.md` §0/§14, `INDEX.md`, and `CURRENT_STATUS.md`. Docs-only change.

## 2026-07-05 — `OSTA_plan.md` master build instructions for AI agents

Added [`../OSTA_plan.md`](docs/OSTA_plan.md) — a root-level, English, system-prompt-style plan that AI agents follow to deliver the 31 open epics on top of the existing M0 foundation.

> ‏أُضيف [`../OSTA_plan.md`](docs/OSTA_plan.md) — خطة بأسلوب موجّهات النظام (بالإنجليزية) في جذر المستودع يتبعها وكلاء الذكاء الاصطناعي لتسليم الملاحم المفتوحة الـ 31 فوق أساس M0 الحالي.

Contents: the 11 owner mandates (Clean Architecture + BLoC, dark/light, responsive, ar/en RTL, animations/transitions, reusable widgets + centralized colors/fonts/images/icons/text, `talker`, `skeletonizer`, document everything, offline-first, clean git graph with releases/tags); **four explicit amendments to the canon** — `talker_*` replaces `pretty_dio_logger`, `skeletonizer` for all loading states (overrides epic `shimmer` mentions), a new offline-first spec (`lib/core/offline/`: `sqflite` JSON-document cache + pending-operations queue + `SyncEngine` + `connectivity_plus`, with a per-feature cached/queued/online-only policy table), and a SemVer release/tag convention (`v0.<n>.0` per milestone, `v1.0.0` = MVP, annotated tags on `main`); source-of-truth precedence with a warning that the epics' stale codegen/Riverpod package stanza is superseded ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69)); and the milestone-by-milestone execution plan (M0 finish → M1…M5 → Shop/Home/Notifications → M6/Phase 2) with per-epic branch names, key ACs, endpoints, offline policies, and a global/per-epic/never package policy. Docs-only change — no code affected; a follow-up to sync `AGENTS.md` with the four amendments is noted in the plan's appendix.

## 2026-07-05 — Official Dart & Flutter agent skills vendored into `.claude/skills/`

Vendored a curated copy of the official Agent Skills published by the Flutter and Dart teams ([announcement](https://blog.flutter.dev/introducing-skills-for-dart-and-flutter-23837c6ec0ae) · upstream [`flutter/skills`](https://github.com/flutter/skills) @ `0d624f3`, [`dart-lang/skills`](https://github.com/dart-lang/skills) @ `8ce8492`). Claude Code auto-discovers each `SKILL.md` and loads it on demand.

> ‏أُدرجت نسخة منتقاة من «مهارات الوكيل» الرسمية لفريقي Flutter وDart في `.claude/skills/`؛ يكتشفها Claude Code تلقائيًا ويحمّلها عند الحاجة.

- **Installed (14)**: 8 Flutter (integration/widget tests, widget previews, responsive layout, layout debugging, hand-written JSON, go_router routing, ARB/gen-l10n localization) + 6 Dart (unit tests, coverage, runtime errors, package conflicts, static analysis, pattern matching).
- **Excluded (7)**: `flutter-use-http-package` (vs `ApiClient`-only rule), `flutter-apply-architecture-best-practices` (MVVM/`Result` vs BLoC + thrown `Failure`s), `dart-generate-test-mocks` + `dart-use-ffigen` (codegen vs no-codegen rule), `dart-migrate-to-checks-package`, `dart-build-cli-app`, `dart-setup-ffi-assets` (irrelevant).
- **Precedence**: skills are verbatim upstream copies; where generic advice conflicts with OSTA conventions, `AGENTS.md`/`CLAUDE.md` win — deltas and the re-vendor workflow documented in [`.claude/skills/README.md`](../.claude/skills/README.md).
- `CHANGELOG.md`, `CURRENT_STATUS.md`, and the `CLAUDE.md` "Where to look" table updated.

## 2026-07-05 — AI-agent config set (per-tool instruction files)

Added the per-tool agent scaffolding mirroring a proven layout, all adapted to OSTA's plain-Dart stack:

- **Root**: `CONTRIBUTING.md` (branch/commit/PR/quality-gate rules, bilingual), `ARCHITECTURE.md` (layers, data flow, DI, routing, adding a feature — bilingual), `CURSOR.md` (Cursor shim).
- **`.agents/`**: generic `AGENTS.md` shim + 8 scoped rules (`project-scope`, `dart-conventions`, `feature-architecture`, `bloc-patterns`, `api-integration`, `ui-design-system`, `security`, `documentation-updates`) + 3 project-tuned skills (`add-feature`, `add-api`, `add-language`).
- **`.claude/`**: 8 slash commands (`add-feature`, `add-api`, `add-language`, `new-screen`, `review`, `test`, `update-docs`, `clean-build`) + `settings.json` (approved-command allowlist).
- **`.codex/AGENTS.md`**, **`.github/copilot-instructions.md`**, **`.github/workflows/docs.yml`** (markdownlint + lychee link-check).
- **`.cursor/`**: 9 `.mdc` rules (the 8 above + `git-commits`) + skills mirror.

Every file encodes the real stack — sealed `Failure` + `try`/`catch` (no `Either`/`fold`), manual `get_it` (no `injectable`/`build_runner`), `ApiClient`/`ApiException`, no offline queue — and links to `AGENTS.md` + `docs/ROADMAP.md`. Verified: correct frontmatter, no stale-stack leakage, all relative links resolve.

## 2026-07-05 — Synced to the plain-Dart refactor + bilingual (EN/AR)

Re-checked the codebase after the "defer advanced Flutter tooling" refactor ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69)) and corrected the whole doc set, then made it bilingual.

> ‏بعد مراجعة الكود عقب إعادة الهيكلة "تأجيل أدوات Flutter المتقدّمة" ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69))، صُحّحت مجموعة التوثيق بالكامل ثم أُضيفت لها الترجمة العربية.

**Codebase reality now** (see [`docs/ROADMAP.md`](../docs/ROADMAP.md)): no `fpdart`/`Either`/`Result<T>` — a `sealed class Failure implements Exception` thrown with plain `try`/`catch`; no `freezed`/`json_serializable`/`injectable`/`build_runner` — plain `Equatable` models with hand-written `fromJson`/`toJson` and **manual** `get_it` registration; single `BASE_URL` dart-define (no `AppFlavor`/`FLAVOR`); `/gallery` component-gallery route removed; CI collapsed to one `format · analyze · test` job. The advanced tooling is **deferred, not rejected** — phased reintroduction plan in `docs/ROADMAP.md`.

> ‏**واقع الكود الآن** (راجع [`docs/ROADMAP.md`](../docs/ROADMAP.md)): لا يوجد `fpdart`/`Either`/`Result<T>` — بل `sealed class Failure implements Exception` يُرمى ويُلتقط بـ `try`/`catch` عادي؛ ولا يوجد `freezed`/`json_serializable`/`injectable`/`build_runner` — بل نماذج `Equatable` بسيطة بدوالّ `fromJson`/`toJson` مكتوبة يدويًا وتسجيل `get_it` **يدوي**؛ و`BASE_URL` واحد عبر dart-define (بلا `AppFlavor`/`FLAVOR`)؛ وحُذف مسار معرض المكوّنات `/gallery`؛ واختُصر الـ CI إلى مهمّة واحدة `format · analyze · test`. الأدوات المتقدّمة **مؤجّلة لا مرفوضة** — الخطة المرحلية في `docs/ROADMAP.md`.

**Doc changes**:

- `AGENTS.md` + `CLAUDE.md` — corrected (error/DI/model/config/CI/commands) and made bilingual; added a "Plain-Dart, No Codegen" section and ROADMAP pointers.
- `decisions/004` rewritten (sealed `Failure` + `try`/`catch`; fpdart deferred), `decisions/005` rewritten (no codegen; freezed/json_serializable/injectable deferred), `decisions/008` (single CI job).
- All guides, feature docs, and reference docs: stale codegen/fpdart/flavor/gallery/CI facts purged, ROADMAP linked, and Arabic (RTL) prose added alongside English (headings bilingual; identifiers/tables/endpoints stay English).
- `CHANGELOG.md` + `CURRENT_STATUS.md` updated.

## 2026-07-02 — Initial documentation set

Created the full documentation tree, mirroring the structure proven on a sibling project and grounded in the two GitHub issue trackers ([Osta-App](https://github.com/YoussefSalem582/Osta-App/issues) · [osta_backend](https://github.com/YoussefSalem582/osta_backend/issues)) plus the actual M0 codebase:

- **Root**: [`AGENTS.md`](../AGENTS.md) (canonical agent/contributor conventions), [`CLAUDE.md`](../CLAUDE.md) (Claude Code shim), [`CHANGELOG.md`](../CHANGELOG.md) (Keep a Changelog, seeded from the four merged M0 PRs).
- **Index & status**: [`INDEX.md`](INDEX.md) (task-oriented entry point + doc map), [`CURRENT_STATUS.md`](CURRENT_STATUS.md) (M0 snapshot + metrics + epic status).
- **Guides** ([guides/](guides/)): 01 folder structure · 02 architecture · 03 add a feature · 04 wire an API · 05 localization · 06 theme tokens · 07 reusable components · 08 security & environment · 09 API endpoint catalogue (from backend epics, with app-status column) · 10 testing · 11 backend ↔ app connectivity.
- **Feature docs** ([features/](features/README.md)): 22 docs matched 1:1 to the app epics (#28–#62) — bilingual overviews, mockup embeds from the `design-assets` branch, endpoint tables, planned architecture, testing expectations, cross-repo links.
- **Decisions** ([decisions/](decisions/README.md)): 8 ADRs (Clean Architecture + BLoC, single app multi-role, go_router role redirect, fpdart Either, codegen stack, Dio envelope + Sanctum, Arabic-first l10n, GitHub Actions CI).
- **Reference** ([reference/](reference/)): ONBOARDING, GLOSSARY, COMMON_PITFALLS, TROUBLESHOOTING, DELIVERY_PLAN (milestones, owners, cross-repo mirror, build order).

Docs-only change — no code or behaviour affected.
