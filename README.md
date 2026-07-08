# OSTA · أُسطى

Single Flutter app (Android + iOS) hosting **every role flow** — customer &
business now, mechanic/tow later — in **one** app target. No monorepo, no Melos.
Feature-first `lib/`, strict shared lints, and a CI pipeline that gates every PR.

> ‏تطبيق Flutter واحد (أندرويد + iOS) يحتوي على **كل مسارات الأدوار** — العميل وصاحب العمل الآن، والميكانيكي وخدمة السحب لاحقًا — في هدف تطبيق **واحد**. بدون monorepo وبدون Melos. بنية `lib/` قائمة على المزايا (feature-first)، وقواعد lint صارمة ومشتركة، وخط CI يفحص كل PR.

## Getting started / البدء

```bash
git clone https://github.com/YoussefSalem582/Osta-App.git
cd Osta-App                        # working dir: osta_app
flutter pub get
flutter run --dart-define=BASE_URL=https://api.osta.dev/api/v1
```

The app boots into a splash screen, then the first-run **role selection**.
No code generation is required — models, DI and error handling are plain,
hand-written Dart (see [docs/ROADMAP.md](docs/ROADMAP.md) for the codegen
tooling deferred while the team ramps up on Flutter). Only localizations are
generated (`lib/core/l10n/`, git-ignored); `flutter gen-l10n` runs
automatically on `flutter run`/`build`.

> ‏يبدأ التطبيق بشاشة splash، ثم **اختيار الدور** في أول تشغيل. لا حاجة لأي توليد كود — الموديلات وحقن الاعتماديات (DI) ومعالجة الأخطاء كلها Dart عادي ومكتوب باليد (راجع [docs/ROADMAP.md](docs/ROADMAP.md) لأدوات توليد الكود المؤجَّلة ريثما يكتسب الفريق خبرة في Flutter). الشيء الوحيد الذي يُولَّد هو ملفات الترجمة (`lib/core/l10n/`، وهي مُستبعَدة من git)؛ ويعمل `flutter gen-l10n` تلقائيًا مع `flutter run`/`build`.

## Environment / البيئة

The API base URL is compile-time via `--dart-define` (no secrets in the repo);
it defaults to the dev API when omitted:

> ‏عنوان الـ API الأساسي يُحدَّد وقت الترجمة عبر `--dart-define` (بدون أي أسرار داخل المستودع)؛ وعند حذفه يرجع افتراضيًا إلى واجهة الـ dev.

```bash
flutter run --dart-define=BASE_URL=https://api.osta.dev/api/v1
```

Multi-flavor (dev/staging/prod) builds are deferred — see
[docs/ROADMAP.md](docs/ROADMAP.md).

> ‏بناء عدة نكهات (dev/staging/prod) مؤجَّل — راجع [docs/ROADMAP.md](docs/ROADMAP.md).

## Project structure / بنية المشروع

```
lib/
  main.dart            # boot: DI init → runApp(OstaApp)
  app.dart             # MaterialApp.router + theme + l10n
  core/                # cross-cutting foundation
    config/            # AppConfig (single BASE_URL via --dart-define)
    network/           # Dio client (retry + redacted logger)
    auth/              # secure token storage
    router/            # go_router (splash → role)
    theme/             # Material 3 light/dark
    l10n/              # generated AppLocalizations (en, ar — RTL)
    error/             # Failure (sealed hierarchy)
    di/                # get_it (manual registration)
  features/            # one folder per area, each split data/ domain/ presentation/
    splash/  role/  auth/  customer/  business/  shop/  notifications/
  shared/              # reusable widgets + extensions
```

## Quality gates / بوابات الجودة

`flutter analyze` runs under **very_good_analysis** (strict, shared app-wide via
root `analysis_options.yaml`). CI (`.github/workflows/ci.yml`) runs a single job
on every PR:

> ‏يعمل `flutter analyze` تحت **very_good_analysis** (صارم، ومشترك على مستوى التطبيق كله عبر `analysis_options.yaml` في الجذر). ويشغّل الـ CI (`.github/workflows/ci.yml`) مهمة واحدة على كل PR:

`flutter pub get` → `flutter gen-l10n` → `dart format` (tracked files) →
`flutter analyze` → `flutter test`.

A red step fails the PR. (Platform build jobs — APK / iOS — are deferred; see
[docs/ROADMAP.md](docs/ROADMAP.md).)

> ‏أي خطوة تفشل تُسقِط الـ PR. (مهام بناء المنصّات — APK / iOS — مؤجَّلة؛ راجع [docs/ROADMAP.md](docs/ROADMAP.md).)

## Branch & PR conventions / أعراف الفروع والـ PR

- **`develop`** integrates all work; **`main`** is the protected release branch (updated only by a `develop → main` release PR).
- Branch off `develop`: `feat/<issue>-<slug>` (e.g. `feat/28-app-scaffolding-ci`) — hand-written kebab-case names only; **never** tool-generated names like `claude/...` (rename with `git branch -m` first).
- PR **base is `develop`**; keep CI green. A finished version/milestone ships to `main` via a `develop → main` release PR (tag `v0.<n>.0`, `v1.0.0` = MVP).
- PR description in **Arabic + English**; reference the issue (`Closes #<n>`).

> ‏**`develop`** فرع التكامل لكل العمل، و**`main`** فرع الإصدار المحميّ (لا يُحدَّث إلا بطلب دمج `develop → main`). افرِّع من `develop` بالنمط `feat/<issue>-<slug>` (مثل `feat/28-app-scaffolding-ci`) — أسماء الفروع تُكتب يدويًا فقط، ويُمنع الإبقاء على الأسماء المولَّدة من الأدوات مثل `claude/...` (أعد التسمية بـ `git branch -m` أولًا). قاعدة الـ PR هي `develop`، وحافظ على الـ CI باللون الأخضر؛ وتصل النسخة المكتملة إلى `main` عبر طلب دمج `develop → main` (بوسم `v0.<n>.0`، و`v1.0.0` للـ MVP). واكتب وصف الـ PR **بالعربية والإنجليزية**، مع الإشارة إلى الـ issue (`Closes #<n>`).
