# ADR 005 — No codegen: plain Equatable models + manual get_it (freezed / json_serializable / injectable deferred)

## Status / الحالة

Accepted (2026-07-02, amended 2026-07-05)

> ‏مقبول (2026-07-02، مُعدَّل في 2026-07-05 ليطابق إعادة الهيكلة التي أجّلت الأدوات المتقدّمة — انظر [../../docs/ROADMAP.md](../../docs/ROADMAP.md)).

## Context / السياق

The app will grow to dozens of models/DTOs (a large backend API surface) and a DI graph that expands with every feature (data source + repo + use cases + bloc each). At that scale, annotation-driven codegen looks attractive — but the immediate priority is a team **new to Flutter** being productive in plain, readable Dart today, without a hidden `build_runner` step standing between an edit and a passing build.

> ‏التطبيق هيكبر لعشرات الموديلز والـ DTOs (سطح واسع للـ backend API) ولرسم بياني للـ DI بيتوسّع مع كل فيتشر (data source + repo + use cases + bloc لكل واحد). على النطاق ده، الـ codegen المبني على الـ annotations بيبان مغري — لكن الأولوية دلوقتي إن فريق **جديد على Flutter** يقدر ينتج بسرعة بـ Dart بسيط وواضح، من غير خطوة `build_runner` مخفية بتقف بين التعديل والـ build الناجح.

## Decision / القرار

We use **no code generation** for models or DI. Everything is plain, hand-written Dart that reads top to bottom.

> ‏احنا مش بنستخدم أي **code generation** للموديلز أو الـ DI. كل حاجة Dart عادي مكتوب باليد بيتقرأ من فوق لتحت.

- **Models** — plain `class X extends Equatable` with hand-written `factory fromJson` / `toJson` / `props`. No `@freezed`, no `@JsonSerializable`, no `part '*.g.dart'`. See `lib/features/auth/data/models/auth_token_model.dart`.
- **DI** — **manual** `get_it` registration in `lib/core/di/injection.dart`: a global `getIt` and a `configureDependencies()` that hand-wires each service with `registerLazySingleton` / `registerSingleton`. No `@injectable`, no `injection.config.dart`.
- **Generated code** — the **only** generated code in the repo is localization (`flutter gen-l10n` → `lib/core/l10n/`). There is no `build_runner` in the pipeline.

The DI graph is wired by hand:

> ‏رسم الـ DI بيتوصّل باليد:

```dart
// lib/core/di/injection.dart
final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  getIt.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
  getIt
    ..registerLazySingleton<AppConfig>(AppConfig.new)
    ..registerLazySingleton<TokenStorage>(() => TokenStorage(getIt()))
    ..registerLazySingleton<Dio>(() => buildAppDio(getIt(), getIt(), getIt()))
    ..registerLazySingleton<ApiClient>(() => ApiClient(getIt()));
  // a new service = one more hand-written registerLazySingleton line
}
```

Models are plain Equatable value types:

> ‏الموديلز عبارة عن قيم Equatable عادية:

```dart
// lib/features/auth/data/models/auth_token_model.dart
class AuthTokenModel extends Equatable {
  const AuthTokenModel({required this.accessToken, required this.refreshToken});

  factory AuthTokenModel.fromJson(Map<String, dynamic> json) => AuthTokenModel(
        accessToken: json['access_token'] as String,
        refreshToken: json['refresh_token'] as String,
      );

  final String accessToken;
  final String refreshToken;

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
      };

  @override
  List<Object?> get props => [accessToken, refreshToken];
}
```

`freezed`, `json_serializable`, and `injectable` are **deferred, not rejected** — they have a phased reintroduction plan in [../../docs/ROADMAP.md](../../docs/ROADMAP.md) (Phases 1–3), to be adopted once the team is comfortable and the model/DI surface makes the boilerplate a real cost.

> ‏الأدوات `freezed` و`json_serializable` و`injectable` **مؤجَّلة، مش مرفوضة** — ليها خطة إعادة إدخال على مراحل في [../../docs/ROADMAP.md](../../docs/ROADMAP.md) (المراحل 1–3)، هتتبنى لما الفريق يرتاح ولما حجم الموديلز والـ DI يخلّي الـ boilerplate تكلفة حقيقية.

## Consequences / النتائج

### Positive / الإيجابيات

Every model and every registration is visible where it lives — no generator to run, no generated file to reason about. A contributor new to the project reads one file and understands exactly what happens; edit-to-build has no hidden step, and the whole toolchain a newcomer must learn shrinks.

> ‏كل موديل وكل تسجيل ظاهر في مكانه — مفيش generator تشغّله ولا ملف مولَّد تفكّر فيه. المساهم الجديد بيقرأ ملف واحد ويفهم بالظبط بيحصل إيه؛ مفيش خطوة مخفية بين التعديل والـ build، وسلسلة الأدوات اللي المبتدئ لازم يتعلّمها بتصغر.

### Negative / السلبيات

Hand-written `fromJson`/`toJson` and manual registrations are boilerplate that scales linearly with the model and service count, and a typo in a snake_case key or a forgotten registration is a runtime bug the compiler will not catch. This is the cost we accept for now; the [../../docs/ROADMAP.md](../../docs/ROADMAP.md) plan is the release valve when the cost outweighs the simplicity.

> ‏الـ `fromJson`/`toJson` المكتوب باليد والتسجيلات اليدوية عبارة عن boilerplate بيكبر خطيًّا مع عدد الموديلز والخدمات، وأي خطأ إملائي في مفتاح snake_case أو تسجيل منسي هيبقى bug وقت التشغيل الـ compiler مش هيمسكه. دي التكلفة اللي احنا قابلينها دلوقتي؛ وخطة [../../docs/ROADMAP.md](../../docs/ROADMAP.md) هي صمّام الأمان لما التكلفة تفوق البساطة.

### Alternatives rejected / البدائل المرفوضة

The annotation-driven codegen stack (`injectable` + `freezed` + `json_serializable` on `build_runner`) removes the boilerplate but adds a mandatory generation step every contributor must run or the build breaks — the wrong trade-off for a Flutter-new team getting started. `dart_mappable` and similar offer no advantage that changes this calculus today. All of these stay on the table via [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

> ‏مجموعة الـ codegen المبنية على الـ annotations (`injectable` + `freezed` + `json_serializable` فوق `build_runner`) بتشيل الـ boilerplate لكن بتضيف خطوة توليد إجبارية لازم كل مساهم يشغّلها وإلا الـ build بيقع — وهي مقايضة غلط لفريق جديد على Flutter لسه بادئ. و`dart_mappable` وأمثاله مش بيقدّموا ميزة بتغيّر الحساب ده النهارده. كل دي فاضلة على الطاولة عن طريق [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

### Follow-ups / المتابعات

Keep models and DI hand-written and readable; add a `registerLazySingleton` line per new service and a `fromJson`/`toJson`/`props` per new model. The only generated artifact remains l10n — after touching ARB files run `flutter gen-l10n`. See [../guides/03_how_to_add_new_feature.md](../guides/03_how_to_add_new_feature.md) for the per-feature checklist and [../reference/TROUBLESHOOTING.md](../reference/TROUBLESHOOTING.md) for common issues.

> ‏خلّي الموديلز والـ DI مكتوبين باليد وواضحين؛ ضيف سطر `registerLazySingleton` لكل خدمة جديدة و`fromJson`/`toJson`/`props` لكل موديل جديد. الحاجة الوحيدة المولَّدة فاضلة هي الـ l10n — بعد ما تعدّل ملفات الـ ARB شغّل `flutter gen-l10n`. راجع [../guides/03_how_to_add_new_feature.md](../guides/03_how_to_add_new_feature.md) لقائمة الفيتشر و[../reference/TROUBLESHOOTING.md](../reference/TROUBLESHOOTING.md) للمشاكل الشائعة.
