# Troubleshooting / حل المشكلات

> [INDEX](../INDEX.md) > Troubleshooting
>
> Incident recipes — Symptom → Cause → Fix. Check here first when something breaks.

This project runs on **plain, readable Dart** — no code generation. Models are `Equatable` classes with hand-written `fromJson`/`toJson`, dependency injection is registered manually in `get_it`, and errors are a sealed `Failure` hierarchy caught with `try`/`catch`. The only generated code is localization (`flutter gen-l10n`). Advanced tooling (`freezed`, `json_serializable`, `injectable`, `fpdart`, build flavors) is **deferred, not rejected** — see the phased plan in [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

> ‏المشروع ده بيشتغل بـ **Dart بسيطة وسهلة القراءة** — من غير أي توليد كود. الموديلات عبارة عن كلاسات `Equatable` مع `fromJson`/`toJson` مكتوبة باليد، وحقن الاعتماديات بيتسجّل يدويًا في `get_it`، والأخطاء عبارة عن هيراركية `Failure` مغلقة (sealed) بتتمسك بـ `try`/`catch`. الكود المولّد الوحيد هو الترجمة (`flutter gen-l10n`). الأدوات المتقدمة (`freezed`، `json_serializable`، `injectable`، `fpdart`، الـ build flavors) **مؤجّلة مش مرفوضة** — بُص على الخطة المرحلية في [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

## Missing `AppLocalizations` getter after adding a string / اختفاء getter الترجمة بعد إضافة نص

- **Symptom**: `The getter 'foo' isn't defined for the type 'AppLocalizations'`.
- **Cause**: key added to `app_en.arb` but not `app_ar.arb`, or `flutter gen-l10n` not run.
- **Fix**: add the key to **both** ARB files, run `flutter gen-l10n`. With `nullable-getter: false`, a missing Arabic key is a hard error.

> ‏الترجمة هي الكود المولّد الوحيد في المشروع. أي مفتاح جديد لازم يتحط في ملفّي الـ ARB الاتنين، وبعدها تشغّل `flutter gen-l10n`. لأن `nullable-getter: false` مضبوطة، أي مفتاح عربي ناقص بيبقى خطأ صريح بيوقف الـ build.

## CI fails on formatting / الـ CI بيفشل بسبب التنسيق

- **Symptom**: `dart format --set-exit-if-changed` fails the single "format · analyze · test" job.
- **Cause**: unformatted code.
- **Fix**: `dart format .`, commit.

> ‏الـ CI عبارة عن job واحدة اسمها "format · analyze · test" بتشغّل `flutter pub get` → `flutter gen-l10n` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`. لو التنسيق غلط الـ job بتوقف — شغّل `dart format .` واعمل commit. مفيش جوبز build للأندرويد أو الـ iOS دلوقتي؛ دي مؤجّلة (ROADMAP المرحلة 4).

## Analyzer or build fails after cloning / الأنالايزر أو الـ build بيفشل بعد الاستنساخ

- **Symptom**: undefined `AppLocalizations`, or analyze errors on a fresh checkout.
- **Cause**: localization not generated yet — `lib/core/l10n/` is git-ignored and produced on demand.
- **Fix**: run `flutter pub get` then `flutter gen-l10n` (it also runs automatically on `flutter run`/`flutter build`). There is **no** `build_runner` step — the project has no `*.g.dart`, `*.freezed.dart`, or `injection.config.dart` to generate.

> ‏مفيش خطوة `build_runner` خالص. لو الأنالايزر بيشتكي بعد استنساخ جديد، غالبًا السبب إن الترجمة لسه ما اتولّدتش — شغّل `flutter pub get` وبعدها `flutter gen-l10n`. المجلد `lib/core/l10n/` بس هو المتجاهَل في git؛ مفيش ملفات `.g.dart` أو `.freezed.dart` أو `.config.dart` في المشروع أصلًا.

## A new service isn't found at runtime / خدمة جديدة مش متلاقية وقت التشغيل

- **Symptom**: `Object/factory with type X is not registered inside GetIt` or a null service.
- **Cause**: DI is **manual** — a new service needs a hand-written registration line; there is no annotation scan.
- **Fix**: add a `registerLazySingleton`/`registerSingleton` line to `configureDependencies()` in `lib/core/di/injection.dart`, resolving its dependencies via `getIt()`. No `@injectable`, no `build_runner`.

> ‏حقن الاعتماديات يدوي بالكامل — مفيش annotations ولا scan. أي خدمة جديدة محتاجة سطر تسجيل مكتوب باليد جوه `configureDependencies()` في `lib/core/di/injection.dart`، وبتجيب اعتمادياتها عن طريق `getIt()`. لو لقيت خطأ "not registered inside GetIt"، غالبًا نسيت تضيف السطر ده.

## Infinite 401 loop / immediate logout / لفة 401 لا نهائية أو خروج فوري

- **Symptom**: requests keep 401'ing, or the app bounces to login right after login.
- **Cause**: refresh token invalid/expired, or bad `BASE_URL`.
- **Fix**: `AuthInterceptor` refreshes once then emits `AuthEvents.onSessionExpired`; confirm `TokenStorage` holds a valid refresh token and `BASE_URL` points at `/api/v1`. Re-login clears it.

> ‏الـ `AuthInterceptor` بيعمل refresh مرة واحدة بس، وبعدها بيطلق `AuthEvents.onSessionExpired`. اتأكد إن `TokenStorage` فيه refresh token صالح وإن الـ `BASE_URL` بيوصل لـ `/api/v1`. تسجيل الدخول من جديد بيصفّي الحالة دي.

## `ServerFailure` / `ServerException` on a valid-looking request / خطأ سيرفر على طلب سليم الشكل

- **Symptom**: a `ServerFailure` surfaces (or the network layer throws `ServerException`) even though the endpoint works in a browser.
- **Cause**: the response isn't the ApiResponse envelope (wrong base URL / hitting a non-API route), or a real 5xx.
- **Fix**: verify `AppConfig.baseUrl` ends at `/api/v1`; check the raw response is `{success, data, …}`.

> ‏لو ظهر `ServerFailure` (أو الطبقة الشبكية رمت `ServerException`) مع إن الـ endpoint شغّال في المتصفح، غالبًا الرد مش على شكل الـ ApiResponse envelope — يعني الـ base URL غلط أو بتضرب على route مش تابع للـ API. اتأكد إن `AppConfig.baseUrl` بينتهي بـ `/api/v1` وإن الرد الخام على شكل `{success, data, …}`.

## Error handling: `try`/`catch`, not `.fold()` / معالجة الأخطاء بـ try/catch مش fold

- **Symptom**: looking for `Either`, `Result<T>`, or `.fold()` to handle a repository error and not finding them.
- **Cause**: this project uses a **sealed `Failure`** hierarchy, not functional error types. Repositories **throw** a `Failure`; callers use plain `try`/`catch`.
- **Fix**: catch `Failure` (or a specific subtype like `NetworkFailure`/`ServerFailure`/`UnknownFailure` from `lib/core/error/failure.dart`) in the bloc/caller. The network layer still throws typed `ApiException`s (`api_exception.dart`); repositories catch those and convert to a `Failure`. `fpdart`/`Either` is deferred — see [../../docs/ROADMAP.md](../../docs/ROADMAP.md) (Phase 5).

> ‏المشروع مابيستخدمش `Either` ولا `Result<T>` ولا `.fold()`. الأخطاء عبارة عن هيراركية `Failure` مغلقة في `lib/core/error/failure.dart` — الـ repositories بترمي `Failure`، والـ bloc/المستدعي بيمسكها بـ `try`/`catch` عادي. الطبقة الشبكية لسه بترمي `ApiException` بأنواعها، والـ repository بيمسكها ويحوّلها لـ `Failure`. الأسلوب ده متعمّد عشان يبقى سهل على فريق جديد على Flutter. `fpdart` مؤجّل (ROADMAP المرحلة 5).

## Bad login returns 422, not 401 / تسجيل دخول غلط بيرجّع 422 مش 401

- **Symptom**: wrong password surfaces as a validation error, not "unauthenticated".
- **Cause**: intended backend contract.
- **Fix**: handle login failure as `ValidationException` (read `fieldErrors`), not `UnauthenticatedException`. See [COMMON_PITFALLS.md](COMMON_PITFALLS.md).

> ‏كلمة السر الغلط بتظهر كخطأ تحقّق (validation) مش "غير مصادَق" — ده سلوك مقصود من الباك اند. عالج فشل تسجيل الدخول كـ `ValidationException` واقرأ `fieldErrors`، مش كـ `UnauthenticatedException`.

## Cairo font weights look off / أوزان خط Cairo شكلها غلط

- **Symptom**: text is too heavy/synthetic-bold.
- **Cause**: applying `FontWeight.bold` on top of the variable font, or bypassing `AppTypography`.
- **Fix**: use `Theme.of(context).textTheme.*`; weights come from `FontVariation` in `AppTypography`.

> ‏لو النص طالع تقيل أو bold صناعي، غالبًا حد حط `FontWeight.bold` فوق الخط المتغيّر (variable font) أو تجاوز `AppTypography`. استخدم `Theme.of(context).textTheme.*`؛ الأوزان بتيجي من `FontVariation` جوه `AppTypography`.

## `/centers/nearby` returns empty locally / `/centers/nearby` بترجع فاضية محليًا

- **Symptom**: nearby search returns nothing against a local backend.
- **Cause**: PostGIS not available in the local DB — the backend degrades to an empty page.
- **Fix**: point at a PostGIS-enabled environment (e.g. the dev API), or enable PostGIS locally. Not an app bug.

> ‏لو البحث القريب مابيرجّعش حاجة على باك اند محلي، السبب إن PostGIS مش متوفّر في قاعدة البيانات المحلية، فالباك اند بيرجّع صفحة فاضية. وجّه على بيئة فيها PostGIS (زي الـ dev API) أو فعّل PostGIS محليًا. ده مش باج في التطبيق.

## `flutter_secure_storage` errors on a fresh simulator / أخطاء التخزين الآمن على محاكي جديد

- **Symptom**: read/write throws on first run of a clean simulator.
- **Cause**: keychain/keystore not initialized yet.
- **Fix**: cold-restart the simulator; ensure entitlements/keychain access group are set for iOS.

> ‏لو القراءة/الكتابة بترمي خطأ في أول تشغيل على محاكي نضيف، السبب إن الـ keychain/keystore لسه ما اتهيّأش. اعمل cold-restart للمحاكي، واتأكد إن الـ entitlements ومجموعة وصول الـ keychain مضبوطة للـ iOS.

## Visual token change hard to verify / تغيير في التوكنات صعب التحقق منه

- **Symptom**: unsure a colour/spacing change looks right in both themes and directions.
- **Cause**: no dedicated component gallery — the `/gallery` route and `ComponentGalleryPage` were removed.
- **Fix**: run the app on a real screen that uses the token, then toggle light/dark and LTR/RTL. Exercise the shared widgets (`AppButton`, `AppCard`, `AppTextField`, `AppTopBar`, `AppBottomNavBar`) via the widget tests in `test/shared/ui/`. Update golden tests (`flutter test --update-goldens`) if the change is intentional.

> ‏مفيش معرض مكوّنات مخصص دلوقتي — الـ route القديمة `/gallery` و`ComponentGalleryPage` اتشالوا. للتأكد من تغيير لون أو مسافة، شغّل التطبيق على شاشة حقيقية بتستخدم التوكن، وبدّل بين الفاتح/الغامق و LTR/RTL. جرّب الـ widgets المشتركة عن طريق اختبارات `test/shared/ui/`، وحدّث الـ golden tests بـ `flutter test --update-goldens` لو التغيير مقصود.

## Related / روابط ذات صلة

- [../guides/10_testing.md](../guides/10_testing.md) · [COMMON_PITFALLS.md](COMMON_PITFALLS.md) · [../guides/04_how_to_add_new_api.md](../guides/04_how_to_add_new_api.md) · [../../docs/ROADMAP.md](../../docs/ROADMAP.md)
