---
name: add-api
description: Wire a backend endpoint end-to-end through the ApiClient envelope, ApiException->Failure mapping. Use when connecting a new API route.
---

# Add an API Endpoint

Wire one backend route end-to-end in plain Dart: path constant -> `ApiClient` call -> hand-written model -> repository (maps `ApiException` to a `Failure`) -> use case -> bloc -> manual `get_it` registration. No codegen, no `Either`, no offline queue. Full guide: [../../../osta_readme_files/guides/04_how_to_add_new_api.md](../../../osta_readme_files/guides/04_how_to_add_new_api.md).

## When to Use

- Connecting a new backend route (Laravel 12 at `/api/v1`) to a feature.
- Adding a method to an existing data source / repository for another endpoint.
- Anytime you would otherwise reach for Dio directly — don't; go through `ApiClient`.

Do NOT use for: pure UI/state work with no network (that is add-feature), or l10n-only changes.

## The envelope contract

Every response is wrapped. `ApiClient` (lib/core/network/api_client.dart) already parses it — you never touch raw Dio or the envelope keys.

Success -> `ApiResult<T>` (`.data` + optional `.meta` as `PaginationMeta`):

```json
{ "success": true, "data": { ... }, "meta": { "pagination": { "current_page": 1, "last_page": 5, "per_page": 15, "total": 68 } } }
```

Failure -> a typed `ApiException` is **thrown** (never returned):

```json
{ "success": false, "error": { "code": "VALIDATION_ERROR", "message": "…", "details": { "phone": ["…"] } } }
```

`error.code` -> exception (all in lib/core/network/api_exception.dart, mapped by `apiExceptionFromEnvelope`):

| Exception | HTTP / code | Handle by |
|---|---|---|
| `ValidationException` | 422 `VALIDATION_ERROR` | read `.fieldErrors` (field -> messages), surface inline on the form |
| `UnauthenticatedException` | 401 `UNAUTHENTICATED` | usually pre-empted by `AuthInterceptor` refresh-retry-once |
| `ForbiddenException` | 403 `FORBIDDEN` | show "not allowed" |
| `NotFoundException` | 404 `NOT_FOUND` | empty / gone state |
| `RateLimitException` | 429 `TOO_MANY_REQUESTS` | back off |
| `ServerException` | 5xx `SERVER_ERROR` / malformed / unknown code | generic error |
| `NetworkException` | transport (timeout, DNS, refused) | offline / retry hint |

**Login gotcha:** a wrong email/password comes back as **422 `ValidationException`**, not 401 — do NOT special-case 401 for login. See [../../../osta_readme_files/reference/COMMON_PITFALLS.md](../../../osta_readme_files/reference/COMMON_PITFALLS.md).

**Accept-Language:** the backend localizes `message`/validation by `Accept-Language` (Arabic default). A request interceptor injecting the active locale is **planned** ([app #30](https://github.com/YoussefSalem582/Osta-App/issues/30)) — add it there, not per-call.

## Instructions

1. **Path constant.** On the first API PR, create `lib/core/network/api_endpoints.dart` (it does not exist yet). Use `static const` for fixed paths and a small helper method for `{id}` routes. Base URL comes from `AppConfig.baseUrl`; put only the path here.
   ```dart
   class ApiEndpoints {
     static const centersNearby = '/centers/nearby';
     static String center(String id) => '/centers/$id';
   }
   ```

2. **Model (hand-written).** Plain `class X extends Equatable` with `factory X.fromJson(Map<String, dynamic>)`, `toJson()`, and `props`. No `@freezed`, no `@JsonSerializable`, no `part '*.g.dart'`. Backend keys are snake_case — map them explicitly. Pattern: lib/features/auth/data/models/auth_token_model.dart.
   ```dart
   class CenterModel extends Equatable {
     const CenterModel({required this.id, required this.name});
     factory CenterModel.fromJson(Map<String, dynamic> json) => CenterModel(
       id: json['id'] as String,
       name: json['name'] as String,
     );
     final String id;
     final String name;
     Map<String, dynamic> toJson() => {'id': id, 'name': name};
     @override
     List<Object?> get props => [id, name];
   }
   ```

3. **Data source — call `ApiClient` with a `parse:` callback.** The real signature is `get/post/put/delete<T>(String path, {required T Function(Object? data) parse, Map<String,dynamic>? query, Object? body, bool authenticated = true})`. `parse` turns `data` into your typed value; the method returns `ApiResult<T>` (read `.data`, and `.meta` for pagination). Pass `authenticated: false` for login / public routes.
   ```dart
   class DiscoveryRemoteDataSource {
     DiscoveryRemoteDataSource(this._client);
     final ApiClient _client;

     Future<List<CenterModel>> nearby({required double lat, required double lng}) async {
       final res = await _client.get<List<CenterModel>>(
         ApiEndpoints.centersNearby,
         query: {'latitude': lat, 'longitude': lng},
         parse: (data) => (data as List)
             .map((e) => CenterModel.fromJson(e as Map<String, dynamic>))
             .toList(),
       );
       return res.data; // res.meta is a PaginationMeta? when the route is paginated
     }
   }
   ```

4. **Repository — catch `ApiException`, throw a `Failure`.** `ApiClient` throws typed `ApiException`s; the domain layer speaks `Failure` (lib/core/error/failure.dart: `NetworkFailure` / `ServerFailure` / `UnknownFailure`, all `sealed`). Map each subtype by hand and throw — there is no `.toFailure()` helper, no `Either`, no `Result<T>`, no `.fold()`. Success returns the value.
   ```dart
   class DiscoveryRepository {
     DiscoveryRepository(this._ds);
     final DiscoveryRemoteDataSource _ds;

     Future<List<CenterModel>> nearby({required double lat, required double lng}) async {
       try {
         return await _ds.nearby(lat: lat, lng: lng);
       } on NetworkException {
         throw const NetworkFailure();
       } on ServerException catch (e) {
         throw ServerFailure(e.message);
       } on ApiException catch (e) {
         // ValidationException/Forbidden/NotFound/RateLimit/Unauthenticated
         throw UnknownFailure(e.message);
       }
     }
   }
   ```
   For a form endpoint, let `ValidationException` reach the bloc instead (rethrow it) so it can read `.fieldErrors` — map only the rest to `Failure`.

5. **Use case.** A thin callable that holds the repo and exposes one method. No logic beyond delegating (add validation/composition here if the endpoint needs it).
   ```dart
   class GetNearbyCenters {
     GetNearbyCenters(this._repo);
     final DiscoveryRepository _repo;
     Future<List<CenterModel>> call({required double lat, required double lng}) =>
         _repo.nearby(lat: lat, lng: lng);
   }
   ```

6. **Bloc — plain `try`/`catch (Failure)`.** Call the use case inside a `try`, emit success or error. Catch `Failure` (and `ValidationException` first if this is a form, to surface `.fieldErrors`).
   ```dart
   try {
     final centers = await _getNearbyCenters(lat: lat, lng: lng);
     emit(DiscoveryLoaded(centers));
   } on Failure catch (e) {
     emit(DiscoveryError(e.message));
   }
   ```

7. **Register in get_it — by hand.** Add one `registerLazySingleton` line per collaborator in `configureDependencies()` (lib/core/di/injection.dart). Blocs use `registerFactory`. No `injectable`, no `injection.config.dart`, no `build_runner`.
   ```dart
   getIt
     ..registerLazySingleton<DiscoveryRemoteDataSource>(() => DiscoveryRemoteDataSource(getIt()))
     ..registerLazySingleton<DiscoveryRepository>(() => DiscoveryRepository(getIt()))
     ..registerLazySingleton<GetNearbyCenters>(() => GetNearbyCenters(getIt()))
     ..registerFactory<DiscoveryBloc>(() => DiscoveryBloc(getIt()));
   ```

8. **Verify.** No codegen step. If you touched ARB files run `flutter gen-l10n`; then `dart format .`, `flutter analyze`, `flutter test`. Add a data-source or repository test that maps a mocked envelope (see test/core/network/api_client_test.dart and test/core/network/fakes.dart for the `http_mock_adapter` pattern).

## Post-Completion Checklist

- [ ] Path lives in `lib/core/network/api_endpoints.dart` (`static const` / `{id}` helper) — no hardcoded URL strings.
- [ ] Model is plain `Equatable` + hand `fromJson`/`toJson`/`props`; snake_case keys mapped. No freezed/json_serializable/`*.g.dart`.
- [ ] Call goes through `ApiClient.get/post/put/delete<T>` with a `parse:` callback; `authenticated: false` only for public routes. No direct Dio.
- [ ] Repository catches `ApiException` and throws a `Failure` (mapped by subtype); form routes let `ValidationException` through for `.fieldErrors`. No `Either`/`Result`/`.fold()`.
- [ ] Bloc uses `try`/`catch (Failure)`; login does NOT treat 401 specially (bad login is 422).
- [ ] Every new class registered by hand in `configureDependencies()` (blocs via `registerFactory`).
- [ ] `dart format .`, `flutter analyze`, `flutter test` pass; a test maps a mocked envelope for the new route.
- [ ] `flutter gen-l10n` run only if ARB files changed.
- [ ] Updated `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, `osta_readme_files/CURRENT_STATUS.md`.
