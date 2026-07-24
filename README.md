<div align="center">

<img src="assets/images/app_icon.png" alt="OSTA" width="132" />

# OSTA · أُسطى

**Car maintenance in minutes.** One Flutter app, every role.

‏**صيانة سيارتك في دقائق.** تطبيق Flutter واحد، لكل الأدوار.

<img src="assets/images/osta.png" alt="" width="180" />

![Flutter](https://img.shields.io/badge/Flutter-3.44.1-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-%5E3.12.1-0175C2?logo=dart&logoColor=white)
![Lints](https://img.shields.io/badge/lints-very__good__analysis-0E7A3B)
![l10n](https://img.shields.io/badge/l10n-EN%20%C2%B7%20AR%20(RTL)-F5A623)
![License](https://img.shields.io/badge/license-All_Rights_Reserved-B00020)

</div>

---

Single Flutter app (Android + iOS) hosting **every role flow** — customer &
business now, mechanic/tow later — in **one** app target. No monorepo, no Melos.
Feature-first `lib/`, strict shared lints, and a CI pipeline that gates every PR.

> ‏تطبيق Flutter واحد (أندرويد + iOS) يحتوي على **كل مسارات الأدوار** — العميل وصاحب العمل الآن، والميكانيكي وخدمة السحب لاحقًا — في هدف تطبيق **واحد**. بدون monorepo وبدون Melos. بنية `lib/` قائمة على المزايا (feature-first)، وقواعد lint صارمة ومشتركة، وخط CI يفحص كل PR.

## Getting started / البدء

```bash
git clone https://github.com/YoussefSalem582/Osta-App.git
cd Osta-App                        # working dir: osta_app
flutter pub get
flutter run
```

No code generation is required — models, DI and error handling are plain,
hand-written Dart (see [docs/ROADMAP.md](docs/ROADMAP.md) for the codegen
tooling deferred while the team ramps up on Flutter). Only localizations are
generated (`lib/core/l10n/`, git-ignored); `flutter gen-l10n` runs
automatically on `flutter run`/`build`.

> ‏لا حاجة لأي توليد كود — الموديلات وحقن الاعتماديات (DI) ومعالجة الأخطاء كلها Dart عادي ومكتوب باليد (راجع [docs/ROADMAP.md](docs/ROADMAP.md) لأدوات توليد الكود المؤجَّلة ريثما يكتسب الفريق خبرة في Flutter). الشيء الوحيد الذي يُولَّد هو ملفات الترجمة (`lib/core/l10n/`، وهي مُستبعَدة من git)؛ ويعمل `flutter gen-l10n` تلقائيًا مع `flutter run`/`build`.

### First-run flow / مسار أول تشغيل

A single pure guard (`lib/core/router/session_redirect.dart`) drives every
redirect:

```text
splash → language → role → onboarding → auth-choose → auth → role shell
```

The language, role and onboarding gates re-show on every **logged-out** launch
(in-memory flags; the saved locale and role are the pre-selected defaults). A
valid `{token, activeRole}` skips straight to the shell — there is no guest
path. A freshly-registered **business** user runs the provider onboarding
wizard before reaching its shell.

> ‏يقود التوجيهَ حارسٌ واحد نقي (`lib/core/router/session_redirect.dart`): splash ← اللغة ← الدور ← onboarding ← اختيار المصادقة ← المصادقة ← واجهة الدور. تُعرض بوابات اللغة والدور والـ onboarding في كل تشغيل **غير مسجَّل الدخول** (أعلام في الذاكرة، واللغة والدور المحفوظان هما الافتراضيان). ووجود `{token, activeRole}` صالح يقفز مباشرةً إلى الواجهة — لا يوجد مسار ضيف. ومستخدم **النشاط التجاري** المسجَّل حديثًا يمرّ بمُرشد التأهيل قبل واجهته.

## Environment / البيئة

The API base URL is compile-time via `--dart-define` (no secrets in the repo).
It defaults to the live backend, so `flutter run` with no flags works:

> ‏عنوان الـ API الأساسي يُحدَّد وقت الترجمة عبر `--dart-define` (بدون أي أسرار داخل المستودع)، وقيمته الافتراضية هي الخادم الحيّ، فيعمل `flutter run` بلا أي إضافات.

```bash
# Optional — override per environment:
flutter run --dart-define=BASE_URL=https://osta.technology92.com/api/v1
```

Multi-flavor (dev/staging/prod) builds are deferred — see
[docs/ROADMAP.md](docs/ROADMAP.md).

> ‏بناء عدة نكهات (dev/staging/prod) مؤجَّل — راجع [docs/ROADMAP.md](docs/ROADMAP.md).

## Project structure / بنية المشروع

```text
lib/
  main.dart            # boot: DI init → runApp(OstaApp)
  app.dart             # MaterialApp.router + theme + l10n
  core/                # cross-cutting foundation
    config/            # AppConfig (single BASE_URL via --dart-define)
    network/           # Dio client (retry + redacted logger)
    auth/              # secure token storage
    session/           # SessionController (single source of routing truth)
    router/            # go_router + the pure redirect guard
    theme/             # Material 3 light/dark + design tokens
    l10n/              # generated AppLocalizations (en, ar — RTL)
    error/             # Failure (sealed hierarchy)
    di/                # get_it (manual registration)
    constants/         # shared constant values
  features/            # one folder per area, each split data/ domain/ presentation/
    splash/  language/ role/  onboarding/  auth/
    home/  customer/  business/  shop/  shell/  notifications/
  shared/              # reusable widgets + extensions
assets/
  images/              # brand assets (see below)
  fonts/               # Cairo (variable, wght 200–900)
```

## Brand assets / أصول العلامة

Everything lives in `assets/images/` and ships with the app (`pubspec.yaml`
bundles the whole folder). Never hardcode an asset path — `AppImages`
(`lib/core/constants/app_images.dart`) is the only place those strings live.
The brand green is `#0E7A3B` (`AppColors.brandGreen`); the accent amber is the
smile under the wordmark.

> ‏كل الأصول في `assets/images/` وتُشحَن مع التطبيق. لا تكتب مسار أصل يدويًا — `AppImages` هو المكان الوحيد لهذه النصوص. الأخضر الأساسي `#0E7A3B`، واللون المكمّل هو الابتسامة الكهرمانية تحت الشعار.

| Asset | Preview | `AppImages` | Used by |
| --- | --- | --- | --- |
| `app_icon.png` | <img src="assets/images/app_icon.png" width="56" alt="app icon" /> | — | Launcher icon (`flutter_launcher_icons`), and the tile above |
| `app_icon_foreground.png` | — | — | Android adaptive foreground + Android 12 splash (padded so the mask can't clip the wordmark) |
| `logo.png` | <img src="assets/images/logo.png" width="56" alt="wordmark" /> | `logo` | Native + in-app splash, the `BrandScaffold` band on the inner auth screens, and the role shell's top bar (tinted brand green) |
| `full_logo.png` | <img src="assets/images/full_logo.png" width="56" alt="full lockup" /> | `fullLogo` | Landing screens — language pick, auth-choose, first onboarding slide |
| `osta.png` | <img src="assets/images/osta.png" width="56" alt="mascot" /> | `mascot` | The mascot alone — second onboarding slide |

`logo.png` and `full_logo.png` are **white on transparent**: they read on the
brand green and on dark surfaces, and vanish on white. Tint them
(`Image.asset(..., color: AppColors.brandGreen)`, as the role shell does) or
reach for `app_icon.png` wherever the background is light or unknown.

> ‏‏`logo.png` و`full_logo.png` أبيضان على خلفية شفافة: يظهران على الأخضر والأسطح الداكنة، ويختفيان على الأبيض. لوِّنهما (`Image.asset(..., color: AppColors.brandGreen)` كما تفعل واجهة الدور) أو استخدم `app_icon.png` عندما تكون الخلفية فاتحة أو غير معروفة.

The native launcher icon and splash are regenerated manually (they are **not**
`build_runner` codegen):

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
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

## Documentation / التوثيق

| Need | File |
| --- | --- |
| Project conventions (canonical, everything-doc) | [AGENTS.md](AGENTS.md) |
| Layers, data flow, DI, routing | [osta_readme_files/docs/ARCHITECTURE.md](osta_readme_files/docs/ARCHITECTURE.md) |
| Doc index & task map | [osta_readme_files/INDEX.md](osta_readme_files/INDEX.md) |
| What to build next | [osta_readme_files/reference/DELIVERY_PLAN.md](osta_readme_files/reference/DELIVERY_PLAN.md) |
| Deferred tooling & phased plan | [docs/ROADMAP.md](docs/ROADMAP.md) |
| Contributing | [CONTRIBUTING.md](CONTRIBUTING.md) |

## Branch & PR conventions / أعراف الفروع والـ PR

- **`develop`** integrates all work; **`main`** is the protected release branch (updated only by a `develop → main` release PR).
- Branch off `develop`: `feat/<issue>-<slug>` (e.g. `feat/28-app-scaffolding-ci`) — hand-written kebab-case names only; **never** tool-generated names like `claude/...` (rename with `git branch -m` first).
- PR **base is `develop`**; keep CI green. A finished version/milestone ships to `main` via a `develop → main` release PR (tag `v0.<n>.0`, `v1.0.0` = MVP).
- PR description in **Arabic + English**; reference the issue (`Closes #<n>`).

> ‏**`develop`** فرع التكامل لكل العمل، و**`main`** فرع الإصدار المحميّ (لا يُحدَّث إلا بطلب دمج `develop → main`). افرِّع من `develop` بالنمط `feat/<issue>-<slug>` (مثل `feat/28-app-scaffolding-ci`) — أسماء الفروع تُكتب يدويًا فقط، ويُمنع الإبقاء على الأسماء المولَّدة من الأدوات مثل `claude/...` (أعد التسمية بـ `git branch -m` أولًا). قاعدة الـ PR هي `develop`، وحافظ على الـ CI باللون الأخضر؛ وتصل النسخة المكتملة إلى `main` عبر طلب دمج `develop → main` (بوسم `v0.<n>.0`، و`v1.0.0` للـ MVP). واكتب وصف الـ PR **بالعربية والإنجليزية**، مع الإشارة إلى الـ issue (`Closes #<n>`).

## License & ownership / الرخصة والملكية

**All rights reserved — source-available, view-only.** This repository is
public **only** so anyone can follow the project's progress and open issues.
No part of the code, documentation, assets, or the **OSTA / أسطى** name and
brand may be used, copied, modified, or redistributed without prior written
permission. Development is restricted to the OSTA team. See
[LICENSE](LICENSE) · [OWNERSHIP.md](OWNERSHIP.md).

> ‏**جميع الحقوق محفوظة — الكود معروض للاطّلاع فقط.** المستودع علني فقط
> لمتابعة تقدّم المشروع وفتح المشاكل؛ ولا يجوز استخدام أو نسخ أو تعديل أو
> إعادة نشر أي جزء من الكود أو التوثيق أو الأصول أو اسم **OSTA / أسطى**
> والعلامة دون إذن كتابي مسبق. التطوير حكر على فريق OSTA. راجع
> [LICENSE](LICENSE) و[OWNERSHIP.md](OWNERSHIP.md).
