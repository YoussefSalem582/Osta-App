# Common Pitfalls / الأخطاء الشائعة

> [INDEX](../INDEX.md) > Common Pitfalls
>
> "Don't X, do Y" cheat-sheet. Each item is `DON'T` / `DO` / `WHY`. Agent-parseable.

This page collects the mistakes that keep biting people in this codebase. The stack is deliberately plain Dart — no codegen beyond l10n — so most pitfalls are about respecting the hand-written tokens, the manual DI, and the try/catch error contract. Advanced tooling is deferred, not rejected; see the phased plan in [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

> ‏الصفحة دي بتجمع الأخطاء اللي بتتكرر كتير في المشروع. الـ stack مقصود إنه Dart بسيط — مفيش codegen غير الـ l10n — فمعظم الأخطاء بتكون في احترام الـ tokens المكتوبة باليد، والـ DI اليدوي، وعقد معالجة الأخطاء بـ try/catch. الأدوات المتقدمة مؤجلة مش مرفوضة؛ راجع الخطة المرحلية في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

## Design tokens / رموز التصميم

Never reach past the token layer to raw values — the theme can't override what you hardcode.

> ‏متتخطاش طبقة الـ tokens للقيم الخام — الثيم مش هيقدر يتحكم في حاجة اتكتبت بشكل ثابت.

### Hardcoded colour
DON'T: `Color(0xFF0E7A3B)` or `Colors.green`
DO: `context.appColors.accent` or `Theme.of(context).colorScheme.primary`
WHY: Light/dark can't override a raw hex — the wrong colour ships in dark mode.

> ‏الوضع الفاتح/الغامق مش بيقدر يتجاوز قيمة hex ثابتة — فبيتشحن لون غلط في الوضع الغامق.

### Raw spacing / radius
DON'T: `EdgeInsets.all(16)` · `BorderRadius.circular(12)`
DO: `EdgeInsets.all(AppSpacing.md)` · `BorderRadius.circular(AppRadii.md)`
WHY: The scale stays consistent; responsive helpers depend on named tokens.

> ‏المقياس بيفضل متناسق؛ ومساعدات التجاوب بتعتمد على الـ tokens المسمّاة.

### Inline TextStyle
DON'T: `TextStyle(fontSize: 14, fontWeight: FontWeight.w600)`
DO: `Theme.of(context).textTheme.titleMedium`
WHY: Cairo variable-font weights only apply via `AppTypography`; synthetic bold looks wrong.

> ‏أوزان خط Cairo المتغيّر بتتطبّق بس من خلال `AppTypography`؛ والـ bold الصناعي بيطلع شكله وحش.

### Hardcoded asset path
DON'T: `Image.asset('assets/images/logo.png')`
DO: `Image.asset(AppImages.logo)`
WHY: Renaming an asset breaks at the call site, not at the constants table.

> ‏إعادة تسمية أصل بتكسر عند نقطة الاستدعاء، مش عند جدول الثوابت.

## Localization / التوطين

Every user-facing string goes through l10n, and every key lives in both ARB files. l10n is the one thing this project still generates.

> ‏كل نص بيظهر للمستخدم بيعدّي من خلال الـ l10n، وكل مفتاح لازم يكون موجود في ملفّي الـ ARB الاتنين. الـ l10n هو الحاجة الوحيدة اللي المشروع لسه بيولّدها.

### Raw user-facing string
DON'T: `Text('Book now')`
DO: `Text(context.l10n.bookNow)`
WHY: Arabic users see English; the RTL audit breaks.

> ‏المستخدم العربي هيشوف إنجليزي؛ ومراجعة الـ RTL هتتكسر.

### Key in one ARB only
DON'T: Add to `app_en.arb`, skip `app_ar.arb`.
DO: Add to **both**, then `flutter gen-l10n`.
WHY: `nullable-getter: false` makes a missing Arabic key a **compile error**.

> ‏إعداد `nullable-getter: false` بيخلّي أي مفتاح عربي ناقص خطأ في وقت الـ compile.

### Hand-formatted money
DON'T: `'EGP $amount'`
DO: `EgpFormatter.format(amount, locale)`
WHY: Egyptian locale needs Arabic-Indic digits + correct grouping.

> ‏اللغة المصرية محتاجة أرقام عربية-هندية وتجميع صحيح للخانات.

## Networking & auth / الشبكة والمصادقة

Go through `ApiClient` for every call and let the interceptor own token refresh. The network layer throws typed `ApiException`s; repositories convert those to a `Failure`.

> ‏عدّي على `ApiClient` في كل طلب وسيب الـ interceptor يتولّى تجديد التوكن. طبقة الشبكة بترمي `ApiException` من نوع محدّد؛ والـ repositories بتحوّلها لـ `Failure`.

### Calling Dio directly
DON'T: `dio.get('/centers/nearby')`
DO: `apiClient.get<T>(ApiEndpoints.centersNearby)`
WHY: `ApiClient` parses the envelope and throws typed errors; a raw Dio call bypasses both.

> ‏`ApiClient` بيفك المغلّف (envelope) ويرمي أخطاء من نوع محدّد؛ ونداء Dio الخام بيتخطّى الاتنين.

### Expecting 401 on bad login
DON'T: treat a wrong password as `UnauthenticatedException` (401).
DO: handle it as `ValidationException` (**422** with `fieldErrors`).
WHY: The backend returns 422 for bad credentials by design.

> ‏الـ backend بيرجّع 422 للبيانات الغلط بشكل مقصود، مش 401.

### Manual 401 handling
DON'T: catch 401 in a bloc and refresh the token yourself.
DO: let `AuthInterceptor` do the single refresh-retry; react to `AuthEvents.onSessionExpired`.
WHY: Duplicated refresh logic causes refresh storms and double-logout.

> ‏منطق التجديد المكرّر بيسبّب عواصف تجديد وخروج مزدوج من الحساب.

### Tokens in SharedPreferences
DON'T: `prefs.setString('token', …)`
DO: `TokenStorage.writeTokens(...)` (flutter_secure_storage).
WHY: SharedPreferences is plaintext; tokens must be encrypted.

> ‏الـ SharedPreferences نص صريح؛ والتوكِنات لازم تتشفّر.

## Error handling / معالجة الأخطاء

Errors are a sealed `Failure` plus plain `try`/`catch`. There is no `Either`, no `Result<T>`, no `.fold()` — fpdart is deferred (see [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md) Phase 5). Repositories throw a `Failure`; blocs catch it. This keeps the flow readable for a team new to Flutter.

> ‏الأخطاء عبارة عن `Failure` من نوع sealed مع `try`/`catch` عادي. مفيش `Either` ولا `Result<T>` ولا `.fold()` — الـ fpdart مؤجّل (راجع المرحلة 5 في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)). الـ repositories بترمي `Failure`؛ والـ blocs بتمسكها. ده بيخلّي المسار واضح لفريق جديد على Flutter.

### Wrapping results in Either / Result<T>
DON'T: `Either<Failure, User>` · `result.fold(onError, onOk)` · a `Result<T>` typedef.
DO: throw a `Failure` from the repository and `try { … } catch (Failure f) { … }` in the bloc.
WHY: fpdart was removed for beginner-friendliness; the whole app is try/catch. Reintroducing `Either` now splits the codebase in two styles.

> ‏الـ fpdart اتشال عشان يبقى أسهل للمبتدئين؛ والتطبيق كله try/catch. رجوع `Either` دلوقتي بيقسّم الكود لأسلوبين.

### Inventing a new failure type inline
DON'T: `throw Exception('network down')` from a repository.
DO: throw one of the sealed cases — `NetworkFailure` / `ServerFailure` / `UnknownFailure` from `lib/core/error/failure.dart`.
WHY: The sealed hierarchy lets the bloc switch exhaustively; a bare `Exception` slips past that and shows a generic message.

> ‏التسلسل الـ sealed بيخلّي الـ bloc يعمل switch شامل؛ والـ `Exception` المجرّد بيفلت من ده وبيعرض رسالة عامة.

## Dependency injection / حقن الاعتماديات

DI is **manual** `get_it` — no annotations, no generated `injection.config.dart`. Registrations live by hand in `lib/core/di/injection.dart` (`configureDependencies()`, global `getIt`). `injectable` is deferred (see [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md) Phases 1–3).

> ‏الـ DI عبارة عن `get_it` **يدوي** — مفيش annotations ولا ملف `injection.config.dart` مولَّد. التسجيلات مكتوبة باليد في `lib/core/di/injection.dart` (`configureDependencies()` والـ `getIt` العام). الـ `injectable` مؤجّل (راجع المراحل 1–3 في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)).

### Reaching for @injectable / build_runner
DON'T: annotate a service `@injectable` and run `build_runner` to wire it.
DO: add one hand-written line to `configureDependencies()`, e.g. `getIt.registerLazySingleton<Foo>(() => Foo(getIt()));`.
WHY: There is no generator in the pipeline; the annotation does nothing and `injection.config.dart` does not exist.

> ‏مفيش مولّد في المسار؛ والـ annotation مش بتعمل حاجة و`injection.config.dart` مش موجود أصلاً.

## Models / النماذج

Models are plain `class X extends Equatable` with hand-written `fromJson` / `toJson` / `props`. See `lib/features/auth/data/models/auth_token_model.dart`. No `@freezed`, no `@JsonSerializable`, no `part '*.g.dart'`.

> ‏النماذج عبارة عن `class X extends Equatable` عادي مع `fromJson` / `toJson` / `props` مكتوبين باليد. شوف `lib/features/auth/data/models/auth_token_model.dart`. مفيش `@freezed` ولا `@JsonSerializable` ولا `part '*.g.dart'`.

### Reaching for @freezed / @JsonSerializable
DON'T: annotate a model `@freezed` / `@JsonSerializable` and add a `part '*.g.dart';`.
DO: write the class by hand — extend `Equatable`, add `factory X.fromJson(Map<String, dynamic>)`, `toJson()`, and `props`.
WHY: `freezed` / `json_serializable` are deferred ([`../../docs/ROADMAP.md`](../../docs/ROADMAP.md) Phases 1–3); the `.freezed.dart` / `.g.dart` parts they reference are never generated, so the file won't compile.

> ‏الـ `freezed` / `json_serializable` مؤجّلين (المراحل 1–3 في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md))؛ وأجزاء `.freezed.dart` / `.g.dart` اللي بيشيروا ليها مش بتتولّد، فالملف مش هيتترجم.

## Config & build / الإعدادات والبناء

There is a single `BASE_URL` dart-define read by `AppConfig`. No `AppFlavor`, no `FLAVOR`, no `--flavor`. Multi-flavor builds are deferred ([`../../docs/ROADMAP.md`](../../docs/ROADMAP.md) Phase 4).

> ‏فيه `BASE_URL` واحد بس بيتقرأ من خلال `AppConfig`. مفيش `AppFlavor` ولا `FLAVOR` ولا `--flavor`. بناءات الـ flavor المتعددة مؤجّلة (المرحلة 4 في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)).

### Passing a FLAVOR / --flavor
DON'T: `flutter run --flavor dev --dart-define=FLAVOR=dev`.
DO: `flutter run --dart-define=BASE_URL=https://osta.technology92.com/api/v1`.
WHY: There is no `AppFlavor` enum and no flavor config; only `BASE_URL` is read.

> ‏مفيش enum اسمه `AppFlavor` ولا إعداد flavor؛ الـ `BASE_URL` بس هو اللي بيتقرأ.

### Running build_runner
DON'T: `dart run build_runner build --delete-conflicting-outputs` before analyze/test.
DO: nothing — only l10n generates, via `flutter gen-l10n` (and it runs automatically on `flutter run` / `flutter build`).
WHY: No `@freezed` / `@injectable` / `@JsonSerializable` remain, so there is nothing for `build_runner` to do.

> ‏مفيش `@freezed` / `@injectable` / `@JsonSerializable` فاضلين، فمفيش حاجة يعملها `build_runner`.

## Codegen & generated files / توليد الكود والملفات المولّدة

The only generated code is l10n under `lib/core/l10n/`. Files like `*.g.dart`, `*.freezed.dart`, and `injection.config.dart` no longer exist — don't create or reference them.

> ‏الكود المولّد الوحيد هو الـ l10n تحت `lib/core/l10n/`. ملفات زي `*.g.dart` و`*.freezed.dart` و`injection.config.dart` بقت مش موجودة — متعملهاش ومتشيرش ليها.

### Committing generated files
DON'T: `git add lib/core/l10n/` (the generated localizations).
DO: leave `lib/core/l10n/` git-ignored; regenerate with `flutter gen-l10n`.
WHY: It's a derived artifact; committing it causes merge noise and drift.

> ‏ده أثر مُشتَق؛ وإضافته للـ commit بتسبّب ضوضاء في الدمج وانحراف.

## CI / التكامل المستمر

CI is one job — "format · analyze · test" on ubuntu: `flutter pub get` → `flutter gen-l10n` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`. There are no Android/iOS build jobs and no `build_runner` step; those are deferred ([`../../docs/ROADMAP.md`](../../docs/ROADMAP.md) Phase 4).

> ‏الـ CI عبارة عن job واحد — "format · analyze · test" على ubuntu: `flutter pub get` ثم `flutter gen-l10n` ثم `dart format --set-exit-if-changed` ثم `flutter analyze` ثم `flutter test`. مفيش jobs لبناء Android/iOS ولا خطوة `build_runner`؛ دول مؤجّلين (المرحلة 4 في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)).

### Expecting a build matrix to gate the PR
DON'T: wait for `build-android` / `build-ios` checks, or add a `build_runner` step to the workflow.
DO: rely on the single "format · analyze · test" check in `.github/workflows/ci.yml`.
WHY: The matrix was collapsed to one job; the platform-build jobs are deferred to a later phase.

> ‏الـ matrix اتلمّ في job واحد؛ وjobs بناء المنصّات مؤجّلة لمرحلة لاحقة.

## Git & PRs / Git والطلبات

### Wrong branch / attribution
DON'T: branch off `design-assets` or `main`; add AI co-author trailers.
DO: `feat/<issue>-<slug>` off `develop`; PR base `develop`; plain commit messages.
WHY: `develop` is the integration base (`main` is release-only, reached via a `develop → main` release PR); commits reflect the developer identity.

> ‏`develop` هو قاعدة الدمج (و`main` للإصدار فقط عبر طلب دمج `develop → main`)؛ والـ commits بتعكس هوية المطوّر.

### English-only PR description
DON'T: describe the PR in English only.
DO: write it **Arabic + English** (matches the epics).

> ‏اكتب وصف الـ PR بالعربي والإنجليزي عشان يطابق الـ epics.

## Product rules / قواعد المنتج

These are domain rules the backend enforces or the epics fixed — getting them wrong ships a broken flow, not just a lint warning.

> ‏دي قواعد النطاق اللي الـ backend بيفرضها أو الـ epics ثبّتتها — الغلط فيها بيشحن flow مكسور، مش مجرد تحذير lint.

### Re-showing the role chooser
DON'T: show the chooser every launch.
DO: read persisted `activeRole` on splash; show it once.
WHY: [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32) — the chooser appears once; wrong shell auto-corrects with a toast.

> ‏[app #32](https://github.com/YoussefSalem582/Osta-App/issues/32) — المُختار بيظهر مرة واحدة؛ والـ shell الغلط بيتصحّح تلقائياً مع toast.

### Assuming business verification
DON'T: gate a business behind pending/approval.
DO: treat centers as **live the moment onboarding finishes** (open onboarding).
WHY: There is no verification step ([app #53](https://github.com/YoussefSalem582/Osta-App/issues/53)).

> ‏مفيش خطوة تحقّق؛ المراكز بتبقى مباشرة أول ما الـ onboarding يخلص ([app #53](https://github.com/YoussefSalem582/Osta-App/issues/53)).

### Wrong phone format
DON'T: accept arbitrary phone formats.
DO: Egyptian `+20` / `01x` only.
WHY: The backend normalizes to Egyptian E.164; other formats 422.

> ‏الـ backend بيوحّد الأرقام لصيغة E.164 المصرية؛ وأي صيغة تانية بترجّع 422.

### Building a cart in Shop
DON'T: add cart/checkout to the marketplace.
DO: browse + **enquire** only (call/WhatsApp lead).
WHY: The Shop is a two-sided enquiry marketplace, not e-commerce ([app #48](https://github.com/YoussefSalem582/Osta-App/issues/48)).

> ‏الـ Shop سوق استفسار ثنائي الجانب، مش تجارة إلكترونية ([app #48](https://github.com/YoussefSalem582/Osta-App/issues/48)).

### Confusing mechanic roster with the solo-mechanic role
DON'T: give center roster mechanics a login.
DO: roster mechanics are login-less staff records ([app #62](https://github.com/YoussefSalem582/Osta-App/issues/62)); the authenticated solo-mechanic is a separate Phase-2 role ([app #59](https://github.com/YoussefSalem582/Osta-App/issues/59)).

> ‏ميكانيكيّو القائمة سجلات موظفين بدون تسجيل دخول ([app #62](https://github.com/YoussefSalem582/Osta-App/issues/62))؛ والميكانيكي المستقل المُصادَق عليه دور منفصل في المرحلة 2 ([app #59](https://github.com/YoussefSalem582/Osta-App/issues/59)).
