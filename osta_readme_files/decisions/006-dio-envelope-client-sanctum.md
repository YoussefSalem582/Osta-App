# ADR 006 — Dio behind an envelope-aware ApiClient + Sanctum tokens

## Status

Accepted (2026-07-02, amended 2026-07-05)

## Context / السياق

The backend wraps every response in the ApiResponse envelope (`{success, data, meta}` / `{success:false, error}`) and authenticates with **Laravel Sanctum dual tokens** (access ~60 min + refresh 30 d, with refresh rotation). The app needs consistent envelope parsing, typed errors, transparent token refresh, retries, and redacted logging — in one place, so no feature re-implements HTTP handling.

> ‏الـ backend بيغلّف كل استجابة في الـ ApiResponse envelope (`{success, data, meta}` أو `{success:false, error}`) وبيصادق باستخدام **توكِنات Laravel Sanctum المزدوجة** (توكِن وصول ~60 دقيقة + توكِن تجديد 30 يوم، مع تدوير التوكِن عند التجديد). التطبيق محتاج تحليل موحّد للـ envelope، وأخطاء ذات أنواع محددة، وتجديد شفّاف للتوكِن، وإعادة محاولة، وتسجيل مُنقّح — كل ده في مكان واحد، عشان مفيش feature تعيد بناء التعامل مع الـ HTTP من الأول.

## Decision / القرار

We will route **all** HTTP through a single **envelope-aware `ApiClient`** (`lib/core/network/`) over Dio. It returns `ApiResult<T>` (data + optional `PaginationMeta`) on success and throws typed `ApiException`s on failure (`ValidationException` 422 with `fieldErrors`, `Unauthenticated`, `Forbidden`, `NotFound`, `RateLimit`, `Server`, `Network`). Auth is handled by `AuthInterceptor` (a `QueuedInterceptor`): attach the bearer, on 401 refresh **once** and retry the original request, queuing concurrent 401s behind a single refresh; a failed refresh emits on `AuthEvents.onSessionExpired`. `TokenStorage` (flutter_secure_storage) holds tokens; `SocialTokenExchange` handles Google/Apple. `dio_smart_retry` covers transient retries; `pretty_dio_logger` is configured to redact auth headers/bodies.

> ‏هنمرّر **كل** طلبات الـ HTTP من خلال `ApiClient` واحد **بيفهم الـ envelope** (`lib/core/network/`) فوق Dio. بيرجّع `ApiResult<T>` (البيانات + `PaginationMeta` اختياري) عند النجاح، وبيرمي `ApiException` بأنواع محددة عند الفشل (`ValidationException` 422 مع `fieldErrors`، و`Unauthenticated`، و`Forbidden`، و`NotFound`، و`RateLimit`، و`Server`، و`Network`). المصادقة بيتولاها `AuthInterceptor` (وهو `QueuedInterceptor`): بيرفق الـ bearer، وعند 401 بيجدّد **مرة واحدة** ويعيد الطلب الأصلي، مع اصطفاف طلبات 401 المتزامنة خلف تجديد واحد؛ ولو التجديد فشل بيصدر حدث على `AuthEvents.onSessionExpired`. `TokenStorage` (flutter_secure_storage) بيحتفظ بالتوكِنات؛ و`SocialTokenExchange` بيتولّى Google/Apple. `dio_smart_retry` بيغطي إعادة المحاولة للأخطاء العابرة؛ و`pretty_dio_logger` مضبوط عشان يُنقّي رؤوس وأجسام المصادقة من التسجيل.

Errors surface as typed `ApiException`s at the network boundary. Repositories catch those and rethrow them as a `sealed class Failure` (`NetworkFailure` / `ServerFailure` / `UnknownFailure`); blocs and callers use plain `try`/`catch` — no `Either`, no `.fold()`, no `Result<T>`. This keeps the whole error path beginner-friendly for a team new to Flutter. `ApiClient` is registered by hand in `configureDependencies()` (`lib/core/di/injection.dart`) via `getIt.registerLazySingleton` — no annotations, no code generation.

> ‏الأخطاء بتظهر كـ `ApiException` بأنواع محددة عند حدود الشبكة. الـ repositories بتلتقطها وتعيد رميها كـ `sealed class Failure` (`NetworkFailure` أو `ServerFailure` أو `UnknownFailure`)؛ والـ blocs والمستدعون بيستخدموا `try`/`catch` عادي — من غير `Either`، ولا `.fold()`، ولا `Result<T>`. ده بيخلّي مسار الأخطاء كله سهل على فريق جديد على Flutter. `ApiClient` بيتسجّل يدويًا في `configureDependencies()` (`lib/core/di/injection.dart`) عن طريق `getIt.registerLazySingleton` — من غير annotations ولا توليد كود. مشتقات fpdart والـ codegen مؤجّلة (شوف [../../docs/ROADMAP.md](../../docs/ROADMAP.md)).

## Consequences / التبعات

- **Positive:**
  - Features never touch Dio or parse the envelope — they get `ApiResult<T>` or a typed exception.
  - 401 refresh is transparent and storm-safe (queued).
  - Tokens never hit logs; secrets stay in secure storage.

> ‏الإيجابيات: الـ features مبتلمسش Dio ولا بتحلّل الـ envelope — بتاخد `ApiResult<T>` أو استثناء بنوع محدد. تجديد الـ 401 شفّاف وآمن ضد العواصف (مصطف). التوكِنات عمرها ما بتوصل للتسجيل؛ والأسرار بتفضل في التخزين الآمن.

- **Negative:**
  - `ApiClient` is a critical shared component — changes there are high-blast-radius (well-tested: envelope, refresh, rotation, exchange).

> ‏السلبيات: `ApiClient` مكوّن مشترك حرِج — أي تغيير فيه نطاق تأثيره كبير (لكنه مغطّى باختبارات جيدة: الـ envelope، والتجديد، والتدوير، والتبادل).

- **Alternatives rejected:**
  - **`http` package** — no interceptors; we'd rebuild refresh/retry/logging.
  - **retrofit/chopper codegen** — another generator to run and maintain; the hand-written client is small, already covers the envelope precisely, and fits the no-codegen stance (see [../../docs/ROADMAP.md](../../docs/ROADMAP.md)).
  - **Per-feature Dio instances** — inconsistent auth/error handling.

> ‏البدائل المرفوضة: حزمة `http` — من غير interceptors، وكنا هنعيد بناء التجديد/إعادة المحاولة/التسجيل. توليد retrofit/chopper — مولّد كمان لازم نشغّله ونصونه، والعميل المكتوب باليد صغير وبيغطي الـ envelope بدقة وبيتماشى مع توجّه "من غير codegen" (شوف [../../docs/ROADMAP.md](../../docs/ROADMAP.md)). نُسخ Dio لكل feature — تعامل غير متسق مع المصادقة والأخطاء.

- **Follow-ups:**
  - Bad login returns **422, not 401** — see [../reference/COMMON_PITFALLS.md](../reference/COMMON_PITFALLS.md). Lifecycle diagram in [../guides/02_architecture.md](../guides/02_architecture.md).

> ‏المتابعات: تسجيل الدخول الخاطئ بيرجّع **422 مش 401** — شوف [../reference/COMMON_PITFALLS.md](../reference/COMMON_PITFALLS.md). مخطط دورة الحياة في [../guides/02_architecture.md](../guides/02_architecture.md).
