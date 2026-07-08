# 🔌 How to Wire a New API Endpoint / كيفية توصيل نقطة API جديدة

> [INDEX](../INDEX.md) > How to Wire a New API Endpoint

The backend ([osta_backend](https://github.com/YoussefSalem582/osta_backend/issues), Laravel 12 at `/api/v1`) wraps every response in the **ApiResponse envelope**. The app's `ApiClient` already understands it — you write data sources against `ApiClient`, never against Dio directly.

> ‏الـ backend (لارافيل 12 على `/api/v1`) بيغلّف كل استجابة في **مغلّف ApiResponse**. الـ `ApiClient` في التطبيق فاهم المغلّف ده بالفعل، فإنت بتكتب مصادر البيانات على أساس `ApiClient` مش على Dio مباشرة.

---

## The envelope contract / عقد المغلّف

Success:

```json
{ "success": true, "data": { ... }, "meta": { "pagination": { "current_page": 1, "last_page": 5, "per_page": 15, "total": 68 } } }
```

Failure:

```json
{ "success": false, "error": { "code": "VALIDATION_ERROR", "message": "…", "details": { "phone": ["…"] } } }
```

`ApiClient` returns `ApiResult<T>` (data + optional `PaginationMeta`) on success, or **throws a typed `ApiException`** on failure. There is no `Either`, no `Result<T>` wrapper — success returns a value, failure throws.

> ‏الـ `ApiClient` بيرجّع `ApiResult<T>` (البيانات + `PaginationMeta` اختياري) عند النجاح، أو **بيرمي `ApiException` من نوع محدّد** عند الفشل. مفيش `Either` ولا غلاف `Result<T>` — النجاح بيرجّع قيمة، والفشل بيرمي استثناء.

The typed exceptions below live in `lib/core/network/api_exception.dart`:

> ‏الاستثناءات ذات النوع المحدّد التالية موجودة في `lib/core/network/api_exception.dart`:

| Exception | HTTP / code | What to do |
|---|---|---|
| `ValidationException` | 422 `VALIDATION_ERROR` | read `fieldErrors`, surface inline on the form |
| `UnauthenticatedException` | 401 | usually pre-empted by `AuthInterceptor` refresh |
| `ForbiddenException` | 403 | show "not allowed" |
| `NotFoundException` | 404 | empty/gone state |
| `RateLimitException` | 429 | back off; may carry `Retry-After` |
| `ServerException` | 5xx / malformed | generic error |
| `NetworkException` | transport | offline/retry hint |

> **Gotcha**: a wrong email/password returns **422**, not 401 — don't special-case 401 for login. See [../reference/COMMON_PITFALLS.md](../reference/COMMON_PITFALLS.md).

> ‏**انتبه**: الإيميل أو الباسورد الغلط بيرجّع **422** مش 401 — متعملش معالجة خاصة لـ 401 في تسجيل الدخول. شوف [../reference/COMMON_PITFALLS.md](../reference/COMMON_PITFALLS.md).

---

## Steps / الخطوات

The flow is deliberately plain Dart: no codegen, no annotations, no `build_runner`. You write a data source, a repository, and a hand-written `get_it` registration line. Only l10n is generated in this codebase (`flutter gen-l10n`). Advanced tooling (freezed/json_serializable/injectable) is **deferred** — see the team plan at [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

> ‏المسار عمداً Dart بسيط: مفيش توليد كود، مفيش annotations، مفيش `build_runner`. إنت بتكتب مصدر بيانات، ومستودع (repository)، وسطر تسجيل `get_it` بإيدك. الحاجة الوحيدة اللي بتتولّد في المشروع ده هي الـ l10n (`flutter gen-l10n`). الأدوات المتقدمة (freezed/json_serializable/injectable) **مؤجّلة** — شوف خطة الفريق في [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

### 1. (First API PR) create a path-constants file / (أول PR للـ API) اعمل ملف ثوابت المسارات

There is **no `api_endpoints.dart` yet** — the first feature PR that calls the backend should add `lib/core/network/api_endpoints.dart` with `static const` paths (and parameterised helpers for `{id}` routes), so nobody hardcodes URL strings. Base URL comes from `AppConfig.baseUrl` (`--dart-define BASE_URL`, default `https://osta.technology92.com/api/v1`).

> ‏لسه **مفيش `api_endpoints.dart`** — أول PR لميزة بتنادي الـ backend المفروض يضيف `lib/core/network/api_endpoints.dart` بمسارات `static const` (ودوال مساعِدة للمسارات اللي فيها `{id}`)، عشان محدش يكتب روابط بإيده. الـ base URL بييجي من `AppConfig.baseUrl` (`--dart-define BASE_URL`، الافتراضي `https://osta.technology92.com/api/v1`).

```dart
class ApiEndpoints {
  static const centersNearby = '/centers/nearby';
  static String center(String id) => '/centers/$id';
}
```

### 2. Remote data source / مصدر البيانات البعيد

The data source is a plain class that takes `ApiClient` in its constructor and maps the raw JSON to a model. No annotations.

> ‏مصدر البيانات كلاس عادي بياخد `ApiClient` في الـ constructor بتاعه وبيحوّل الـ JSON الخام لموديل. من غير أي annotations.

```dart
class DiscoveryRemoteDataSource {
  DiscoveryRemoteDataSource(this._client);
  final ApiClient _client;

  Future<List<CenterModel>> nearby({required double lat, required double lng}) async {
    final res = await _client.get<List<dynamic>>(
      ApiEndpoints.centersNearby,
      query: {'latitude': lat, 'longitude': lng},
    );
    return res.data.map((e) => CenterModel.fromJson(e as Map<String, dynamic>)).toList();
    // res.pagination is available when the endpoint is paginated
  }
}
```

Models are plain `class CenterModel extends Equatable` with a hand-written `factory CenterModel.fromJson(...)`, `toJson()`, and `props` — no `@freezed`, no `@JsonSerializable`, no `part '*.g.dart'`. See `lib/features/auth/data/models/auth_token_model.dart` for the pattern.

> ‏الموديلات كلاسات عادية `class CenterModel extends Equatable` مع `factory CenterModel.fromJson(...)` و`toJson()` و`props` مكتوبين بإيدك — مفيش `@freezed` ولا `@JsonSerializable` ولا `part '*.g.dart'`. شوف `lib/features/auth/data/models/auth_token_model.dart` للنمط.

### 3. Repository — catch exceptions, throw a Failure / المستودع — امسك الاستثناءات وارمِ Failure

The repository catches the typed `ApiException` and rethrows it as a `Failure` from `lib/core/error/failure.dart`. `Failure` is a `sealed class` implementing `Exception`; there is no `Either`, no `Result<T>`, and no `.fold()` — the repository returns the value on success and throws on failure.

> ‏المستودع بيمسك الـ `ApiException` ذو النوع المحدّد ويرميه من جديد كـ `Failure` من `lib/core/error/failure.dart`. الـ `Failure` عبارة عن `sealed class` بتطبّق `Exception`؛ مفيش `Either`، ولا `Result<T>`، ولا `.fold()` — المستودع بيرجّع القيمة عند النجاح ويرمي استثناء عند الفشل.

```dart
class DiscoveryRepository {
  DiscoveryRepository(this._ds);
  final DiscoveryRemoteDataSource _ds;

  Future<List<Center>> nearby(LatLng at) async {
    try {
      final models = await _ds.nearby(lat: at.lat, lng: at.lng);
      return models.map((m) => m.toEntity()).toList();
    } on ApiException catch (e) {
      throw e.toFailure(); // NetworkException → NetworkFailure, etc.
    }
  }
}
```

The `Failure` hierarchy the repository throws:

> ‏تسلسل `Failure` اللي المستودع بيرميه:

```dart
// lib/core/error/failure.dart
sealed class Failure implements Exception {
  const Failure(this.message);
  final String message;
}
class NetworkFailure extends Failure { const NetworkFailure([super.message = 'Network error']); }
class ServerFailure  extends Failure { const ServerFailure([super.message = 'Server error']); }
class UnknownFailure extends Failure { const UnknownFailure([super.message = 'Unexpected error']); }
```

### 4. BLoC — plain try/catch / الـ BLoC — try/catch عادي

The BLoC calls the repository inside a `try`/`catch (Failure)`, emitting a success or error state. No `Result` to fold, no functional plumbing — just a `try`/`catch` a Flutter-new developer can read at a glance (see [03_how_to_add_new_feature.md](03_how_to_add_new_feature.md)).

> ‏الـ BLoC بينادي المستودع جوه `try`/`catch (Failure)`، ويطلّع حالة نجاح أو خطأ. مفيش `Result` نعمله fold، ولا سباكة برمجية وظيفية — مجرد `try`/`catch` يقدر مطوّر جديد على Flutter يقراه بنظرة (شوف [03_how_to_add_new_feature.md](03_how_to_add_new_feature.md)).

```dart
try {
  final centers = await _repo.nearby(at);
  emit(DiscoveryLoaded(centers));
} on Failure catch (e) {
  emit(DiscoveryError(e.message));
}
```

### 5. Register in get_it — by hand / سجّل في get_it — بإيدك

Registration is **manual**: add one line to `configureDependencies()` in `lib/core/di/injection.dart`. There is no `injectable`, no `injection.config.dart`, and no `build_runner` — you wire the new services yourself with `registerLazySingleton`.

> ‏التسجيل **يدوي**: ضيف سطر واحد لـ `configureDependencies()` في `lib/core/di/injection.dart`. مفيش `injectable`، ولا `injection.config.dart`، ولا `build_runner` — إنت بتوصّل الخدمات الجديدة بنفسك بـ `registerLazySingleton`.

```dart
// lib/core/di/injection.dart
getIt
  ..registerLazySingleton<DiscoveryRemoteDataSource>(() => DiscoveryRemoteDataSource(getIt()))
  ..registerLazySingleton<DiscoveryRepository>(() => DiscoveryRepository(getIt()));
```

No codegen step follows. If you touched ARB files, run `flutter gen-l10n`; otherwise just `flutter analyze` and `flutter test`.

> ‏مفيش خطوة توليد كود بعد كده. لو لمست ملفات الـ ARB، شغّل `flutter gen-l10n`؛ غير كده يبقى بس `flutter analyze` و`flutter test`.

---

## Auth, language, pagination / المصادقة واللغة والترقيم

- **Auth** is automatic: `AuthInterceptor` attaches the bearer and does the 401 refresh-retry-once. For unauthenticated calls (login, legal docs) pass the client's no-auth flag.
- **Accept-Language**: the backend localizes `message`/validation by `Accept-Language` (ar default). A request interceptor injecting the active locale is specified by [app #30](https://github.com/YoussefSalem582/Osta-App/issues/30) — add it there, not per-call.
- **Pagination**: `ApiResult.pagination` (`PaginationMeta`: `currentPage`, `lastPage`, `perPage`, `total`) drives infinite lists.

> ‏**المصادقة** تلقائية: الـ `AuthInterceptor` بيرفق الـ bearer ويعمل تحديث-وإعادة-محاولة-مرة-واحدة عند 401. للنداءات غير المصادَق عليها (تسجيل الدخول، المستندات القانونية) مرّر علامة الـ no-auth بتاعة الـ client.

> ‏**Accept-Language**: الـ backend بيترجم الـ `message`/التحقق حسب `Accept-Language` (العربية افتراضياً). فيه request interceptor بيحقن اللغة النشطة محدَّد في [app #30](https://github.com/YoussefSalem582/Osta-App/issues/30) — ضيفه هناك، مش في كل نداء.

> ‏**الترقيم (Pagination)**: الـ `ApiResult.pagination` (`PaginationMeta`: `currentPage`، `lastPage`، `perPage`، `total`) بيشغّل القوائم اللانهائية.

---

## Worked example endpoints / أمثلة على نقاط النهاية

The full catalogue (grouped by domain, with per-endpoint app status) is in [09_api_endpoints.md](09_api_endpoints.md). Today only `POST /auth/login`, `/auth/refresh`, and `/auth/social/{provider}` are wired (via `core/network`); everything else is Planned until its feature epic lands.

> ‏الكتالوج الكامل (مُجمّع حسب النطاق، مع حالة كل نقطة في التطبيق) موجود في [09_api_endpoints.md](09_api_endpoints.md). النهاردة `POST /auth/login` و`/auth/refresh` و`/auth/social/{provider}` بس هي المتوصّلة (عن طريق `core/network`)؛ وكل حاجة تانية مخطّطة لحد ما الـ epic بتاعها ينزل.

---

## Related / روابط ذات صلة

- [09_api_endpoints.md](09_api_endpoints.md) · [02_architecture.md](02_architecture.md) § HTTP lifecycle · [08_security_and_environment.md](08_security_and_environment.md) · [ADR 006](../decisions/006-dio-envelope-client-sanctum.md)
