# 📊 OSTA — Current Project Status

> [INDEX](INDEX.md) > Current Status
>
> **Last Updated:** Jul 6, 2026 — **adopted a `develop`/`main` branching model**: feature branches now PR into a new long-lived **`develop`** integration branch, and **`main`** is release-only (advanced only by a `develop → main` PR + SemVer tag). Also Jul 6: the **first-run flow & 4-role split ([#32](https://github.com/YoussefSalem582/Osta-App/issues/32) · [PR #67](https://github.com/YoussefSalem582/Osta-App/pull/67))** was merged into `develop` (adapted to the post-[#69](https://github.com/YoussefSalem582/Osta-App/pull/69) plain-Dart conventions — manual `get_it` DI for the session/auth layer, dev `/gallery` route dropped). Earlier (Jul 5): **[`OSTA_plan.md`](../OSTA_plan.md) + [`OSTA_TODO.md`](../OSTA_TODO.md) added**: the master AI-agent execution plan for delivering the 31 open epics (11 owner mandates, offline-first + talker + skeletonizer + release/tag amendments, milestone-by-milestone build order) and its trackable zero-to-production checklist (per-phase release tags through the Phase-9 launch gate). Also vendored the official Dart/Flutter agent skills (14 curated, 7 excluded) into [`.claude/skills/`](../.claude/skills/README.md). Earlier the same day: documentation set created, then amended to match the deferral refactor ([`../docs/ROADMAP.md`](../docs/ROADMAP.md)) — `AGENTS.md` + `CLAUDE.md` shim at the root, and this `osta_readme_files/` tree (INDEX, guides, feature docs mirroring the GitHub epics, ADRs, reference docs, delivery plan). Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Version:** `1.0.0+1` — not released; no store presence yet.
> **Flutter:** SDK constraint `^3.12.1` (Dart); CI pins Flutter 3.44.1.
> **Status:** 🚧 **M0 foundation complete** ([#28](https://github.com/YoussefSalem582/Osta-App/issues/28) ✅ scaffolding+CI, [#29](https://github.com/YoussefSalem582/Osta-App/issues/29) ✅ design system, [#31](https://github.com/YoussefSalem582/Osta-App/issues/31) ✅ networking) | 🔄 [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) localization & RTL open | 📋 All feature epics open — see [DELIVERY_PLAN.md](reference/DELIVERY_PLAN.md)

## Table of Contents

- [Executive Summary](#-executive-summary)
- [Project Metrics](#-project-metrics)
- [What Exists Today](#-what-exists-today)
- [Feature Status vs Epics](#-feature-status-vs-epics)
- [Design System](#-design-system)
- [Testing](#-testing)
- [Technical Stack](#-technical-stack)
- [Backend Status](#-backend-status)
- [Git & Branch Status](#-git--branch-status)

---

## 🎯 Executive Summary / الملخص التنفيذي

OSTA (أُسطى) is an Egyptian car-services marketplace: customers discover service centers on a map, book slots, pay via Paymob (wallets/InstaPay) or cash, manage their garage, and shop a two-sided parts marketplace; businesses self-onboard (no verification), manage bookings/catalog/team, and get a realtime dashboard. **One Flutter app hosts every role** — customer + business shells now, solo-mechanic + tow-truck in Phase 2.

> ‏أُسطى سوق مصري لخدمات السيارات: العملاء يكتشفون مراكز الخدمة على الخريطة، يحجزون مواعيد، يدفعون عبر Paymob (محافظ/InstaPay) أو نقدًا، يديرون جراجهم، ويتسوقون في سوق قطع غيار ثنائي الجانب؛ والأنشطة التجارية تُسجّل نفسها ذاتيًا (بدون توثيق)، تدير الحجوزات والكتالوج والفريق، وتحصل على لوحة تحكم لحظية. **تطبيق Flutter واحد يستضيف كل الأدوار** — واجهات العميل والنشاط التجاري الآن، والميكانيكي الفردي وونش السحب في المرحلة الثانية.

The app is at **M0**: production-quality foundation (DI, config, networking, theming, l10n scaffolding, shared components, CI) with the feature surface still to be built. The **backend is MVP feature-complete except payments (M3.5)** — most app epics are `backend:ready`.

> ‏التطبيق في مرحلة **M0**: أساس بجودة الإنتاج (حقن التبعيات، الإعدادات، الشبكة، الثيمات، هيكلة الترجمة، المكوّنات المشتركة، الـ CI) مع سطح الميزات الذي ما زال يُبنى. **الباك-إند مكتمل الميزات لنسخة الـ MVP باستثناء المدفوعات (M3.5)** — ومعظم إبكات التطبيق `backend:ready`.

**Deliberately plain Dart:** the foundation was intentionally simplified so a team new to Flutter can be productive in readable code — plain `Equatable` models with hand-written `fromJson`/`toJson`, manual `get_it` registration, sealed `Failure` + `try`/`catch` for errors, and a single `BASE_URL`. Advanced tooling (codegen, functional error handling, build flavors, platform CI) is **deferred, not rejected** — with a phased plan in [`../docs/ROADMAP.md`](../docs/ROADMAP.md).

> ‏**دارت بسيطة عن قصد:** جرى تبسيط الأساس عمدًا حتى يقدر فريق جديد على Flutter أن ينتج بكود مقروء — موديلات `Equatable` عادية مع `fromJson`/`toJson` مكتوبة باليد، وتسجيل `get_it` يدوي، وأخطاء عبر `sealed Failure` و`try`/`catch`، و`BASE_URL` واحد. الأدوات المتقدمة (توليد الكود، معالجة الأخطاء الوظيفية، نكهات البناء، الـ CI متعدد المنصات) **مؤجّلة وليست مرفوضة** — بخطة مرحلية في [`../docs/ROADMAP.md`](../docs/ROADMAP.md).

### Key Highlights / أبرز النقاط

- ✅ **Envelope-aware networking** — `ApiClient` with typed exceptions, Sanctum dual-token, queued 401 refresh-retry-once, social token exchange
- ✅ **Design system** — Material 3 light/dark, brand green/lime, `AppColors` ThemeExtension, Cairo typography, token classes, persisted theme mode
- ✅ **8 shared UI components** + EGP/number formatters (Arabic-Indic digits)
- ✅ **Manual DI** via `get_it` (`configureDependencies()`); models are plain `Equatable` + hand-written `fromJson`/`toJson`
- ✅ **CI** — single "format · analyze · test" gate on ubuntu (Flutter 3.44.1)
- ✅ **Strict lints** (`very_good_analysis`), ~32 tests green
- 🚧 **2 screens implemented** (Splash, Role selection); all feature folders are stubs
- 📋 **31 open app epics** across M1–M7 + Shop + Home + Phase-2 backlog

> ‏أبرز ما أُنجز: شبكة واعية بالغلاف، نظام تصميم Material 3، ثمانية مكوّنات UI مشتركة ومنسّقات EGP/أرقام، حقن تبعيات يدوي عبر `get_it` وموديلات `Equatable` عادية، بوابة CI واحدة، فحوص لِنت صارمة و~32 اختبارًا خضراء، وشاشتان منفّذتان بينما باقي مجلدات الميزات لا تزال هياكل فارغة.

---

## 📈 Project Metrics / مقاييس المشروع

The table below summarizes the codebase footprint today.

> ‏يلخّص الجدول التالي حجم قاعدة الكود حاليًا.

| Metric | Count | Status |
|--------|-------|--------|
| Hand-written Dart files | 37 | ✅ |
| Screens/pages | 2 (SplashPage, RoleSelectionPage) | 🚧 |
| Blocs/Cubits | 1 (ThemeModeController) | 🚧 |
| Repositories / use cases | 0 | 📋 stubs await features |
| Shared UI components | 8 | ✅ |
| Formatters | 2 (EgpFormatter, NumberFormatter) | ✅ |
| Locales | 2 (ar default, en) — ~6 keys | 🚧 grows with features |
| Test files / cases | 11 / ~32 | ✅ green |
| Open app epics | 31 (+2 trackers) | 📋 |

---

## 🧱 What Exists Today / ما هو موجود اليوم

The map below groups the built modules by layer. No codegen is involved — only l10n is generated.

> ‏الخريطة التالية تجمّع الوحدات المبنية حسب الطبقة. لا يوجد توليد كود — فقط الـ l10n مُولّد.

| Area | Contents |
|------|----------|
| `core/network` | `ApiClient` (envelope → `ApiResult<T>`/`ApiException`), `AuthInterceptor` (401 refresh-retry-once), `TokenStorage`, `AuthEvents`, `SocialTokenExchange`, `PaginationMeta`, Dio + retry + redacted logger |
| `core/theme` | `AppColors` (ThemeExtension), `AppTheme.light()/dark()`, `AppTokens` (spacing/radii/elevation), `AppTypography` (Cairo), `ThemeModeController` |
| `core/di` | manual `get_it` registration in `injection.dart` (`configureDependencies()`, global `getIt`) — no annotations, no `build_runner` |
| `core/config` | `AppConfig` — single `BASE_URL` via `--dart-define` (no flavors) |
| `core/router` | GoRouter: `/splash`, `/role` |
| `core/error` | `sealed class Failure implements Exception` (`NetworkFailure`/`ServerFailure`/`UnknownFailure`); repositories throw, callers `try`/`catch` |
| `shared/ui` | AppButton, AppTopBar, AppBottomNavBar, AppCard, AppTextField, AppBottomSheet, Empty/Error/LoadingState |
| `features/` | splash + role implemented; auth (token model only), business/*, customer/*, shop, notifications = stub folders |

---

## 🧩 Feature Status vs Epics / حالة الميزات مقابل الإبكات

Full mirror with owners and backend state: [DELIVERY_PLAN.md](reference/DELIVERY_PLAN.md). Summary:

> ‏المرآة الكاملة مع المالكين وحالة الباك-إند في [DELIVERY_PLAN.md](reference/DELIVERY_PLAN.md). ملخص:

| Milestone | Epics | State |
|-----------|-------|-------|
| M0 Foundation | [#28](https://github.com/YoussefSalem582/Osta-App/issues/28) [#29](https://github.com/YoussefSalem582/Osta-App/issues/29) [#31](https://github.com/YoussefSalem582/Osta-App/issues/31) ✅ · [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) 🔄 | done except l10n/RTL runtime switch |
| M1 First-run, auth, account | #32–#40, #53 | 📋 open, backend ready |
| M2 Discovery (map/profile/filters) | #41–#43 | 📋 open, backend ready |
| M3 Booking + business bookings + team | #44, #45, #55, #62 | 📋 open, backend ready |
| M3.5 Payments (Paymob) | #46 | ⛔ blocked — backend #47/#48/#49 open |
| M4 Realtime + business dashboard | #47, #54 | 📋 open, backend ready |
| M5 Garage + business catalog | #50, #56 | 📋 open, backend ready |
| M7 Notifications + FCM | #52 | 📋 open, backend ready |
| Home / Shop | #51, #48, #57 (+#49 P2) | 📋 open, backend ready |
| Phase 2 | #58, #59, #60 | ⛔ backend blocked |

---

## 🎨 Design System / نظام التصميم

The design system is fully wired and verified by tests; there is no dev gallery route.

> ‏نظام التصميم موصول بالكامل ومُتحقّق منه بالاختبارات؛ لا يوجد مسار جاليري للمطوّرين.

- Brand: green `#0E7A3B` seed + lime `#B2D235`; semantic accent/success/warning pairs (light + dark) via `ThemeExtension`
- Tokens: spacing 4/8/16/24/32 · radii 8/12/16/pill · elevation 0/1/3/6
- Typography: Cairo variable font (weights via `FontVariation` — no synthetic bold)
- Theme mode persisted (`theme_mode` in SharedPreferences); WCAG contrast test in suite

## 🧪 Testing / الاختبارات

11 files / ~32 cases cover the foundation: network (envelope parsing, error mapping, 401 refresh, queued refresh, token rotation, social exchange), theme (contrast, persistence), shared UI (components, navigation, badges), formatters (EGP + Arabic/Latin digits), smoke. Tooling: `flutter_test`, `http_mock_adapter`, hand-rolled fakes — no mockito/mocktail. Conventions for feature work (golden light/dark × RTL/LTR etc.): [guides/10_testing.md](guides/10_testing.md).

> ‏تغطّي 11 ملفًا و~32 حالة الأساس: الشبكة (تحليل الغلاف، تعيين الأخطاء، تجديد 401، التجديد المصفوف، تدوير الرمز، التبادل الاجتماعي)، الثيم (التباين، الاستمرارية)، الـ UI المشتركة (المكوّنات، التنقّل، الشارات)، المنسّقات (EGP وأرقام عربية/لاتينية)، واختبار دخاني. الأدوات: `flutter_test` و`http_mock_adapter` وفيكات مكتوبة باليد — بدون mockito/mocktail.

## 🛠 Technical Stack / المكدّس التقني

Plain Dart, no codegen. Flutter · `flutter_bloc` · `get_it` (manual registration) · `equatable` (plain models + hand-written `fromJson`/`toJson`) · `go_router` 17 · `dio` 5 + `dio_smart_retry` + `pretty_dio_logger` · `flutter_secure_storage` · `shared_preferences` · `cached_network_image` · `intl`/ARB l10n · `very_good_analysis` · GitHub Actions CI. Advanced tooling (`freezed`/`json_serializable`/`injectable`, `fpdart`) is deferred — see [`../docs/ROADMAP.md`](../docs/ROADMAP.md).

> ‏دارت عادية بدون توليد كود. Flutter مع `flutter_bloc` و`get_it` (تسجيل يدوي) و`equatable` (موديلات عادية مع `fromJson`/`toJson` باليد) و`go_router` 17 و`dio` 5 (+`dio_smart_retry` +`pretty_dio_logger`) و`flutter_secure_storage` و`shared_preferences` و`cached_network_image` وترجمة `intl`/ARB و`very_good_analysis` و GitHub Actions. الأدوات المتقدمة (`freezed`/`json_serializable`/`injectable` و`fpdart`) مؤجّلة — راجع [`../docs/ROADMAP.md`](../docs/ROADMAP.md).

Planned per epics: google_maps_flutter, geolocator, google_sign_in, sign_in_with_apple, webview_flutter (Paymob), firebase_messaging, pusher_channels_flutter (Reverb), image_picker, table_calendar, carousel_slider, and more — see feature docs.

> ‏مخطَّط حسب الإبكات: google_maps_flutter وgeolocator وgoogle_sign_in وsign_in_with_apple وwebview_flutter (Paymob) وfirebase_messaging وpusher_channels_flutter (Reverb) وimage_picker وtable_calendar وcarousel_slider وغيرها — راجع مستندات الميزات.

## 🔌 Backend Status / حالة الباك-إند

Laravel 12 · `/api/v1` · MVP **feature-complete except M3.5 payments** ([#47](https://github.com/YoussefSalem582/osta_backend/issues/47), [#48](https://github.com/YoussefSalem582/osta_backend/issues/48), [#49](https://github.com/YoussefSalem582/osta_backend/issues/49) open). Catalogue + app-status per endpoint: [guides/09_api_endpoints.md](guides/09_api_endpoints.md); cross-repo audit: [guides/11_backend_feature_connectivity.md](guides/11_backend_feature_connectivity.md).

> ‏Laravel 12 على `/api/v1`، مكتمل الميزات لنسخة الـ MVP **باستثناء مدفوعات M3.5** ([#47](https://github.com/YoussefSalem582/osta_backend/issues/47) و[#48](https://github.com/YoussefSalem582/osta_backend/issues/48) و[#49](https://github.com/YoussefSalem582/osta_backend/issues/49) مفتوحة). الكتالوج وحالة كل نقطة نهاية في [guides/09_api_endpoints.md](guides/09_api_endpoints.md)؛ والتدقيق عبر المستودعات في [guides/11_backend_feature_connectivity.md](guides/11_backend_feature_connectivity.md).

## 🌿 Git & Branch Status / حالة Git والفروع

- Branching model: **`develop`** is the integration branch (all feature work targets it); **`main`** is the protected release branch, advanced only by a `develop → main` release PR + tag. (origin also hosts `design-assets`, which carries `mockups/*.png`.)
- Merged PRs: [#63](https://github.com/YoussefSalem582/Osta-App/pull/63) scaffolding+CI · [#64](https://github.com/YoussefSalem582/Osta-App/pull/64) networking · [#65](https://github.com/YoussefSalem582/Osta-App/pull/65) design system · [#66](https://github.com/YoussefSalem582/Osta-App/pull/66) nav bars
- Branch convention: `feat/<issue>-<slug>` off `develop` (hand-written kebab-case — never tool-generated names like `claude/...`); PR base `develop`; bilingual descriptions

> ‏نموذج الفروع: **`develop`** فرع التكامل (كل عمل الميزات يستهدفه)، و**`main`** فرع الإصدار المحميّ الذي لا يتقدّم إلا بطلب دمج `develop → main` مع وسم إصدار. (يستضيف origin أيضًا فرع `design-assets` الذي يحمل `mockups/*.png`.) عُرف الفروع: `feat/<issue>-<slug>` من `develop`، وقاعدة الـ PR هي `develop`، بوصف ثنائي اللغة.
