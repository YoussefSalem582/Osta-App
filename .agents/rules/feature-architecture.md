---
description: "Clean Architecture layers + dependency rule for feature modules"
globs: "lib/features/**/*.dart"
alwaysApply: false
---

# Feature Architecture

Every feature under `lib/features/**` is a three-layer Clean Architecture module in **plain, readable Dart** — no codegen (freezed/injectable/json_serializable/build_runner are deferred, see [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)). Folders already exist as stubs; you fill them. Reference guide: [`../../osta_readme_files/guides/03_how_to_add_new_feature.md`](../../osta_readme_files/guides/03_how_to_add_new_feature.md).

## Folder tree

```text
lib/features/<feature>/
├── data/
│   ├── datasources/    # *RemoteDataSource — calls ApiClient
│   ├── models/         # *Model extends Equatable + hand fromJson/toJson/toEntity
│   └── repositories/   # *RepositoryImpl — try/catch, ApiException → Failure
├── domain/
│   ├── entities/       # *Entity extends Equatable (pure Dart)
│   ├── repositories/   # abstract *Repository contract
│   └── usecases/       # one class per action
└── presentation/
    ├── bloc/           # *Bloc / *Event / *State
    ├── pages/          # route widgets (static const path)
    └── widgets/
```

Nested subdomains follow the same shape (e.g. `customer/garage/{data,domain,presentation}`).

## Dependency rule

| Layer | May import | Must NOT import |
|-------|------------|-----------------|
| `domain/` | Dart, `equatable` | Flutter, `dio`, models, datasources, `Either`/`Result` |
| `data/` | `domain/`, `core/network`, `core/error` | `presentation/` |
| `presentation/` | `domain/` (use cases, entities), `bloc` | `data/` directly |

Direction: `data/` → `domain/` ← `presentation/`. Domain is the pure center — it knows nothing about the outer layers.

## Domain rules

- Entities are `class X extends Equatable` with `props`. **No `fromJson`** — entities are transport-agnostic.
- Repository contracts are `abstract class` interfaces. Methods **return the entity directly and `throw` a `Failure`** on error — never `Either`, `Result<T>`, or `.fold()`.
- Use cases are one thin class per action, holding the repo and exposing `call()`.

```dart
abstract class GarageRepository {
  Future<List<Vehicle>> getVehicles(); // returns directly; throws Failure
}

class GetVehicles {
  GetVehicles(this._repo);
  final GarageRepository _repo;
  Future<List<Vehicle>> call() => _repo.getVehicles();
}
```

## Data rules

- Models are `class XModel extends Equatable` with **hand-written** `fromJson`/`toJson`/`props` + a `toEntity()`. No `@freezed`, `@JsonSerializable`, or `part '*.g.dart'`. snake_case → camelCase by reading the key by name. Live example: `lib/features/auth/data/models/auth_token_model.dart`.
- Datasources call `ApiClient` (`get/post/put/delete<T>`) and parse with `XModel.fromJson` — never call `Dio` directly.
- Repo impls wrap the call in `try`/`catch`, map the typed `ApiException` to a `Failure`, and **`throw`** it (no return-of-error).

```dart
class GarageRepositoryImpl implements GarageRepository {
  GarageRepositoryImpl(this._ds);
  final GarageRemoteDataSource _ds;

  @override
  Future<List<Vehicle>> getVehicles() async {
    try {
      final res = await _ds.getVehicles();
      return res.map((m) => m.toEntity()).toList();
    } on ApiException catch (e) {
      throw e.toFailure(); // ValidationException → …, NetworkException → NetworkFailure, ServerException → ServerFailure
    }
  }
}
```

Failures are the sealed hierarchy in `lib/core/error/failure.dart`: `NetworkFailure` / `ServerFailure` / `UnknownFailure`.

## Presentation rules

- The BLoC receives events, calls the use case inside `try`/`catch`, and emits states — no `.fold()`.
- Catch `Failure` (thrown up from the repo) and emit an error state.
- Pages/widgets reuse `lib/shared/ui/` (`AppButton`, `AppCard`, `AppTextField`, `EmptyState`/`ErrorState`/`LoadingState`, …) and design tokens (`AppSpacing`/`AppRadii`/`context.appColors`) — never raw values. Route paths are `static const path` on the page widget.

```dart
Future<void> _onLoad(GarageLoadRequested e, Emitter<GarageState> emit) async {
  emit(const GarageLoading());
  try {
    emit(GarageLoaded(await _getVehicles()));
  } on Failure catch (f) {
    emit(GarageError(f));
  }
}
```

## DI

Register by hand in `configureDependencies()` inside `lib/core/di/injection.dart` (global `getIt`) — no annotations, no generated `injection.config.dart`.

| Type | Registration |
|------|--------------|
| DataSource, RepositoryImpl, UseCase | `registerLazySingleton` |
| BLoC | `registerFactory` |

```dart
getIt
  ..registerLazySingleton<GarageRemoteDataSource>(() => GarageRemoteDataSource(getIt()))
  ..registerLazySingleton<GarageRepository>(() => GarageRepositoryImpl(getIt()))
  ..registerFactory<GarageBloc>(() => GarageBloc(GetVehicles(getIt())));
```
