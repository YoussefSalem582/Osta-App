> [INDEX](../INDEX.md) > Folder Structure

# 📁 Folder Structure / هيكل المجلدات

OSTA is a **single Flutter app** (no monorepo, no Melos) organized feature-first with Clean Architecture layers inside each feature. This guide maps the repo as it stands today (M0 foundation merged — [app #28](https://github.com/YoussefSalem582/Osta-App/issues/28), [#29](https://github.com/YoussefSalem582/Osta-App/issues/29), [#31](https://github.com/YoussefSalem582/Osta-App/issues/31)); most feature folders are **stubs** awaiting their open epics. The codebase is deliberately **plain Dart with no codegen** so a team new to Flutter can move fast — advanced tooling is deferred, not rejected (see [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)).

> ‏OSTA تطبيق Flutter **واحد** (بدون monorepo وبدون Melos)، منظّم بأسلوب feature-first مع طبقات Clean Architecture داخل كل ميزة. الدليل ده بيوصّف المستودع بوضعه الحالي (أساس M0 اتدمج)، ومعظم مجلدات الميزات لسه **stubs** مستنية الـ epics بتاعتها. الكود مكتوب عمداً بـ Dart بسيط **من غير أي codegen** علشان فريق جديد على Flutter يقدر يتحرك بسرعة — الأدوات المتقدمة **مؤجَّلة مش مرفوضة** (شوف [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)).

## Annotated `lib/` tree / شجرة `lib/` الموصّفة

Legend: 🔧 = generated (git-ignored) · 🚧 = stub folder (no dart files yet, planned by open epic). Only l10n is generated now.

> ‏المفتاح: 🔧 = مُولَّد (متجاهَل من git) · 🚧 = مجلد stub (لسه من غير ملفات dart، مخطَّط له في epic مفتوح). حالياً الحاجة الوحيدة المُولَّدة هي l10n.

```
lib/
├── main.dart                           # Bootstrap: configureDependencies() → runApp(OstaApp)
├── app.dart                            # OstaApp: MaterialApp.router + theme + l10n
│
├── core/                               # App-wide infrastructure (no feature knowledge)
│   ├── auth/
│   │   └── token_storage.dart          # flutter_secure_storage wrapper (access_token / refresh_token)
│   ├── config/
│   │   └── app_config.dart             # BASE_URL from --dart-define (default https://api.osta.dev/api/v1)
│   ├── constants/
│   │   └── app_images.dart             # AppImages.logo / fullLogo / mascot (assets/images/)
│   ├── di/
│   │   └── injection.dart              # configureDependencies() — MANUAL get_it registration, global getIt
│   ├── error/
│   │   └── failure.dart                # sealed Failure implements Exception (Network/Server/Unknown) — thrown, caught with try/catch
│   ├── l10n/                           # 🔧 GENERATED AppLocalizations (+ _ar, _en)
│   ├── network/
│   │   ├── api_client.dart             # Envelope-aware get/post/put/delete<T> → ApiResult<T>
│   │   ├── api_exception.dart          # sealed typed exceptions (422/401/403/404/429/5xx/transport)
│   │   ├── api_result.dart             # ApiResult<T> (data + PaginationMeta?)
│   │   ├── auth_events.dart            # broadcast onSessionExpired stream
│   │   ├── auth_interceptor.dart       # QueuedInterceptor: bearer attach + 401 refresh-retry-once
│   │   ├── dio_client.dart             # buildAppDio(): Dio (15s timeouts) + interceptors
│   │   ├── pagination_meta.dart        # plain Equatable + hand-written fromJson
│   │   ├── social_token_exchange.dart  # POST /auth/social/{provider} → store token pair
│   │   └── token_pair.dart             # parse dual tokens from response
│   ├── router/
│   │   └── app_router.dart             # GoRouter: /splash → /role. No shells yet.
│   └── theme/
│       ├── app_colors.dart             # ThemeExtension<AppColors>: brandGreen #0E7A3B, brandLime #B2D235
│       ├── app_theme.dart              # AppTheme.light() / dark() — Material 3, seeded from brandGreen
│       ├── app_tokens.dart             # AppSpacing / AppRadii / AppElevation
│       ├── app_typography.dart         # Cairo variable font, full TextTheme
│       └── theme_mode_controller.dart  # Cubit<ThemeMode>, persists 'theme_mode' (SharedPreferences)
│
├── features/                           # Feature-first modules
│   ├── auth/                           # 🚧 STUB — only data/models/auth_token_model.dart (plain Equatable dual-token);
│   │                                   #    domain/presentation empty. Epics: app #35, #36
│   ├── business/                       # 🚧 STUB dirs: bookings/ dashboard/ services/ team/ wallet/
│   │                                   #    (no dart files). Epics: app #54, #55, #56, #62, #58
│   ├── customer/                       # 🚧 STUB dirs: booking/ garage/ home/ map/ profile/ wallet/
│   │                                   #    (no dart files). Epics: app #44/#45/#47, #39/#50, #51, #41–#43, #40, #46
│   ├── notifications/                  # 🚧 STUB — data/domain/presentation dirs only. Epic: app #52
│   ├── role/
│   │   └── presentation/role_selection_page.dart   # Role picker (customer vs business)
│   ├── shop/                           # 🚧 STUB — data/domain/presentation dirs only. Epics: app #48, #49, #57
│   └── splash/
│       └── presentation/splash_page.dart           # 2s intro → role selection
│
├── l10n/
│   ├── app_en.arb                      # Localization source template (~6 keys today)
│   └── app_ar.arb                      # Arabic — default & RTL-first
│
└── shared/                             # Reusable presentation-layer code (used across features)
    ├── extensions/context_ext.dart     # context.l10n
    ├── formatters/app_formatters.dart  # EgpFormatter, NumberFormatter (ar_EG Arabic-Indic digits)
    └── ui/                             # AppButton, AppTopBar, AppBottomNavBar(+Item), AppCard,
                                        # AppTextField, AppBottomSheet, status_states.dart
                                        # (EmptyState/ErrorState/LoadingState)
```

The tree is intentionally flat and readable: no generated `*.g.dart` / `*.freezed.dart` / `injection.config.dart`, no build flavors, no dev gallery. Everything you see is hand-written Dart except the l10n output.

> ‏الشجرة مسطّحة وسهلة القراءة عن قصد: مفيش ملفات مُولَّدة زي `*.g.dart` أو `*.freezed.dart` أو `injection.config.dart`، ومفيش build flavors، ومفيش صفحة gallery للتطوير. كل اللي بتشوفه Dart مكتوب باليد ما عدا مخرجات الـ l10n.

## The three-layer feature convention / اتفاقية الطبقات الثلاث للميزة

Every feature under `lib/features/<feature>/` follows Clean Architecture with three layers — this is what the stub `data/` / `domain/` / `presentation/` folders anticipate. Models are plain `Equatable` classes with hand-written `fromJson`/`toJson`; there is no codegen (deferred — see [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md), Phases 1–3).

> ‏كل ميزة تحت `lib/features/<feature>/` بتتبع Clean Architecture بثلاث طبقات — وده اللي بتتوقعه مجلدات الـ stub زي `data/` و `domain/` و `presentation/`. الموديلات عبارة عن كلاسات `Equatable` بسيطة مع `fromJson`/`toJson` مكتوبين باليد؛ مفيش codegen (مؤجَّل — شوف [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)، المراحل 1–3).

| Layer | Depends on | Contains | Example (today) |
|---|---|---|---|
| `data/` | domain | models (plain `Equatable` + hand-written `fromJson`/`toJson`), remote data sources calling `ApiClient`, repository implementations that **throw** a `Failure` | `auth/data/models/auth_token_model.dart` |
| `domain/` | nothing | entities, repository interfaces, use cases that return `T` directly and throw `Failure` on error (no `Either`, no `Result<T>`) | none yet — 0 repositories/use cases at M0 |
| `presentation/` | domain | pages, widgets, BLoC/Cubit state management (`flutter_bloc`) using plain `try`/`catch` around calls | `role/presentation/role_selection_page.dart`, `splash/presentation/splash_page.dart` |

Dependency rule: **data → domain ← presentation**. Wiring is done with **manual** `get_it` registration in `core/di/injection.dart` — each service gets a hand-written `registerLazySingleton` line, no `injectable`, no `build_runner`.

> ‏قاعدة الاعتماد: **data → domain ← presentation**. الربط بيتم بتسجيل **يدوي** لـ `get_it` في `core/di/injection.dart` — كل خدمة بتاخد سطر `registerLazySingleton` مكتوب باليد، من غير `injectable` ومن غير `build_runner`.

## core vs features vs shared / core مقابل features مقابل shared

The three top-level folders under `lib/` separate plumbing, product, and reusable UI.

> ‏المجلدات الثلاثة الرئيسية تحت `lib/` بتفصل بين البنية التحتية والمنتج وواجهة الاستخدام القابلة لإعادة الاستخدام.

| Folder | What belongs there | What does NOT |
|---|---|---|
| `lib/core/` | Cross-cutting infrastructure with no feature knowledge: networking (`ApiClient`, interceptors), manual DI, `AppConfig` (single `BASE_URL`), error types (`Failure`), theme, router, token storage, generated l10n | Screens, feature models, feature blocs |
| `lib/features/` | One folder per feature area, each with `data/domain/presentation`; feature-specific pages, blocs, models, repositories | Anything two features both need — promote it to `shared/` or `core/` |
| `lib/shared/` | Reusable **presentation** code: `App*` widgets, formatters, extensions | Business logic, networking, feature state |

Rule of thumb: `core/` is plumbing, `features/` is product, `shared/` is reusable UI.

> ‏القاعدة العامة: `core/` هي البنية التحتية، و `features/` هي المنتج، و `shared/` هي واجهة الاستخدام القابلة لإعادة الاستخدام.

## Where everything else lives / أين يوجد كل شيء آخر

The table below maps the supporting files outside `lib/`.

> ‏الجدول التالي بيوضّح الملفات المساندة خارج `lib/`.

| Location | Contents |
|---|---|
| `test/` | 11 files mirroring `lib/`: `test/auth_token_model_test.dart`, `test/core/network/` (envelope, auth interceptor, social exchange + `fakes.dart` helpers), `test/core/theme/` (theme mode, WCAG contrast), `test/shared/ui/` (components, navigation), `test/shared/formatters/`, root `widget_test.dart` smoke. Tooling: `flutter_test`, `http_mock_adapter`, hand-written fakes (no mockito/mocktail). Golden tests (light/dark × RTL/LTR) planned per [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29). |
| `assets/images/` | Logo, full logo, mascot — referenced via `AppImages` (`core/constants/app_images.dart`), declared in `pubspec.yaml`. |
| `lib/l10n/` | ARB sources: `app_en.arb` (template) + `app_ar.arb`. Config in root `l10n.yaml` (`nullable-getter: false`). Output generated to `lib/core/l10n/` as `AppLocalizations`; accessed via `context.l10n`. |
| `.github/workflows/ci.yml` | CI: a single job **"format · analyze · test"** on ubuntu — `flutter pub get` → `flutter gen-l10n` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`. No `build_runner` step, no android/iOS build jobs (deferred — see [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md), Phase 4). Flutter pinned to 3.44.1. |
| `pubspec.yaml` | Dependencies, `generate: true` for l10n, `assets/images/`, Cairo variable font (wght 200–900). |

## Generated files (never edit, git-ignored) / الملفات المُولَّدة (لا تُعدَّل، متجاهَلة من git)

Only localization is generated now. Produced by `flutter gen-l10n` (also runs automatically on `flutter run` / `flutter build`); CI regenerates it on every run. There is **no `build_runner`** step anymore — no `*.g.dart`, no `*.freezed.dart`, no `*.config.dart` exist.

> ‏حالياً الحاجة الوحيدة المُولَّدة هي الترجمة (l10n)، وبتتولّد بواسطة `flutter gen-l10n` (اللي بيشتغل كمان تلقائياً مع `flutter run` / `flutter build`)، والـ CI بيعيد توليدها في كل تشغيلة. مافيش خطوة `build_runner` خالص — ومافيش أي `*.g.dart` ولا `*.freezed.dart` ولا `*.config.dart`.

- `lib/core/l10n/` — `AppLocalizations` output (the only generated code)

Model codegen (`freezed` / `json_serializable`), DI codegen (`injectable`), and functional-error types (`fpdart`) are deferred, with a phased reintroduction plan in [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

> ‏توليد الموديلات (`freezed` / `json_serializable`) وتوليد الـ DI (`injectable`) وأنواع الأخطاء الوظيفية (`fpdart`) كلها مؤجَّلة، مع خطة إعادة إدخال على مراحل في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

## Naming conventions / اتفاقيات التسمية

The conventions below keep files, classes, and branches predictable across the repo.

> ‏الاتفاقيات التالية بتخلّي الملفات والكلاسات والفروع متوقَّعة في كل المستودع.

- **Files**: `snake_case.dart`, named after the main class (`theme_mode_controller.dart` → `ThemeModeController`).
- **Shared widgets**: `App*` prefix — `AppButton`, `AppTopBar`, `AppBottomNavBar`, `AppCard`, `AppTextField`, `AppBottomSheet` (renamed from `Osta*` in commit 638c88a). Theme/token classes follow the same prefix: `AppColors`, `AppTheme`, `AppTypography`, `AppSpacing`, `AppRadii`, `AppElevation`, `AppImages`, `AppConfig`.
- **Branches**: `feat/<issue>-<slug>` off `develop`; PR base `develop` (`main` is release-only, via a `develop → main` release PR), description Arabic + English.
- **Lints**: `very_good_analysis` — CI fails on format or analyze violations.

## Related docs / مستندات ذات صلة

- [INDEX](../INDEX.md)
- Root [README](../../README.md) — setup and run instructions
- Deferred-tooling plan: [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)
- Master scope: [app #61 MVP delivery tracker](https://github.com/YoussefSalem582/Osta-App/issues/61)
