# ADR 004 — Sealed `Failure` + plain `try`/`catch` for error handling

## Status

Accepted (2026-07-02, amended 2026-07-05)

## Context / السياق

The network layer produces typed `ApiException`s (422 validation with field errors, 401, 403, 404, 429, 5xx, transport). Those must not leak into presentation, and the BLoC layer needs a clear, predictable way to branch success vs failure. The team is new to Flutter, so the error model must stay in plain, readable Dart that any contributor can follow on day one.

> ‏تُنتج طبقة الشبكة استثناءات `ApiException` مُصنّفة (تحقّق 422 مع أخطاء الحقول، و401، و403، و404، و429، و5xx، وأخطاء النقل). يجب ألّا تتسرّب هذه الأخطاء إلى طبقة العرض، وتحتاج طبقة الـ BLoC إلى طريقة واضحة ومتوقّعة للتفريع بين النجاح والفشل. الفريق جديد على Flutter، لذا يجب أن يبقى نموذج معالجة الأخطاء مكتوبًا بلغة Dart بسيطة وقابلة للقراءة يستطيع أي مساهم متابعتها من أول يوم.

## Decision / القرار

We represent domain errors as a **sealed `Failure` class** (`lib/core/error/failure.dart`) and handle them with **plain `try`/`catch`** — no `fpdart`, no `Either<Failure, T>`, no `Result<T>` typedef, no `.fold()`.

> ‏نُمثّل أخطاء النطاق عبر صنف `Failure` من نوع `sealed` (في `lib/core/error/failure.dart`)، ونعالجها باستخدام `try`/`catch` العادي — بدون `fpdart`، وبدون `Either<Failure, T>`، وبدون اسم مُستعار `Result<T>`، وبدون `.fold()`.

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

Repositories are the boundary: they `try`/`catch` the typed `ApiException`s the network layer throws and rethrow the matching `Failure`. BLoCs `try`/`catch` the `Failure` and emit the right state. Nothing above the repository sees Dio or `ApiException`.

> ‏المستودعات (repositories) هي الحدّ الفاصل: تلتقط استثناءات `ApiException` المُصنّفة التي ترميها طبقة الشبكة عبر `try`/`catch`، ثم تعيد رمي `Failure` المناسب. تلتقط الـ BLoCs هذا الـ `Failure` عبر `try`/`catch` وتُصدر الحالة المناسبة. لا شيء فوق المستودع يرى Dio أو `ApiException`.

**`fpdart` is deferred, not rejected.** Functional error values (`Either`) are a real option once the team is comfortable in Flutter; the phased reintroduction lives in [ROADMAP Phase 5](../../docs/ROADMAP.md). We chose the simplest thing that works today.

> ‏تأجّل استخدام `fpdart`، ولم يُرفض. قِيَم الأخطاء الوظيفية (`Either`) خيار حقيقي بمجرد أن يألف الفريق Flutter؛ وخطة إعادة إدخالها على مراحل موجودة في [ROADMAP المرحلة 5](../../docs/ROADMAP.md). اخترنا أبسط حلٍّ ناجح اليوم.

## Consequences / النتائج

- **Positive / إيجابيات:**
  - Plain `try`/`catch` is idiomatic Dart every contributor already knows — zero learning curve.
  - Clean separation stays intact: transport concerns live in data; the domain speaks `Failure`.
  - The `sealed` modifier still gives exhaustive `switch` over `Failure` subtypes when a caller wants to branch by type.

  > ‏استخدام `try`/`catch` العادي أسلوب Dart المألوف الذي يعرفه كل مساهم — بلا منحنى تعلّم. ويبقى الفصل نظيفًا: شؤون النقل داخل طبقة البيانات، والنطاق يتحدّث بلغة `Failure`. كما يمنحنا المُعدِّل `sealed` تفريعًا شاملًا عبر `switch` على أنواع `Failure` الفرعية عندما يريد المُستدعي التفريع حسب النوع.

- **Negative / سلبيات:**
  - Nothing forces a caller to catch — a forgotten `try`/`catch` compiles. We mitigate with a thin, consistent repository→bloc convention and tests.

  > ‏لا شيء يُجبر المُستدعي على الالتقاط — نسيان `try`/`catch` يُترجَم دون خطأ. نُخفّف ذلك عبر اتفاقية موحّدة ورفيعة من المستودع إلى الـ bloc، ومع الاختبارات.

- **Alternatives rejected / بدائل مرفوضة:**
  - **`fpdart` `Either<Failure, T>` now** — adds a functional-style learning curve for a Flutter-new team; deferred to [ROADMAP Phase 5](../../docs/ROADMAP.md) rather than adopted upfront.
  - **Per-feature sealed result classes** — reinvents the same wrapper N times.

  > ‏تبنّي `fpdart` بـ `Either<Failure, T>` الآن يُضيف منحنى تعلّم للأسلوب الوظيفي على فريقٍ جديد على Flutter؛ لذا أُجّل إلى [ROADMAP المرحلة 5](../../docs/ROADMAP.md) بدل تبنّيه مُقدَّمًا. أما أصناف النتائج المُغلقة لكل ميزة على حدة فتُعيد اختراع نفس الغلاف مرارًا.

- **Follow-ups / متابعات:**
  - Repositories map each `ApiException` subtype to the right `Failure` (see [../guides/04_how_to_add_new_api.md](../guides/04_how_to_add_new_api.md)).

  > ‏تُطابق المستودعات كل نوع فرعي من `ApiException` مع `Failure` المناسب (انظر [../guides/04_how_to_add_new_api.md](../guides/04_how_to_add_new_api.md)).
