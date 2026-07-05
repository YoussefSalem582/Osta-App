# 🧩 How to Add a New Feature / كيفية إضافة ميزة جديدة

> [INDEX](../INDEX.md) > How to Add a New Feature

Every feature is a three-layer Clean Architecture module written in **plain, readable Dart** — no code generation. The folders already exist as stubs (`lib/features/customer/*`, `lib/features/business/*`, `shop`, `notifications`, `auth`) — you fill them in. This guide is the contract until the [auth epic (#35)](https://github.com/YoussefSalem582/Osta-App/issues/35) lands the canonical reference implementation.

> ‏كل ميزة عبارة عن وحدة من ثلاث طبقات على نمط Clean Architecture مكتوبة بلغة Dart بسيطة وواضحة — من غير أي توليد كود. المجلدات موجودة بالفعل كـ stubs، وأنت اللي تملأها. الدليل ده هو المرجع المُلزِم لحد ما الـ auth epic (#35) ينزّل التطبيق المرجعي الكامل.

Advanced tooling (freezed, injectable, fpdart, build flavors) was **deferred, not rejected** — the phased reintroduction plan lives in [docs/ROADMAP.md](../../docs/ROADMAP.md). Until then, everything below is hand-written.

> ‏الأدوات المتقدمة (freezed و injectable و fpdart وتعدُّد الـ flavors) تم **تأجيلها، مش رفضها** — وخطة إعادة إدخالها على مراحل موجودة في docs/ROADMAP.md. لحد كده، كل اللي تحت مكتوب باليد.

---

## 0. Before you write code / قبل ما تكتب كود

1. **Read the epic.** Find the matching GitHub issue and its feature doc in [../features/](../features/README.md). Don't invent scope — the epic defines screens, endpoints, and test expectations.
2. **Check the endpoint is ready.** [09_api_endpoints.md](09_api_endpoints.md) + [11_backend_feature_connectivity.md](11_backend_feature_connectivity.md) tell you if the backend route exists (most do) or is blocked.
3. **Branch:** `feat/<issue>-<slug>` off `main`.

> ‏قبل ما تبدأ: اقرأ الـ epic ولاقي issue بتاعتها ومستند الميزة في ../features/ — ما تخترعش نطاق، الـ epic هي اللي بتحدد الشاشات والـ endpoints وتوقعات الاختبار. اتأكد إن الـ endpoint جاهز من 09_api_endpoints.md و 11_backend_feature_connectivity.md. بعدين اعمل فرع `feat/<issue>-<slug>` من `main`.

---

## 1. Domain layer (`domain/`) / طبقة الـ domain

Pure Dart, no Flutter imports. Entities are plain `Equatable` classes. Repositories are abstract interfaces whose methods **return the value directly and throw a `Failure` on error** — no `Either`, no `Result<T>`.

> ‏Dart خالص من غير أي استيراد لـ Flutter. الـ entities عبارة عن كلاسات `Equatable` عادية. الـ repositories واجهات abstract، وميثوداتها **بترجّع القيمة مباشرة وبترمي `Failure` عند الخطأ** — من غير `Either` ولا `Result<T>`.

```dart
// domain/entities/vehicle.dart
class Vehicle extends Equatable {
  const Vehicle({required this.id, required this.brand, required this.isPrimary});
  final String id;
  final String brand;
  final bool isPrimary;
  @override
  List<Object?> get props => [id, brand, isPrimary];
}

// domain/repositories/garage_repository.dart
abstract class GarageRepository {
  Future<List<Vehicle>> getVehicles();          // returns directly; throws Failure on error
  Future<Vehicle> addVehicle(NewVehicle input);
}

// domain/usecases/get_vehicles.dart
class GetVehicles {
  GetVehicles(this._repo);
  final GarageRepository _repo;
  Future<List<Vehicle>> call() => _repo.getVehicles();
}
```

Errors are a sealed hierarchy — see [ADR 004](../decisions/004-fpdart-either-error-handling.md). Callers use plain `try`/`catch`.

> ‏الأخطاء عبارة عن تسلسل `sealed` — راجع ADR 004. اللي بينادي بيستخدم `try`/`catch` عادي.

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

---

## 2. Data layer (`data/`) / طبقة الـ data

Models are plain `Equatable` classes with **hand-written** `fromJson`/`toJson` — no `@freezed`, no `@JsonSerializable`, no `part '*.g.dart'`. snake_case JSON maps to camelCase Dart by reading the key by name in `fromJson`. See `lib/features/auth/data/models/auth_token_model.dart` for the live example.

> ‏الـ models كلاسات `Equatable` عادية بـ `fromJson`/`toJson` **مكتوبين باليد** — من غير `@freezed` ولا `@JsonSerializable` ولا `part '*.g.dart'`. تحويل مفاتيح الـ JSON من snake_case لـ camelCase بيتم يدويًا بقراءة المفتاح بالاسم داخل `fromJson`. راجع `auth_token_model.dart` كمثال حي.

```dart
// data/models/vehicle_model.dart
class VehicleModel extends Equatable {
  const VehicleModel({required this.id, required this.brand, required this.isPrimary});

  factory VehicleModel.fromJson(Map<String, dynamic> json) => VehicleModel(
        id: json['id'] as String,
        brand: json['brand'] as String,
        isPrimary: json['is_primary'] as bool,   // snake_case → camelCase, by hand
      );

  final String id;
  final String brand;
  final bool isPrimary;

  Map<String, dynamic> toJson() => {'id': id, 'brand': brand, 'is_primary': isPrimary};

  Vehicle toEntity() => Vehicle(id: id, brand: brand, isPrimary: isPrimary);

  @override
  List<Object?> get props => [id, brand, isPrimary];
}
```

There is **no `build_runner` step** — the only generated code in the repo is l10n. See [ADR 005](../decisions/005-codegen-stack-injectable-freezed.md).

> ‏مفيش خطوة `build_runner` — الكود المُولَّد الوحيد في المشروع هو الـ l10n. راجع ADR 005.

The **remote data source** calls `ApiClient` (`get/post/put/delete<T>`) and parses with `VehicleModel.fromJson`. The **repository impl** catches the typed `ApiException` thrown by the network layer and rethrows it as a `Failure`:

> ‏الـ remote data source بينادي `ApiClient` (`get/post/put/delete<T>`) ويحلّل بـ `VehicleModel.fromJson`. الـ repository impl بيمسك الـ `ApiException` المُصنَّف اللي بترميه طبقة الشبكة، ويرميه من جديد كـ `Failure`.

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
      // ValidationException → …, NetworkException → NetworkFailure, ServerException → ServerFailure
      throw e.toFailure();
    }
  }
}
```

---

## 3. Presentation layer (`presentation/`) / طبقة العرض

The BLoC calls the use case inside `try`/`catch` and emits the matching state — no `.fold()`.

> ‏الـ BLoC بينادي الـ use case جوه `try`/`catch` ويصدر الـ state المناسب — من غير `.fold()`.

```dart
class GarageBloc extends Bloc<GarageEvent, GarageState> {
  GarageBloc(this._getVehicles) : super(const GarageInitial()) {
    on<GarageLoadRequested>(_onLoad);
  }
  final GetVehicles _getVehicles;

  Future<void> _onLoad(GarageLoadRequested e, Emitter<GarageState> emit) async {
    emit(const GarageLoading());
    try {
      final vehicles = await _getVehicles();
      emit(GarageLoaded(vehicles));
    } on Failure catch (f) {
      emit(GarageError(f));
    }
  }
}
```

Pages/widgets reuse `lib/shared/ui/` components (`AppButton`, `AppCard`, `AppTextField`, `EmptyState`/`ErrorState`/`LoadingState`, …) and design tokens — never raw colors/spacing (see [06_how_to_change_theme_colors.md](06_how_to_change_theme_colors.md)).

> ‏الصفحات والويدجت بتعيد استخدام مكوّنات `lib/shared/ui/` (`AppButton` و`AppCard` و`AppTextField` و`EmptyState`/`ErrorState`/`LoadingState` …) وتوكِنات التصميم — ما تستخدمش ألوان أو مسافات خام أبدًا.

---

## 4. DI / حقن الاعتماديات

Registration is **manual** — add a hand-written line in `configureDependencies()` inside `lib/core/di/injection.dart`. No annotations, no generated `injection.config.dart`. See [ADR 005](../decisions/005-codegen-stack-injectable-freezed.md).

> ‏التسجيل **يدوي** — ضيف سطرًا مكتوبًا باليد في `configureDependencies()` جوه `lib/core/di/injection.dart`. مفيش annotations ولا ملف `injection.config.dart` مُولَّد. راجع ADR 005.

```dart
// lib/core/di/injection.dart
getIt
  ..registerLazySingleton<GarageRemoteDataSource>(() => GarageRemoteDataSource(getIt()))
  ..registerLazySingleton<GarageRepository>(() => GarageRepositoryImpl(getIt()))
  ..registerFactory<GarageBloc>(() => GarageBloc(GetVehicles(getIt())));
```

---

## 5. Routing / التوجيه

Add the route in `lib/core/router/app_router.dart` (paths are `static const path` on the page widget). Once role shells land ([app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)), place customer routes under the ConsumerShell branch and business routes under the ProviderShell branch.

> ‏ضيف المسار في `lib/core/router/app_router.dart` (المسارات معرَّفة كـ `static const path` على الـ page widget). بعد ما الـ role shells تنزل (#34)، حُطّ مسارات العميل تحت فرع ConsumerShell ومسارات النشاط التجاري تحت فرع ProviderShell.

---

## 6. Localization / التعريب

Add every user-facing string to **both** `lib/l10n/app_en.arb` (template) and `lib/l10n/app_ar.arb`, then run `flutter gen-l10n`. Access via `context.l10n.key`. Arabic is default; keep layouts RTL-safe. See [05_how_to_add_new_language.md](05_how_to_add_new_language.md).

> ‏ضيف كل نص بيظهر للمستخدم في **الاتنين** `lib/l10n/app_en.arb` (القالب) و`lib/l10n/app_ar.arb`، وبعدين شغّل `flutter gen-l10n`. الوصول عن طريق `context.l10n.key`. العربية هي الافتراضي؛ خلّي التخطيطات آمنة للاتجاه من اليمين للشمال.

---

## 7. Tests / الاختبارات

- **Unit**: repository (envelope mapping, `ApiException` → `Failure`) and BLoC (state sequence) using `http_mock_adapter` or hand fakes (`test/core/network/fakes.dart`). No mockito/mocktail.
- **Widget/golden**: per the epic — commonly golden light/dark × RTL/LTR, and widget tests for gates (add-car gate, onboarding flag, payment WebView). See [10_testing.md](10_testing.md).

> ‏اختبارات الوحدة: للـ repository (تحويل الـ envelope، و`ApiException` → `Failure`) وللـ BLoC (تسلسل الحالات) باستخدام `http_mock_adapter` أو fakes مكتوبة باليد. مفيش mockito/mocktail. اختبارات الـ widget/golden: حسب الـ epic — عادةً golden فاتح/غامق × RTL/LTR، واختبارات للبوابات.

---

## 8. Ship / التسليم

Run `flutter analyze` (clean), `flutter test` (green), and `dart format .`. There is **no `build_runner` step**; only `flutter gen-l10n` generates code (and it runs automatically on `flutter run`/`build`). Then update docs ([../../CHANGELOG.md](../../CHANGELOG.md), [../DOCUMENTATION_UPDATE_SUMMARY.md](../DOCUMENTATION_UPDATE_SUMMARY.md), [../CURRENT_STATUS.md](../CURRENT_STATUS.md), the feature doc). PR base `main`, description in **Arabic + English**.

> ‏شغّل `flutter analyze` (نضيف) و`flutter test` (أخضر) و`dart format .`. مفيش خطوة `build_runner`؛ الـ `flutter gen-l10n` بس هو اللي بيولّد كود (وبيشتغل تلقائيًا مع `flutter run`/`build`). بعدين حدّث المستندات، واعمل PR على `main` بوصف بالعربي والإنجليزي.

To run the app locally, pass a single `BASE_URL` dart-define (no `--flavor`, no `FLAVOR`):

> ‏عشان تشغّل التطبيق محليًا، مرّر `BASE_URL` واحد كـ dart-define (من غير `--flavor` ولا `FLAVOR`).

```bash
flutter run --dart-define=BASE_URL=https://api.osta.dev/api/v1
```

---

## Related / مرتبط

- [02_architecture.md](02_architecture.md) · [04_how_to_add_new_api.md](04_how_to_add_new_api.md) · [../features/README.md](../features/README.md) · [../reference/COMMON_PITFALLS.md](../reference/COMMON_PITFALLS.md) · [docs/ROADMAP.md](../../docs/ROADMAP.md)
