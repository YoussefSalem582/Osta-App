# OSTA App — Agent Instructions / تعليمات الوكلاء

<!-- canonical-banner:start -->
> **Canonical source of truth for AI agents.**
> This file is the single authoritative guide for every agent (Claude Code, Cursor, Codex CLI, Copilot, Gemini, generic). Per-tool instruction files are **thin shims** that add tool-specific runtime rules and reference this document for everything else — do **not** duplicate content from this file into them.
>
> ‏المرجع الأساسي الموحّد لوكلاء الذكاء الاصطناعي. هذا الملفّ هو الدليل الوحيد المعتمد لكل وكيل؛ وملفّات الأدوات الأخرى مجرّد طبقات رفيعة تضيف قواعد تشغيل خاصة بالأداة وتُحيل إلى هذا المستند. لا تُكرّر محتوى هذا الملفّ فيها.
>
> | Tool | Shim file | What lives only in the shim |
> |------|-----------|------------------------------|
> | Claude Code | [CLAUDE.md](CLAUDE.md) | Tool-use rules, response style, approved commands |
>
> **If you edit project conventions, edit this file.** Shims should never grow back into full mirrors.
<!-- canonical-banner:end -->

## Table of Contents

- [Project Overview](#project-overview--نظرة-عامة)
- [Current Stage — Read This First](#current-stage--read-this-first--المرحلة-الحالية--اقرأ-هذا-أولًا)
- [Plain-Dart, No Codegen](#plain-dart-no-codegen--دارت-بسيط-بلا-توليد-كود)
- [Key Entry Points](#key-entry-points--نقاط-الدخول-الرئيسية)
- [Feature Architecture](#feature-architecture--معمارية-الميزات)
- [Design Tokens — Never Hardcode](#design-tokens--never-hardcode--رموز-التصميم--لا-تُثبّت-القيم-يدويًا)
- [State Management (BLoC)](#state-management-bloc--إدارة-الحالة)
- [API Integration](#api-integration--تكامل-الـ-api)
- [Error Handling](#error-handling--معالجة-الأخطاء)
- [DI Registration (manual get_it)](#di-registration-manual-get_it--تسجيل-التبعيات-يدوي)
- [Localization](#localization--الترجمة)
- [Security](#security--الأمان)
- [Shared UI Components](#shared-ui-components--مكوّنات-الواجهة-المشتركة)
- [Naming Conventions](#naming-conventions--اصطلاحات-التسمية)
- [Git & PRs](#git--prs--الالتزامات-والطلبات)
- [Mandatory Documentation](#mandatory-documentation-after-every-change--التوثيق-الإلزامي)
- [Approved Commands](#approved-commands--الأوامر-المعتمدة)
- [Issue Trackers & Roadmap](#issue-trackers--roadmap--متتبّعات-القضايا-وخارطة-الطريق)

## Project Overview / نظرة عامة

**OSTA · أُسطى** — Egyptian car-services marketplace. **One Flutter app** (Android + iOS) hosts every role flow: **CUSTOMER** and **BUSINESS** shells now, SOLO-MECHANIC and TOW-TRUCK as "coming soon" (Phase 2). No monorepo, no Melos, no guest mode.

> ‏**أُسطى** — سوق خدمات سيارات مصري. تطبيق Flutter **واحد** (أندرويد + iOS) يستضيف كل تدفّقات الأدوار: شِلّ **العميل** وشِلّ **النشاط التجاري** الآن، والميكانيكي المستقلّ والونش لاحقًا (المرحلة الثانية). لا مستودع أحادي، ولا Melos، ولا وضع ضيف.

- **Architecture**: Clean Architecture (data → domain ← presentation) + BLoC
- **State**: `flutter_bloc` — Bloc for features, Cubit for simple state
- **DI**: `get_it` — **manual** registration in `lib/core/di/injection.dart` (no codegen)
- **Models**: plain `Equatable` classes + hand-written `fromJson`/`toJson` (no codegen)
- **Errors**: `sealed class Failure implements Exception` + plain `try`/`catch` (`lib/core/error/failure.dart`)
- **Routing**: `go_router` — `/splash → /role`; role-aware shells planned (Consumer `/home`, Provider `/dashboard`) per [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32)/[#34](https://github.com/YoussefSalem582/Osta-App/issues/34)
- **Networking**: Dio behind envelope-aware `ApiClient` (`lib/core/network/`) — typed `ApiException`s, `ApiResult<T>` + `PaginationMeta`, `dio_smart_retry`, redacted `pretty_dio_logger`
- **Auth**: Laravel Sanctum dual token, `AuthInterceptor` 401 refresh-retry-once (QueuedInterceptor), `SocialTokenExchange` for Google/Apple (server-side Socialite — **no firebase_auth**)
- **Storage**: `TokenStorage` (`flutter_secure_storage`) for tokens; `SharedPreferences` for preferences
- **Config**: single `BASE_URL` via `--dart-define` → `AppConfig` — no `.env`, no flavors
- **Localization**: ARB (English template + Arabic), **Arabic default, RTL-first**, `context.l10n`
- **Theme**: Material 3, brand green `#0E7A3B` + lime `#B2D235`, `AppColors` ThemeExtension, Cairo variable font, persisted light/dark (`ThemeModeController`)
- **Backend**: Laravel 12 at `/api/v1` — envelope `{success, data, meta}` / `{success:false, error:{code,message,details}}`; EGP; Egypt `+20` phones; Paymob; Reverb; FCM
- **Lints**: `very_good_analysis`
- **CI**: GitHub Actions — one `format · analyze · test` job

## Current Stage — Read This First / المرحلة الحالية — اقرأ هذا أولًا

The app is at **M0 (foundation)**: core (manual DI, config, network, theme, router, l10n) and 8 shared UI components are real and tested; `lib/features/` is mostly **stub folders** (only `splash` and `role` have pages, plus one auth model). Every feature is specified by an open GitHub epic.

> ‏التطبيق في مرحلة **M0 (الأساس)**: النواة (حقن تبعيات يدوي، إعدادات، شبكة، ثيم، موجّه، ترجمة) وثمانية مكوّنات واجهة مشتركة حقيقية ومُختبَرة؛ ومجلّد `lib/features/` غالبه **مجلّدات هيكلية فارغة** (شاشتا `splash` و`role` فقط، ونموذج مصادقة واحد). كل ميزة مُحدّدة في epic مفتوح على GitHub.

**Before building anything**, read the matching epic and its feature doc in [`osta_readme_files/features/`](osta_readme_files/features/README.md), and check [`osta_readme_files/reference/DELIVERY_PLAN.md`](osta_readme_files/reference/DELIVERY_PLAN.md) for milestone order and owners.

## Plain-Dart, No Codegen / دارت بسيط بلا توليد كود

The codebase was **intentionally simplified** so a team new to Flutter can be productive in plain, readable Dart. Advanced tooling (`freezed`, `json_serializable`, `injectable`, `build_runner`, `fpdart`, build flavors) was **deferred, not rejected** — a phased reintroduction plan lives in [`docs/ROADMAP.md`](docs/ROADMAP.md).

> ‏جرى **تبسيط الشيفرة عمدًا** ليكون فريق جديد على Flutter مُنتِجًا بدارت بسيطة وقابلة للقراءة. أُجِّلت الأدوات المتقدّمة (freezed، json_serializable، injectable، build_runner، fpdart، نكهات البناء) ولم تُرفَض — وخطّة إعادة إدخالها على مراحل في [`docs/ROADMAP.md`](docs/ROADMAP.md).

**There is no `build_runner` step.** Models are hand-written `Equatable` classes, DI is hand-wired `get_it`, errors are a `sealed Failure` thrown with `try/catch`. The **only** generated code is localizations (`lib/core/l10n/`, git-ignored, via `flutter gen-l10n`). Do not add codegen packages without following the ROADMAP phase.

## Key Entry Points / نقاط الدخول الرئيسية

| File | Purpose |
|------|---------|
| `lib/main.dart` | Boot: `configureDependencies()` → `runApp(OstaApp)` |
| `lib/app.dart` | `OstaApp` — `MaterialApp.router` + theme + l10n |
| `lib/core/di/injection.dart` | Manual `get_it` registration |
| `lib/core/router/app_router.dart` | GoRouter routes (paths are `static const path` on page widgets) |
| `lib/core/network/api_client.dart` | All HTTP goes through this |
| `lib/core/config/app_config.dart` | `BASE_URL` dart-define |
| `lib/core/theme/` | Design tokens + themes |
| `lib/shared/ui/` | Reusable App* components |

## Feature Architecture / معمارية الميزات

Every feature lives under `lib/features/<name>/` (customer/business sub-areas nested, e.g. `features/customer/garage/`) with three layers:

> ‏كل ميزة داخل `lib/features/<name>/` (مناطق العميل/النشاط متداخلة) بثلاث طبقات:

```text
features/<name>/
├── data/          # datasources (ApiClient) · models (Equatable + fromJson/toJson) · repositories
├── domain/        # entities (Equatable) · repository contracts · usecases
└── presentation/  # bloc / pages / widgets
```

**Dependency rule**: Presentation → Domain ← Data. Domain has zero Flutter imports. The **auth feature ([app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)) will be the canonical reference** — match it once it lands. Until then follow [`osta_readme_files/guides/03_how_to_add_new_feature.md`](osta_readme_files/guides/03_how_to_add_new_feature.md).

> ‏**قاعدة الاعتماد**: العرض ← النطاق ← البيانات، والنطاق خالٍ من استيرادات Flutter. ميزة المصادقة ستكون المرجع القياسي عند إنجازها.

## Design Tokens — Never Hardcode / رموز التصميم — لا تُثبّت القيم يدويًا

| Category | Use | Never |
|----------|-----|-------|
| Colors | `context.appColors.accent`, `Theme.of(context).colorScheme.*` | `Color(0xFF...)`, `Colors.green` |
| Spacing | `AppSpacing.md` (xs=4, sm=8, md=16, lg=24, xl=32) | raw `16.0` |
| Radius | `AppRadii.md` (sm=8, md=12, lg=16, pill=999) | raw `BorderRadius.circular(12)` |
| Elevation | `AppElevation.low` (0/1/3/6) | raw numbers |
| Text | `Theme.of(context).textTheme.*` (Cairo via `AppTypography`) | inline `TextStyle(...)` |
| Assets | `AppImages.logo` / `.fullLogo` / `.mascot` | `'assets/images/...'` |

Tokens live in `lib/core/theme/app_tokens.dart` and `app_colors.dart`. New colors need light **and** dark values plus the contrast test (`test/core/theme/contrast_test.dart`).

## State Management (BLoC) / إدارة الحالة

Bloc for feature flows, Cubit for simple state (existing example: `ThemeModeController extends Cubit<ThemeMode>`). States/events are `Equatable` value types.

> ‏Bloc لتدفّقات الميزات، وCubit للحالات البسيطة. الحالات والأحداث أنواع قيمة تعتمد `Equatable`.

## API Integration / تكامل الـ API

1. All HTTP through `ApiClient` (`get/post/put/delete<T>`) — never a raw `Dio` call.
2. Success → `ApiResult<T>` (with `PaginationMeta?`); failure → typed `ApiException` (`ValidationException` 422 + `fieldErrors`, `Unauthenticated` 401, `Forbidden` 403, `NotFound` 404, `RateLimit` 429, `Server` 5xx, `Network`).
3. 401 is handled by `AuthInterceptor` (single refresh-retry); a failed refresh emits on `AuthEvents.onSessionExpired` — route to login from there.
4. Bad login credentials return **422, not 401** (backend contract).
5. Catalogue + app status: [`osta_readme_files/guides/09_api_endpoints.md`](osta_readme_files/guides/09_api_endpoints.md).

## Error Handling / معالجة الأخطاء

Errors use a native `sealed class Failure implements Exception` (`lib/core/error/failure.dart`: `NetworkFailure`, `ServerFailure`, `UnknownFailure`) — **thrown and caught with plain `try`/`catch`**. There is **no `fpdart`, no `Either`, no `Result<T>`** (deferred, [`docs/ROADMAP.md`](docs/ROADMAP.md) Phase 5). A repository catches an `ApiException` and throws the matching `Failure`; the bloc catches `Failure` and emits an error state.

> ‏تعتمد الأخطاء صنفًا `sealed class Failure implements Exception` يُرمى ويُلتقط عبر `try`/`catch` عادي. لا يوجد `fpdart` ولا `Either` ولا `Result<T>` (مؤجّل، المرحلة 5 في الخارطة). المستودع يلتقط `ApiException` ويرمي `Failure` المناسب، والـ bloc يلتقطه ويُصدر حالة خطأ.

## DI Registration (manual get_it) / تسجيل التبعيات (يدوي)

Add a hand-written line to `configureDependencies()` in `lib/core/di/injection.dart` — no annotations, no `build_runner`:

```dart
getIt.registerLazySingleton<GarageRepository>(() => GarageRepositoryImpl(getIt()));
getIt.registerFactory(() => GarageBloc(getIt()));
```

## Localization / الترجمة

- All user-facing strings: `context.l10n.someKey` — zero hardcoded strings.
- Add keys to **both** `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`, then `flutter gen-l10n`.
- Arabic is the default locale; layouts must be RTL-safe. Money/numbers via `EgpFormatter`/`NumberFormatter` (Arabic-Indic digits in `ar_EG`).

> ‏كل النصوص الظاهرة للمستخدم عبر `context.l10n`؛ أضِف المفاتيح إلى ملفّي ARB معًا ثم شغّل `flutter gen-l10n`. العربية هي اللغة الافتراضية والتخطيط يجب أن يدعم RTL. المبالغ والأرقام عبر `EgpFormatter`/`NumberFormatter`.

## Security / الأمان

- **Never hardcode** URLs, tokens, keys. Runtime config comes from `--dart-define` (`BASE_URL`) through `AppConfig` only.
- Auth tokens go **only** in `TokenStorage` (flutter_secure_storage) — never `SharedPreferences`.
- Logging is redacted (`PrettyDioLogger` skips auth headers/bodies).
- Payments use Paymob **hosted checkout** (WebView) — no card data touches the app.

## Shared UI Components / مكوّنات الواجهة المشتركة

Check `lib/shared/ui/` before building new UI:

**AppButton** · **AppTopBar** (RTL-safe) · **AppBottomNavBar** / `AppBottomNavItem` · **AppCard** · **AppTextField** · **AppBottomSheet** · **EmptyState** / **ErrorState** / **LoadingState**

Plus `EgpFormatter` / `NumberFormatter` (`shared/formatters/`) and `context.l10n` (`shared/extensions/`). (The dev component gallery route was removed — see [`docs/ROADMAP.md`](docs/ROADMAP.md).)

## Naming Conventions / اصطلاحات التسمية

| Item | Convention |
|------|-----------|
| Files | `snake_case.dart` |
| Classes | `PascalCase`; shared widgets prefixed `App*` |
| Variables/functions | `camelCase` |
| Private members | `_prefixed` |
| Branches | `<type>/<issue>-<slug>` off `develop`, hand-written kebab-case (e.g. `feat/44-booking-funnel`, `fix/auth-401-loop`) — never tool-generated names like `claude/...` |

## Git & PRs / الالتزامات والطلبات

**Branching model — `develop` integrates, `main` releases:**

- **`develop`** is the default integration branch: all day-to-day work branches off it and merges back into it. **`main`** is the release branch — protected, always releasable, and updated **only** by a release PR from `develop`.
- Branch off **`develop`** as `feat/<issue>-<slug>` (or `fix/`, `refactor/`, `test/`, `docs/`, `chore/` + `<scope>`); **PR base is `develop`**. Merge into `develop` once CI is green and the PR is reviewed.
- **Release / version:** when a milestone or version is complete on `develop`, open a `develop → main` PR; on merge, tag the release on `main` (`v0.<n>.0` per milestone, `v1.0.0` = MVP). **Never** PR a feature branch straight to `main`.
- **Hotfix (exception):** an urgent production fix may branch off `main` as `fix/<issue>-<slug>` and PR back to `main`, then be merged into `develop` so the fix isn't lost.
- Branch names are **hand-written, descriptive, lowercase kebab-case** (e.g. `feat/35-auth-email-password`, `fix/auth-401-loop`, `chore/talker-logging`). **Never** keep an auto-generated/tool-default branch name (random suffixes, `claude/...`, `cursor/...`, `codex/...`) — rename it before opening the PR: `git branch -m <type>/<issue>-<slug>`.
- PR descriptions are **bilingual (Arabic + English)**.
- Plain commit messages (conventional-commit style: `feat(ui): …`). No AI/agent attribution trailers.
- Never commit generated l10n (`lib/core/l10n/`).

> ‏نموذج الفروع — **`develop`** فرع التكامل الافتراضي: كل العمل اليومي يتفرّع منه ويُدمج فيه، و**`main`** فرع الإصدار المحميّ الذي لا يُحدَّث إلا بطلب دمج من `develop`. تفرَّع من `develop` بصيغة `<type>/<issue>-<slug>` وقاعدة الـ PR هي `develop`؛ وعند اكتمال نسخة أو مرحلة افتح طلب دمج `develop → main` ثم ضع وسم الإصدار على `main` (`v0.<n>.0` لكل مرحلة، و`v1.0.0` عند اكتمال الـ MVP). لا تفتح PR لفرع ميزة مباشرةً على `main`. وللإصلاح العاجل فقط: تفرّع من `main` وأعِد الدمج إليه ثم إلى `develop`.

## Mandatory Documentation (after every change) / التوثيق الإلزامي

1. [`CHANGELOG.md`](CHANGELOG.md) — entry under Unreleased
2. [`osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`](osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md) — dated entry at top
3. [`osta_readme_files/CURRENT_STATUS.md`](osta_readme_files/CURRENT_STATUS.md) — update status + metrics
4. The relevant feature doc when a feature lands or its scope changes

## Approved Commands / الأوامر المعتمدة

Safe to run autonomously. Anything else — `git push`, dependency upgrades, store/signing — needs explicit permission.

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install packages |
| `flutter gen-l10n` | Regenerate localizations |
| `flutter analyze` | Static analysis (very_good_analysis) |
| `flutter test` | Run the test suite |
| `dart format .` | Format (CI enforces) |

> **Note**: there is no `build_runner` command — the project uses no codegen (only l10n generation, which runs automatically on `flutter run`/`build`). See [`docs/ROADMAP.md`](docs/ROADMAP.md).

## Issue Trackers & Roadmap / متتبّعات القضايا وخارطة الطريق

- App epics: <https://github.com/YoussefSalem582/Osta-App/issues> — tracker [#61](https://github.com/YoussefSalem582/Osta-App/issues/61)
- Backend epics: <https://github.com/YoussefSalem582/osta_backend/issues> — tracker [#63](https://github.com/YoussefSalem582/osta_backend/issues/63)
- Deferred tooling + phased plan: [`docs/ROADMAP.md`](docs/ROADMAP.md)
- Milestones, owners, cross-repo mirror: [`osta_readme_files/reference/DELIVERY_PLAN.md`](osta_readme_files/reference/DELIVERY_PLAN.md)
- Design mockups: `design-assets` branch (`mockups/*.png`)
