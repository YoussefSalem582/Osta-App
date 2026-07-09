# 📊 OSTA — Current Project Status

> [INDEX](INDEX.md) > Current Status
>
> **Last Updated:** Jul 10, 2026 — **Both CI workflows green; 27 dead doc links found and fixed**: `format · analyze · test` failed on every run (three `my_bookings` widgets missing a trailing comma after `super.key`, so `dart format --set-exit-if-changed` exited 1 first). The whole `docs` workflow had never passed either: `markdownlint-cli2` ran with **no config**, so its default 80-char limit reported 4304 errors across 101 files (the Arabic mirror paragraphs are one long line by design), and `link-check` passed `--exclude-mail`, which current `lychee` rejects outright. Added `.markdownlint.jsonc` disabling only the six rules this repo deliberately violates, auto-fixed the mechanical ones, excluded the vendored `.claude/skills/`, and dropped the bad flag. With the lint finally running, `MD051` exposed a real bug — **all 18 TOC links in `AGENTS.md` and 9 here were dead**, since bilingual headings slug to `#project-overview--نظرة-عامة`, not `#project-overview`. Repointed all 27 with `github-slugger` (a hand-rolled one dropped Arabic diacritics and would have produced fresh dead links). markdownlint: **0 errors**. Analyze clean, 127 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 10, 2026 — **README rebuilt around the brand assets**: the root `README.md` had no imagery. Added a centered brand header and a **Brand assets** section — a preview table mapping each `assets/images/` file to its `AppImages` constant and its verified usage, the `#0E7A3B` brand green, the manual icon/splash regeneration commands, and a note that `logo.png`/`full_logo.png` are white-on-transparent (they vanish on light backgrounds unless tinted, so `app_icon.png` is the safe pick — including for the GitHub header). Corrected three stale claims: `BASE_URL` defaults to the **live** backend (not a dev API), the first-run flow is `splash → language → role → onboarding → auth-choose → auth → shell`, and the `lib/` tree now matches the real `core/` + `features/` folders. Added a Documentation table and badges. All links and image paths resolve. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 9, 2026 — **Customer shell no longer draws two app bars**: a folder reorg re-wrapped `MyBookingsScreen`/`ProfileScreen` in their own `Scaffold` + `AppTopBar`, which the shell then embedded inside its own `Scaffold` (two app bars on the Bookings and More tabs), and left two files declaring `MyBookingsScreen` (ambiguous-import compile error — the stale `presentation/` copy was deleted). Split both along the existing `LiveBookingScreen`/`BookingView` pattern: routed `MyBookingsScreen` (`/my-bookings`) and `ProfileScreen` (`/profile`) keep the app bar; the new scaffold-less `MyBookingsView`/`ProfileView` are what the shell embeds. Added a widget test asserting one `AppBar` + one `AppBottomNavBar` per tab. Analyze clean, 127 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 9, 2026 — **Booking flow fixed (list → detail)**: the customer Bookings tab was showing `BookingView` (the live-status detail) directly, leaving the built bookings list orphaned. The tab now shows the upcoming/past list (`MyBookingsView`) and tapping a card `push`es `/booking-status` (`LiveBookingScreen` detail). Analyze clean, 127 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 9, 2026 — **Business shell embeds the business screens as its tabs (one shared nav, black center FAB)**: the `business` landing reuses the shared `RoleShell` UI (black center action vs the customer's green); its Catalog + Store tabs now render `BusinessServicesPage`/`BusinessShopPage` **as tab bodies**. Both pages were stripped of their own `Scaffold` + calendar FAB + 5-tab bottom nav (the shell owns the bar now); they are embedded, not navigated to, so neither has a standalone route. Added optional `centerColor` to `AppBottomNavBar`/`RoleShell` (defaults to green). Dashboard/More stay placeholders. Analyze clean, 127 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 9, 2026 — **Customer + business shells now render real screens (not placeholders)**: a bad `RoleShell` merge had commented out the `pages`/`IndexedStack` path, so `CustomerShellPage`'s `HomePage` was silently ignored and the Home tab showed an `EmptyState`. Moved each screen onto its tab `body`, dropped the dead `pages` mechanism, and fixed an 11px `RenderFlex` overflow in the merged `CenterCard`. The `business` role was separately landing in an empty 3-tab placeholder — see the business-shell entry above. Analyze clean, 127 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 9, 2026 — **Merged Home screen (PR #85) integrated + merge fallout fixed**: PR #85 left a duplicate `splash_page` import, an unreachable `HomeBottomNav` at `/home` (the guard never allows it), and an identical dead duplicate of `home_bottom_nav.dart`. Fixed by dropping the built `HomePage` into `CustomerShellPage`'s Home tab (replacing the placeholder); `/home` now routes to `HomePage` itself and is allowed by the guard (`HomePage.path` → `AppRoutes.home`). Deleted both `HomeBottomNav` files (worse shell: hardcoded AR labels, `'data'` tabs) and cleaned stray conflict markers in `customer_shell_page.dart`. Analyze clean, 127 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 9, 2026 — **Business onboarding wizard now shown after business registration**: the built wizard (`ProviderOnboardingPage` → `BusinessIdentityPage` → `BusinessCatalogPage`) was routed but unreachable — a business registrant dropped straight into the `/business` shell. Added an in-memory `SessionState.businessOnboarded` gate + guard branch that forces an authenticated `business` user through the wizard before the shell; the catalog's Activate calls `SessionController.completeBusinessOnboarding()` to release the gate. In-memory (re-runs each launch until finished). Customer flow unchanged. Analyze clean, 126 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 9, 2026 — **Routed the built role-selection screen + cleared all analyzer lints**: the finished `RoleSelectionPage` was unrouted with empty `onTap` stubs; wired its customer/business cards to `SessionController.chooseRole`, pointed `/role` at it, deleted the superseded `RoleChooserPage`, and updated `test/widget_test.dart` to the new strings. Also cleared the remaining 18 `flutter analyze` lints (dead import, `profile_Item.dart` → `profile_item.dart` rename, sorted `pubspec.yaml` deps, wrapped long doc comments, redundant `AppCard` padding, `dart format`). Analyze clean, 123 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **Business Services, Shop, and ProviderShell screens added**: implemented `BusinessServicesPage` (with segmented toggle, `ServicePricingToggleCard`, and `DiscountPromotionBanner`), `BusinessShopPage` (with status-badged `ShopProductCard`), and `ProviderShell` (bottom navigation with floating center calendar button). Aligned 100% with mockups and registered `/provider-shell` in `AppRouter`. Earlier: Jul 7, 2026 — **Business onboarding screens, widgets & routing added**: implemented `ProviderOnboardingPage`, `BusinessIdentityPage`, `BusinessCatalogPage`. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).

> **Last Updated:** Jul 9, 2026 — **`BASE_URL` pointed at the live backend**: the deployed backend is now at **`https://osta.technology92.com`** (admin `/admin`, API `/api/v1` — verified live via `GET /api/v1/auth/check-username`). Replaced the dead placeholder `api.osta.dev` with `osta.technology92.com` across the repo — the `AppConfig.baseUrl` compile default plus every run-command / doc reference — so `flutter run` hits a working backend by default (`--dart-define=BASE_URL=…` still overrides). Analyze clean. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 7, 2026 — **Business onboarding screens, widgets & routing added**: implemented `ProviderOnboardingPage`, `BusinessIdentityPage`, `BusinessCatalogPage`, 8 reusable widgets in `lib/features/business/onboarding/presentation/`, aligned `BusinessIdentityPage` 100% with exact user mockup, and registered declarative GoRouter routes in `AppRouter`. Earlier: Jul 7, 2026 — **Role selection screen widgets & RTL alignment added**: implemented `RoleCard`, `ComingSoonBadge`, and `InfoBanner` in `lib/features/role/presentation/widgets/`, enhanced `AppCard` with optional styling properties, fixed `AppColors.gray` syntax, and aligned headers to start for RTL support. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **register avatar upload wired**: the register profile-photo control is now live — tapping opens the system gallery picker (`image_picker`; PHPicker/Android Photo Picker → no permission string or native config), previews the image in the ring, and on submit uploads it to **`POST /api/v1/me/avatar`** (multipart `avatar`, jpeg `maxWidth:1024`/`quality:85`, under the 5 MB server cap) via new `AuthRepository.uploadAvatar(filePath:)` (Dio `FormData`, no `ApiClient` change). Runs after register stores the token, before `onAuthenticated` navigates, **best-effort** (a failed photo never blocks registration). `RegisterSubmitted` gained `photoPath`; added `image_picker: ^1.1.2`; 2 new bloc tests + 4 fakes updated. Analyze clean, 123 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **register screen redesign**: `RegisterPage` reworked to the new design — a tappable **profile-photo placeholder** (dashed brand ring + person glyph + camera badge, prompt `authAddPhoto`) atop the card, **first/last name side by side** in a `Row` (RTL → first name on the right), the primary CTA relabelled `authCreateAccount` ("إنشاء الحساب"), and an **`OrDivider` + the auth-choose "Continue with Google/Apple" social buttons** below it (reused for consistency). Photo upload + social sign-in are stubs (tap → `comingSoon` toast); no `image_picker`/social deps added. The auth-choose `_OrDivider` was extracted to a shared `lib/shared/ui/or_divider.dart`. New strings `authCreateAccount`, `authAddPhoto`, `authOr` (EN + AR). Analyze clean, 120 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **auth → sub-features + BLoC + enhanced validation**: `lib/features/auth/` restructured from flat `data/domain/presentation` (2 `Cubit`s + combined `AuthPage`) into sub-features (`shared/`, `login/`, `register/`, `password_recovery/`, `choose/`) with `bloc/`-backed pages, onto the mandated **BLoC** pattern (`AGENTS.md` §118). Login/register are now separate `LoginPage`/`RegisterPage` on `/auth` + `/auth/register` (`AppRoutes.auth`→`login`, `register` added; guard + router updated), backed by `LoginBloc`/`RegisterBloc`; `PasswordRecoveryBloc` drives recovery. Validation strengthened: real email regex, register/reset passwords need ≥8 chars + letter + digit (login stays lax → server 422), live inline `autovalidate`, a **password-strength meter**, and a **live username-availability marker** (✓/✗, debounced) via new `GET /auth/check-username` (`isUsernameAvailable`; silent-degrades to submit-time 422). New strings (`passwordStrength*`, `authUsername{Available,Taken}`), EN + AR; cubit tests → bloc tests. Analyze clean, 120 tests pass. Paired backend endpoint in `osta_backend`. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **bottom nav redesign**: `AppBottomNavBar` swapped the M3 `NavigationBar` for a rounded, elevated bar (top-rounded, `AppElevation.high`) of icon+label tabs (selected → brand-green + bold) with an optional **raised circular center action** (`centerIcon`/`onCenterTap`) that protrudes above the bar and is an action, not a tab. Customer shell now has 4 tabs (Home, Bookings, Store, More) around a green map/location FAB (stub → "coming soon"); business keeps 3 tabs. New `navStore`/`navMore` strings; badges + RTL retained. Analyze clean, 110 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **auth errors as toasts**: new shared `AppToaster` (`lib/shared/ui/app_toaster.dart`) shows a themed `SnackBar` over the root `ScaffoldMessenger` (`AppToaster.messengerKey` wired into `MaterialApp`); form-level auth failures (login/register, forgot, reset) now pop an error toast instead of inline text (per-field 422s stay inline), and transport failures (`NetworkException`) show a localized "Can't reach the server…" (`errorNetwork`) via a new `networkError` state flag. `AuthFormError` removed. Also added a **debug-only offline login** for the QA/App Review test account (`test@osta.com`/`osta123123` skips `/auth/login` in `kDebugMode`, fabricating a local session — compiled out of release). Analyze clean, 109 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **auth form fields UX pass**: the shared `AppTextField` + input theme gained a brand-green focus ring and error ring (were borderless), focus-tinted icons, per-field leading icons (mail/lock/person/`@`/reset-code), OS autofill hints across the flow (with the login/register form in an `AutofillGroup`), an always-visible `+20` phone dial prefix, Material floating labels (field name as muted placeholder, floats to brand green on focus — distinct from typed text), and a localized Show/Hide password tooltip (new `showPassword`/`hidePassword` strings). Analyze clean, 107 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **branded app icon + native splash**: replaced the default Flutter launcher icon with the OSTA mark (`assets/images/app_icon.png`) and added a native OS launch splash matching the in-app `SplashPage` (white OSTA logo on brand green `#0E7A3B`), via `flutter_launcher_icons` + `flutter_native_splash` (dev deps, run manually — not `build_runner`; Android adaptive icon uses a padded foreground so the mask can't clip the wordmark). Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **auth + language + role screens UI/UX refactor + branded logo**: a new shared `BrandScaffold` (`lib/shared/ui/brand_scaffold.dart`) — collapsing brand-green `SliverAppBar` hero band + white OSTA logo (shrinks but stays visible on scroll, back button pinned over it), bold centered title + optional subtitle — now backs **all four** auth screens (auth-choose, login/register, forgot, reset) **plus the language pick and role chooser**, so the logo carries across the whole logged-out flow (was chooser-only; language/role were flat columns) — full lockup on the landing screens, smaller wordmark on inner auth screens. Auth form fields wrapped in an `AppCard`; language/role keep their selectable cards; the dark-mode-broken `socialButton` was replaced by the tokenized `AppButton` (secondary + icon) and deleted; raw error text → themed `AuthFormError`. No new strings/deps/routes; analyze clean, 107 tests pass. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 6, 2026 — **M1 auth email/password surface extended** (epic [#35](https://github.com/YoussefSalem582/Osta-App/issues/35)): register now takes a unique username + required `+20` phone + password confirm + Terms/Privacy gate; login gains a password visibility toggle and a "forgot password?" link; new `ForgotPasswordPage`/`ResetPasswordPage` recovery flow (`/auth/forgot-password` + `/auth/reset-password`) on a `PasswordRecoveryCubit`; `AuthRepository` gained `logout` (revoke + clear, wired through `SessionController.signOut`), `forgotPassword`, `resetPassword`; server 422s now render as inline per-field errors. Earlier Jul 6: **adopted a `develop`/`main` branching model**: feature branches now PR into a new long-lived **`develop`** integration branch, and **`main`** is release-only (advanced only by a `develop → main` PR + SemVer tag). Also Jul 6: the **first-run flow & 4-role split ([#32](https://github.com/YoussefSalem582/Osta-App/issues/32) · [PR #67](https://github.com/YoussefSalem582/Osta-App/pull/67))** was merged into `develop` (adapted to the post-[#69](https://github.com/YoussefSalem582/Osta-App/pull/69) plain-Dart conventions — manual `get_it` DI for the session/auth layer, dev `/gallery` route dropped). Earlier (Jul 5): **[`OSTA_plan.md`](docs/OSTA_plan.md) + [`OSTA_TODO.md`](docs/OSTA_TODO.md) added**: the master AI-agent execution plan for delivering the 31 open epics (11 owner mandates, offline-first + talker + skeletonizer + release/tag amendments, milestone-by-milestone build order) and its trackable zero-to-production checklist (per-phase release tags through the Phase-9 launch gate). Also vendored the official Dart/Flutter agent skills (14 curated, 7 excluded) into [`.claude/skills/`](../.claude/skills/README.md). Earlier the same day: documentation set created, then amended to match the deferral refactor ([`../docs/ROADMAP.md`](../docs/ROADMAP.md)) — `AGENTS.md` + `CLAUDE.md` shim at the root, and this `osta_readme_files/` tree (INDEX, guides, feature docs mirroring the GitHub epics, ADRs, reference docs, delivery plan). Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 8, 2026 — **auth-flow reorder + language/role/onboarding every logged-out launch**: the logged-out flow is now `splash → language → role → onboarding → auth-choose → auth → shell` (role before onboarding). The **language, role, and onboarding screens each re-show every logged-out launch** — gated by in-memory `SessionState` flags (`languageAcknowledged`/`roleAcknowledged`/`onboardingAcknowledged`, reset each cold `bootstrap`), not the persisted locale/role; the saved locale + role are the pre-selected defaults (accent border + check). A held token skips all three. The **auth-choose back button returns to onboarding** (`SessionController.resetOnboarding()`); login/register back → auth-choose. The earlier "language not showing" was not a bug (correctly gated by the saved locale). Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 7, 2026 — **auth-flow enhancements**: the logged-out first-run flow is now `splash → language → onboarding → role → auth-choose → auth → shell`. **Onboarding** re-shows on **every launch while logged out** (gated by a new in-memory `SessionState.onboardingAcknowledged` flag reset each cold start, checked in `resolveRedirect`); the carousel is intro-only + localized. `LanguagePage` redesigned; new **`AuthChoosePage`** (`/auth/choose`, default unauthenticated landing) offers Sign in / Create account (routing into `AuthPage` via `?mode=login|register` → `AuthCubit.setMode`) + stubbed Google/Apple social buttons. Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Last Updated:** Jul 7, 2026 — **debug-only login prefill**: `AuthPage` prefills the QA/App Review test account (`test@osta.com` / `osta123123`) under `kDebugMode` only (release strips it; the account must exist backend-side). Earlier (Jul 6): **adopted a `develop`/`main` branching model**: feature branches now PR into a new long-lived **`develop`** integration branch, and **`main`** is release-only (advanced only by a `develop → main` PR + SemVer tag). Also Jul 6: the **first-run flow & 4-role split ([#32](https://github.com/YoussefSalem582/Osta-App/issues/32) · [PR #67](https://github.com/YoussefSalem582/Osta-App/pull/67))** was merged into `develop` (adapted to the post-[#69](https://github.com/YoussefSalem582/Osta-App/pull/69) plain-Dart conventions — manual `get_it` DI for the session/auth layer, dev `/gallery` route dropped). Earlier (Jul 5): **[`OSTA_plan.md`](docs/OSTA_plan.md) + [`OSTA_TODO.md`](docs/OSTA_TODO.md) added**: the master AI-agent execution plan for delivering the 31 open epics (11 owner mandates, offline-first + talker + skeletonizer + release/tag amendments, milestone-by-milestone build order) and its trackable zero-to-production checklist (per-phase release tags through the Phase-9 launch gate). Also vendored the official Dart/Flutter agent skills (14 curated, 7 excluded) into [`.claude/skills/`](../.claude/skills/README.md). Earlier the same day: documentation set created, then amended to match the deferral refactor ([`../docs/ROADMAP.md`](../docs/ROADMAP.md)) — `AGENTS.md` + `CLAUDE.md` shim at the root, and this `osta_readme_files/` tree (INDEX, guides, feature docs mirroring the GitHub epics, ADRs, reference docs, delivery plan). Detail: [`DOCUMENTATION_UPDATE_SUMMARY.md`](DOCUMENTATION_UPDATE_SUMMARY.md).
> **Version:** `1.0.0+1` — not released; no store presence yet.
> **Flutter:** SDK constraint `^3.12.1` (Dart); CI pins Flutter 3.44.1.
> **Status:** 🚧 **M0 foundation complete** ([#28](https://github.com/YoussefSalem582/Osta-App/issues/28) ✅ scaffolding+CI, [#29](https://github.com/YoussefSalem582/Osta-App/issues/29) ✅ design system, [#31](https://github.com/YoussefSalem582/Osta-App/issues/31) ✅ networking) | 🔄 [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) localization & RTL open | 📋 All feature epics open — see [DELIVERY_PLAN.md](reference/DELIVERY_PLAN.md)

## Table of Contents

- [Executive Summary](#-executive-summary--الملخص-التنفيذي)
- [Project Metrics](#-project-metrics--مقاييس-المشروع)
- [What Exists Today](#-what-exists-today--ما-هو-موجود-اليوم)
- [Feature Status vs Epics](#-feature-status-vs-epics--حالة-الميزات-مقابل-الإبكات)
- [Design System](#-design-system--نظام-التصميم)
- [Testing](#-testing--الاختبارات)
- [Technical Stack](#-technical-stack--المكدّس-التقني)
- [Backend Status](#-backend-status--حالة-الباك-إند)
- [Git & Branch Status](#-git--branch-status--حالة-git-والفروع)

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
| Hand-written Dart files | 51 | ✅ |
| Screens/pages | 5 (SplashPage, RoleSelectionPage, ProviderOnboardingPage, BusinessIdentityPage, BusinessCatalogPage) | 🚧 |
| Blocs/Cubits | 1 (ThemeModeController) | 🚧 |
| Repositories / use cases | 0 | 📋 stubs await features |
| Shared UI components | 8 | ✅ |
| Formatters | 2 (EgpFormatter, NumberFormatter) | ✅ |
| Locales | 2 (ar default, en) — ~70 keys | 🚧 grows with features |
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
| `features/` | splash + role + auth (email/password login+register, password recovery, secure-storage tokens) + business onboarding / catalog / services / shop screens implemented; customer/*, notifications = stub folders |
| `features/` | splash + role + auth (email/password login+register, password recovery, secure-storage tokens) + business onboarding screens (cards, badges & wizard screens) implemented; customer/*, shop, notifications = stub folders |

---

## 🧩 Feature Status vs Epics / حالة الميزات مقابل الإبكات

Full mirror with owners and backend state: [DELIVERY_PLAN.md](reference/DELIVERY_PLAN.md). Summary:

> ‏المرآة الكاملة مع المالكين وحالة الباك-إند في [DELIVERY_PLAN.md](reference/DELIVERY_PLAN.md). ملخص:

| Milestone | Epics | State |
|-----------|-------|-------|
| M0 Foundation | [#28](https://github.com/YoussefSalem582/Osta-App/issues/28) [#29](https://github.com/YoussefSalem582/Osta-App/issues/29) [#31](https://github.com/YoussefSalem582/Osta-App/issues/31) ✅ · [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) 🔄 | done except l10n/RTL runtime switch |
| M1 First-run, auth, account | #32–#40, #53 | 🔄 first-run ✅ · auth email/password + recovery in progress ([#35](https://github.com/YoussefSalem582/Osta-App/issues/35)) · rest 📋 open, backend ready |
| M2 Discovery (map/profile/filters) | #41–#43 | 📋 open, backend ready |
| M3 Booking + business bookings + team | #44, #45, #55, #62 | 📋 open, backend ready |
| M3.5 Payments (Paymob) | #46 | ⛔ blocked — backend #47/#48/#49 open |
| M4 Realtime + business dashboard | #47, #54 | 📋 open, backend ready |
| M5 Garage + business catalog | #50, #56 | 🔄 business onboarding & catalog screens ✅ · backend ready |
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
