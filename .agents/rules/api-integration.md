---
description: "ApiClient envelope, ApiResult/ApiException, error flow"
globs: "lib/**/*.dart"
alwaysApply: false
---

# API Integration

Every HTTP call in osta goes through **`ApiClient`** (`lib/core/network/api_client.dart`). It parses the backend envelope into a typed `ApiResult<T>` or throws a typed `ApiException`. Features never touch Dio or raw JSON directly.

> Stack is plain Dart — no codegen. Models are hand-written `Equatable`, DI is manual `get_it`, errors are a sealed `Failure` thrown/caught with `try`/`catch`. See `../../docs/ROADMAP.md` for deferred tooling.

## Adding an endpoint — the steps

1. **Path constant** — add to `lib/core/network/api_endpoints.dart`. *This file does not exist yet;* the first API PR creates it (e.g. `class ApiEndpoints { static const login = '/auth/login'; }`). Until then, follow the endpoint catalogue in `../../osta_readme_files/guides/09_api_endpoints.md`.
2. **Call via `ApiClient`** — `getIt<ApiClient>().post(ApiEndpoints.x, parse: ..., body: ...)`. Never `Dio` directly.
3. **Parse** — pass a `parse: (data) => ...` closure that turns `body['data']` into your type.
4. **Model** — plain `class X extends Equatable` with hand-written `factory X.fromJson` / `toJson` / `props`. No `@freezed`, no `*.g.dart`.
5. **Repo contract** — abstract method in `.../domain/repositories/`, returning the domain type (throws on failure, never returns an error type).
6. **Repo impl** — in `.../data/repositories/`; wrap the `ApiClient` call in `try`/`catch (ApiException)` and rethrow a `Failure` (see error flow below).
7. **Use case** — thin `call(...)` in `.../domain/usecases/` delegating to the repo.
8. **Bloc** — inject the use case; `try`/`catch (Failure)` → emit an error state.
9. **Register by hand** — add `getIt.registerLazySingleton`/`registerFactory` lines in `lib/core/di/injection.dart` (`configureDependencies()`). No `injectable`, no `build_runner`.

## `ApiClient` methods

All return `Future<ApiResult<T>>` and take `required T Function(Object? data) parse` + `bool authenticated = true`.

| Method | Extra args | Use for |
|---|---|---|
| `get<T>(path, {query})` | `Map? query` | reads / lists |
| `post<T>(path, {body})` | `Object? body` | create / actions |
| `put<T>(path, {body})` | `Object? body` | full update |
| `delete<T>(path, {body})` | `Object? body` | delete |

- `authenticated: false` → skips the `Authorization` header (login, social exchange), via `AuthInterceptor.noAuthKey`.
- `ApiResult<T>` = `data` (`T`) + optional `meta` (`PaginationMeta`, present on paginated lists).

## Backend envelope

```jsonc
// success
{ "success": true,  "data": <payload>, "meta": { /* pagination, optional */ } }
// failure
{ "success": false, "error": { "code": "…", "message": "…", "details": { /* field errors */ } } }
```

`ApiClient` throws when `body` isn't a map, `success != true`, or Dio errors.

### Error codes → `ApiException`

| `error.code` | HTTP | Exception | Notes |
|---|---|---|---|
| `VALIDATION_ERROR` | 422 | `ValidationException` | carries `fieldErrors: Map<String, List<String>>` from `error.details` |
| `UNAUTHENTICATED` | 401 | `UnauthenticatedException` | triggers interceptor refresh-retry |
| `FORBIDDEN` | 403 | `ForbiddenException` | |
| `NOT_FOUND` | 404 | `NotFoundException` | |
| `TOO_MANY_REQUESTS` | 429 | `RateLimitException` | |
| `SERVER_ERROR` / unknown | 5xx | `ServerException` | fallback for any unrecognised code |
| — (transport) | — | `NetworkException` | timeout / DNS / connection refused, never reached server |

- **Bad login is `422` (`ValidationException`), not `401`.** A 401 means an expired/invalid *session* token.

## Error flow

```text
ApiClient  ── throws ApiException (typed)
   ↓
Repo impl  ── catch (ApiException) → throw Failure  (NetworkFailure / ServerFailure / UnknownFailure)
   ↓
Bloc       ── catch (Failure) → emit Error state
```

`Failure` is a sealed class in `lib/core/error/failure.dart`. **No `Either`, no `Result<T>`, no `.fold()`** — throw and `try`/`catch` end to end.

## Interceptors (`buildAppDio`, `lib/core/network/dio_client.dart`)

Order matters — added in this sequence:

1. **`AuthInterceptor`** (`QueuedInterceptor`) — attaches `Bearer <access>` from `TokenStorage`; on `401`, calls `/auth/refresh` **once**, rotates tokens, replays the original request one time. Second 401 / failed refresh → `TokenStorage.clear()` + `AuthEvents.onSessionExpired`. `QueuedInterceptor` serializes so concurrent 401s share one refresh.
2. **`RetryInterceptor`** (`dio_smart_retry`) — automatic retries on transient transport failures.
3. **`PrettyDioLogger`** — redacted (`responseBody: false`; Authorization headers and bodies never logged).

- `Accept-Language` header is **planned** (app #30), not wired yet.

## Not in osta

- **No offline queue, no cache policy, no connectivity tiers, no optimistic sync.** Requests hit the network directly through `ApiClient`. Do not introduce `CachePolicy`, `OfflineQueue`, or `ConnectivityCubit`.
