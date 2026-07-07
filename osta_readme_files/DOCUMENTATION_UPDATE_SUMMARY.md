# Documentation Update Summary

> [INDEX](INDEX.md) > Documentation Update Summary
>
> Dated log of documentation changes, newest first. Add an entry here after every meaningful change (see [`../AGENTS.md`](../AGENTS.md) § Mandatory Documentation).

## 2026-07-08 — Auth errors as toasts (AppToaster) + localized network error

Added a shared `AppToaster` (`lib/shared/ui/app_toaster.dart`) — a themed `SnackBar` over the root `ScaffoldMessenger` via `AppToaster.messengerKey` (now wired into `MaterialApp`, replacing the private key in `app.dart`); callable from anywhere without a `Scaffold` context. Form-level auth failures (login/register, forgot, reset) now show an error toast instead of inline text: a `BlocListener` fires on `status == failure && fieldErrors.isEmpty`, while per-field 422 errors stay inline. Transport failures (`NetworkException` — connection refused/timeout) are flagged via a new `networkError` bool on `AuthState`/`PasswordRecoveryState` and shown as a localized `errorNetwork` message ("Can't reach the server…", EN + AR) instead of the raw "Network error". The unused `AuthFormError` widget was deleted. Analyze clean; 107 tests pass.

> ‏أُضيف `AppToaster` مشترك يعرض `SnackBar` بالثيم فوق `ScaffoldMessenger` الجذر عبر `AppToaster.messengerKey` (موصول بـ `MaterialApp` بدل المفتاح الخاص في `app.dart`)، ويُستدعى من أي مكان دون سياق `Scaffold`. أخطاء النماذج العامة تظهر الآن كإشعار منبثق بدل النص المضمّن عبر `BlocListener`، وتبقى أخطاء 422 لكل حقل مضمّنة. وتُعلَّم أخطاء النقل (`NetworkException`) بعلم `networkError` وتُعرض برسالة `errorNetwork` مترجمة بدل «Network error». وحُذف `AuthFormError`. التحليل نظيف و107 اختبارات تنجح.

Also added a **debug-only offline login** for the QA / App Review test account: in `kDebugMode` only, `test@osta.com` / `osta123123` skips `/auth/login` and fabricates a local session (`AuthCubit._mockLogin` → `SessionController.onAuthenticated`), so local QA works with the backend down; release compiles it out (the prefill + bypass share `AuthCubit.debugEmail`/`debugPassword`). Covered by `test/features/auth/auth_cubit_test.dart`.

> ‏وأُضيف أيضًا **تسجيل دخول بلا اتصال في وضع التصحيح فقط** لحساب الاختبار: في `kDebugMode` فقط يتخطّى `test@osta.com` / `osta123123` نداء `/auth/login` ويصطنع جلسة محلية، فيعمل الاختبار المحلي والخادم متوقّف؛ ويُحذف في الإصدار. مغطّى باختبار.

Touched: `lib/shared/ui/app_toaster.dart` (new), `lib/app.dart`, `lib/features/auth/presentation/{auth_cubit,password_recovery_cubit,auth_page,forgot_password_page,reset_password_page}.dart`, deleted `lib/features/auth/presentation/widgets/auth_form_error.dart`, `lib/l10n/app_{en,ar}.arb` (+`errorNetwork`), `test/features/auth/auth_cubit_test.dart` (new), `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Auth form fields UX pass (icons, autofill, focus/error rings, +20)

Usability pass on the shared `AppTextField` (`lib/shared/ui/app_text_field.dart`) and the input theme (`lib/core/theme/app_theme.dart`). Text fields now show a brand-green focus ring and an error ring (were borderless), with leading/trailing icons tinting to the brand colour on focus. Every auth field gained a contextual leading icon (mail / lock / person / `@` / reset-code) and OS autofill hints (email, given/family name, new username, current/new password, one-time code, national phone); the login/register form is wrapped in an `AutofillGroup` for password-manager save, and name fields capitalise words. The Egyptian phone field shows an always-visible `+20` dial prefix (with a divider) instead of the old focus-only `prefixText`. `AppTextField` moved from a separate label above the box to a Material **floating label** — the field name is the in-field placeholder in a muted colour and floats to the border in brand green on focus/fill, so the placeholder reads as the field name and is distinct from full-colour typed text (theme sets `hintStyle`/`labelStyle`/`floatingLabelStyle`; the interim example hints + `hint*` strings were dropped). The password eye toggle uses outlined icons + a localized Show/Hide password tooltip (new `showPassword`/`hidePassword` strings). Analyze clean; 107 tests pass (eye-toggle test updated to the outlined icons).

> ‏تحسين قابلية استخدام حقول الإدخال المشتركة وثيم الإدخال: حلقة تركيز خضراء وحلقة خطأ (كانت بلا حدود)، وأيقونات تتلوّن بالأساسي عند التركيز. واكتسب كل حقل مصادقة أيقونة أمامية مناسبة وتلميحات ملء تلقائي (بريد، الاسم الأول/العائلة، اسم مستخدم، كلمة مرور، رمز، هاتف)، مع لفّ نموذج الدخول/التسجيل بـ `AutofillGroup`؛ وتُكبّر حقول الاسم أوّل حرف. ويعرض حقل الهاتف بادئة `+20` ثابتة بفاصل. ويستخدم زر إظهار كلمة المرور أيقونات مفرّغة وتلميحًا مترجمًا (مفتاحان جديدان `showPassword`/`hidePassword`). التحليل نظيف و107 اختبارات تنجح.

Touched: `lib/shared/ui/app_text_field.dart`, `lib/core/theme/app_theme.dart`, `lib/features/auth/presentation/{auth_page,forgot_password_page,reset_password_page}.dart`, `lib/l10n/app_{en,ar}.arb` (+`showPassword`/`hidePassword`), `test/shared/ui/components_test.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Branded app icon + native splash screen

Replaced the default Flutter launcher icon with the OSTA mark (`assets/images/app_icon.png` — white wordmark + smile on brand green) and added a native OS launch splash matching the in-app `SplashPage` (white OSTA logo on brand green `#0E7A3B`). Uses two one-time native-asset generators added as dev deps — `flutter_launcher_icons` + `flutter_native_splash`, configured in `pubspec.yaml`, run manually (`dart run flutter_launcher_icons` / `dart run flutter_native_splash:create`) — not `build_runner`. Android gets per-density mipmaps + an adaptive icon (background `#0E3725`, padded foreground `assets/images/app_icon_foreground.png` scaled into the safe zone so the launcher mask can't clip it); iOS gets the full `AppIcon.appiconset` + `LaunchImage`/`LaunchScreen`. No Dart/runtime changes; analyze clean, all 107 tests pass.

> ‏استُبدلت أيقونة Flutter الافتراضية بعلامة OSTA (`assets/images/app_icon.png`)، وأُضيفت شاشة إقلاع نظام أصليّة مطابقة لـ `SplashPage` (شعار أبيض على الأخضر `#0E7A3B`). عبر مولّدَي `flutter_launcher_icons` و`flutter_native_splash` (مضافين كتبعيّات تطوير، يُشغَّلان يدويًا، لا `build_runner`). تحصل أندرويد على أيقونات لكل كثافة وأيقونة تكيّفية (خلفية `#0E3725` وطبقة أمامية مبطّنة)، وiOS على مجموعة الأيقونات وشاشة الإقلاع. بلا تغييرات Dart؛ التحليل نظيف و107 اختبارات تنجح.

Touched: `pubspec.yaml` (deps + `flutter_launcher_icons`/`flutter_native_splash` config), `assets/images/app_icon_foreground.png` (new, generated), generated native assets under `android/app/src/main/res/**` (mipmaps, adaptive icon, `colors.xml`, splash drawables + styles) and `ios/Runner/**` (`AppIcon.appiconset`, `LaunchImage`, `LaunchScreen.storyboard`, `Info.plist`), `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Auth + language + role screens UI/UX refactor + branded logo (BrandScaffold)

Refactored the auth, language, and role screens' UI/UX and put the app logo on every one of them. New shared `BrandScaffold` (`lib/shared/ui/brand_scaffold.dart`) renders a collapsing brand-green `SliverAppBar` whose hero band holds the white OSTA logo (shrinks but stays visible as the body scrolls, back button pinned over it, subtle shadow once content scrolls under), a bold centered title, and an optional subtitle; the four auth screens (auth-choose, login/register, forgot, reset) plus the language pick and role chooser now build from it, so the logo carries across the whole logged-out flow (was chooser-only; language/role were flat centered columns). Landing screens (chooser, language, role) show the full lockup (`AppImages.fullLogo`), the inner auth screens the smaller wordmark (`AppImages.logo`) — both white assets that read on `AppColors.brandGreen`. Auth form fields are wrapped in an elevated `AppCard`; language/role keep their selectable `_LanguageCard`/`_RoleCard` bodies. The hardcoded, dark-mode-broken `socialButton` was replaced by the tokenized `AppButton` (secondary + icon) at both call sites and its file deleted; raw `TextStyle(color: error)` form errors became a themed `AuthFormError`. No new strings/deps/routes; auth success sub-views stay icon-led. Analyze clean; all 107 tests pass (incl. the language→role→onboarding→auth-choose flow test).

> ‏أُعيد تصميم واجهة/تجربة شاشات المصادقة واللغة والدور مع وضع شعار التطبيق على كلٍّ منها. يعرض `BrandScaffold` المشترك الجديد (`lib/shared/ui/brand_scaffold.dart`) شريطًا علويًا أخضر متقلّصًا (`SliverAppBar`) يحمل شعار OSTA الأبيض (يصغر لكن يبقى ظاهرًا عند التمرير، وزر الرجوع مثبّت فوقه)، ثم عنوانًا عريضًا متوسّطًا وعنوانًا فرعيًا اختياريًا؛ وتُبنى منه الشاشات الأربع (auth-choose، الدخول/التسجيل، نسيت كلمة المرور، إعادة التعيين) إضافةً إلى شاشتَي اللغة والدور، فامتدّ الشعار عبر تدفّق غير المسجّل كله (كان على شاشة الاختيار فقط، وكانت اللغة/الدور أعمدة مسطّحة). تعرض شاشات الهبوط (الاختيار، اللغة، الدور) الشعار الكامل (`AppImages.fullLogo`)، والشاشات الداخلية النسخة الأصغر (`AppImages.logo`). وأصبحت حقول المصادقة داخل `AppCard`؛ وتحتفظ اللغة/الدور ببطاقاتها القابلة للاختيار. واستُبدل `socialButton` المكسور في الوضع الداكن بـ `AppButton` وحُذف ملفه، وصارت أخطاء النماذج عبر `AuthFormError`. بلا نصوص/حزم/مسارات جديدة. التحليل نظيف وكل الاختبارات (107) تنجح.

Touched: `lib/shared/ui/brand_scaffold.dart` (new, moved+renamed from `features/auth/presentation/widgets/auth_scaffold.dart`), `lib/features/auth/presentation/widgets/auth_form_error.dart` (new), `lib/features/auth/presentation/{auth_choose_page,auth_page,forgot_password_page,reset_password_page}.dart`, `lib/features/onboarding/presentation/language_page.dart`, `lib/features/role/presentation/role_chooser_page.dart`, deleted `lib/features/onboarding/widget/social_button.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-08 — Auth-flow reorder + language/role/onboarding every logged-out launch + back chain

Reordered the logged-out flow to `splash → language → role → onboarding → auth-choose → auth → shell` (role now before onboarding). The language, role, and onboarding screens now re-show on **every logged-out launch** — each gated by an in-memory `SessionState` flag (`languageAcknowledged`, `roleAcknowledged`, `onboardingAcknowledged`, reset each cold `bootstrap`) rather than the persisted locale/role; the saved locale + role are the pre-selected defaults (marked with an accent border + check on the cards). The role gate also forces the chooser whenever `activeRole` is null; a held token skips all three. The auth-choose back button returns to onboarding via `SessionController.resetOnboarding()` (role + language stay); login/register back → auth-choose. Onboarding gains a Skip button (top-right, hidden on the last slide) that jumps to auth-choose. The earlier "language not showing" report was not a bug — it was correctly gated by the saved locale; this change makes it (and the role chooser) repeat by request.

> ‏أُعيد ترتيب تدفّق المستخدم غير المسجّل إلى `splash → language → role → onboarding → auth-choose → auth → shell` (أصبح اختيار الدور قبل الـ onboarding). وتظهر شاشات اللغة والدور والـ onboarding الآن **في كل تشغيل طالما غير مسجّل** — كلٌّ محكوم بعلم في الذاكرة (`languageAcknowledged` و`roleAcknowledged` و`onboardingAcknowledged`، تُصفَّر مع كل إقلاع) بدل الاعتماد على اللغة/الدور المحفوظَين؛ ويكون المحفوظ هو الخيار الافتراضي (مُعلَّمًا بإطار وعلامة صح على البطاقات). ويفرض حاجزُ الدور المُختارَ أيضًا كلما كان `activeRole` فارغًا؛ ويتخطّى وجودُ التوكن الثلاثةَ جميعًا. وزرّ الرجوع في auth-choose يعود إلى الـ onboarding عبر `SessionController.resetOnboarding()` (يبقى الدور واللغة). ولم يكن بلاغ «اللغة لا تظهر» عيبًا — كانت محكومة صحيحًا باللغة المحفوظة؛ وهذا التغيير يجعلها (والدور) تتكرّر بناءً على الطلب.

Touched: `lib/core/session/{session_state,session_controller}.dart`, `lib/core/router/session_redirect.dart`, `lib/features/auth/presentation/auth_choose_page.dart`, `lib/features/onboarding/presentation/language_page.dart`, `lib/features/onboarding/page/onboarding_page.dart`, `lib/features/role/presentation/role_chooser_page.dart`, `lib/l10n/app_{en,ar}.arb`, `test/{core/router/session_redirect_test,core/session/session_controller_test,widget_test}.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-07 — Auth-flow enhancements: onboarding gate + redesigned language & auth-choose screens

Reworked the logged-out first-run flow to `splash → language → onboarding → role → auth-choose → auth → shell`. Onboarding is reachable again and re-shows on **every launch while logged out**, gated by a new in-memory `SessionState.onboardingAcknowledged` flag (reset each cold start) checked in `resolveRedirect`; its finish button calls `SessionController.acknowledgeOnboarding()`. The carousel became intro-only + localized. `LanguagePage` was redesigned; a new `AuthChoosePage` (`/auth/choose`, the default unauthenticated landing) offers Sign in / Create account — routing into `AuthPage` via a `?mode=login|register` param (`AuthCubit.setMode`) — plus stubbed Google/Apple social buttons. Guard `authSurface` whitelists `/auth/choose`. Added **back navigation**: auth-choose back clears the role (`switchRole` → role chooser) and login/register back returns to `/auth/choose`; `clearingRole` preserves `onboardingAcknowledged` so back doesn't re-trigger onboarding.

> ‏أُعيد تصميم تدفّق أول تشغيل للمستخدم غير المسجّل إلى `splash → language → onboarding → role → auth-choose → auth → shell`. عادت شاشة الـ onboarding للظهور، وتظهر **في كل تشغيل طالما المستخدم غير مسجّل** عبر علم `onboardingAcknowledged` في الذاكرة (يُصفَّر مع كل إقلاع) يُفحَص في `resolveRedirect`؛ ويستدعي زرّ الإنهاء `SessionController.acknowledgeOnboarding()`. أصبح الكاروسيل تعريفيًا فقط ومترجمًا. وأُعيد تصميم `LanguagePage`، وأُضيفت شاشة `AuthChoosePage` (`/auth/choose`، صفحة الهبوط الافتراضية لغير المسجّل) تعرض «تسجيل الدخول / إنشاء حساب» — وتنتقل إلى `AuthPage` عبر مُعامِل `?mode=login|register` — إضافةً إلى أزرار Google/Apple كعناصر نائبة.

Touched (code + docs): `lib/core/session/{session_state,session_controller}.dart`, `lib/core/router/{app_routes,session_redirect,app_router}.dart`, `lib/features/onboarding/{page/onboarding_page,presentation/language_page,widget/social_button}.dart`, `lib/features/auth/presentation/{auth_choose_page,auth_page,auth_cubit}.dart`, `lib/l10n/app_{en,ar}.arb`, `test/{core/router/session_redirect_test,widget_test}.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-06 — M1 auth email/password surface + password recovery ([#35](https://github.com/YoussefSalem582/Osta-App/issues/35))

Extended the shared auth surface toward the M1 email+password epic (no OTP): register now collects a unique username and a required Egyptian **+20** phone (masked, normalized to E.164), confirms the password, and gates submit behind a Terms/Privacy checkbox; login gains a password visibility toggle and a "forgot password?" link. Added a two-step recovery flow — `ForgotPasswordPage` (`POST /forgot-password`) → `ResetPasswordPage` (`POST /reset-password`) — on a new `PasswordRecoveryCubit` and `/auth/forgot-password` + `/auth/reset-password` routes (whitelisted in `resolveRedirect`). `AuthRepository` gained `logout` (best-effort revoke + always-clear, wired through `SessionController.signOut`), `forgotPassword`, and `resetPassword`; server 422s now surface inline per field via `AuthState.fieldErrors`. Endpoints follow the canonical catalogue.

> ‏تم توسيع واجهة المصادقة نحو ملحمة M1 بالبريد وكلمة المرور (بدون OTP): يجمع التسجيل الآن اسم مستخدم فريدًا ورقم هاتف مصري **+20** إلزاميًا (بقناع، ويُطبَّع إلى E.164) ويؤكّد كلمة المرور ويشترط قبول الشروط والخصوصية؛ ويحصل الدخول على زر إظهار كلمة المرور ورابط «نسيت كلمة المرور؟». وأُضيف تدفّق استعادة من خطوتين — `ForgotPasswordPage` ← `ResetPasswordPage` — على `PasswordRecoveryCubit` جديد ومسارَي `/auth/forgot-password` و`/auth/reset-password`. واكتسب `AuthRepository` الدوال `logout` (إبطال أفضل جهد مع مسح دائم، موصولة بـ `SessionController.signOut`) و`forgotPassword` و`resetPassword`؛ وتظهر أخطاء 422 الآن مضمّنة لكل حقل.

Touched (code + docs): `lib/features/auth/**` (auth page, `auth_cubit`, `auth_validators`, `password_recovery_cubit`, forgot/reset pages, repository), `lib/core/{router,session,di,auth}`, `lib/shared/ui/app_text_field.dart`, `lib/l10n/app_{en,ar}.arb`, matching tests, `CHANGELOG.md`, `CURRENT_STATUS.md`.
## 2026-07-07 — Debug-only login prefill for the QA/App Review test account

`AuthPage` now prefills the email/password fields with the test account (`test@osta.com` / `osta123123`) under `kDebugMode` only — release builds compile the block out. Speeds local sign-in and gives App Review a one-tap login; the account must still exist backend-side (`/auth/login`). Code + docs change.

> ‏يملأ `AuthPage` الآن حقلي البريد وكلمة المرور بحساب الاختبار (`test@osta.com` / `osta123123`) في وضع التصحيح فقط (`kDebugMode`) — تُحذف الكتلة في إصدارات الإنتاج. يُسرّع تسجيل الدخول محليًا ويمنح مراجعة المتجر دخولًا بنقرة واحدة؛ ويجب أن يظل الحساب موجودًا في الخادم (`/auth/login`).

Touched: `lib/features/auth/presentation/auth_page.dart`, `CHANGELOG.md`, `CURRENT_STATUS.md`.

## 2026-07-06 — `develop`/`main` branching model adopted

Introduced a long-lived **`develop`** integration branch and made **`main`** release-only: feature/chore branches now cut from `develop` and PR into `develop`; `main` advances **only** through a `develop → main` release PR + SemVer tag (`v0.<n>.0` per milestone, `v1.0.0` = MVP). Retargeted the open first-run PR ([#67](https://github.com/YoussefSalem582/Osta-App/pull/67)) to `develop`.

> ‏اعتُمد نموذج فروع `develop`/`main`: أُنشئ فرع تكامل دائم **`develop`** وأصبح **`main`** للإصدار فقط — تتفرّع فروع الميزات/المهام من `develop` وتُدمج فيه، ولا يتقدّم `main` إلا عبر طلب دمج `develop → main` مع وسم إصدار (`v0.<n>.0` لكل مرحلة و`v1.0.0` عند الـ MVP). وأُعيد توجيه PR أول تشغيل ([#67](https://github.com/YoussefSalem582/Osta-App/pull/67)) إلى `develop`.

Touched: `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `ARCHITECTURE.md`, `OSTA_plan.md` (§13.1–§13.3), `OSTA_TODO.md`, `CURRENT_STATUS.md`, `guides/01_folder_structure.md`, `guides/03_how_to_add_new_feature.md`, `reference/COMMON_PITFALLS.md`, `.cursor/rules/git-commits.mdc`, `.claude/commands/add-feature.md` + `new-screen.md`, `.agents/skills/add-feature/SKILL.md`, `.cursor/skills/add-feature/SKILL.md`, and `.github/workflows/ci.yml` (added `develop` to CI push triggers). Docs + CI-config change.

## 2026-07-06 — First-run flow & 4-role split rebased onto `main`

The first-run flow & 4-role split ([epic #32](https://github.com/YoussefSalem582/Osta-App/issues/32) · [PR #67](https://github.com/YoussefSalem582/Osta-App/pull/67)) was rebased onto current `main` and adapted to the post-[#69](https://github.com/YoussefSalem582/Osta-App/pull/69) plain-Dart conventions: the feature's `injectable`/`freezed`/`fpdart` annotations and the removed dev `/gallery` route were dropped, session/auth dependencies are registered by hand in `configureDependencies()` (`AuthCubit` as a factory, `AppRouter` built with the `SessionController` singleton), and the obsolete gallery redirect test was deleted.

> ‏أُعيد ترتيب فرع تدفّق أول تشغيل وانقسام الأدوار الأربعة ([الملحمة #32](https://github.com/YoussefSalem582/Osta-App/issues/32) · [PR #67](https://github.com/YoussefSalem582/Osta-App/pull/67)) فوق `main` الحالي وجرت مواءمته مع اصطلاحات Dart البسيطة بعد [#69](https://github.com/YoussefSalem582/Osta-App/pull/69): حُذفت تعليقات `injectable`/`freezed`/`fpdart` ومسار `/gallery` التطويري المُزال، وسُجِّلت تبعيات الجلسة والمصادقة يدويًا في `configureDependencies()` (‏`AuthCubit` كمصنع، و`AppRouter` يُبنى بمفرد `SessionController`)، وحُذف اختبار توجيه المعرض المتقادم.

`CHANGELOG.md` and `CURRENT_STATUS.md` updated to match. Code + docs change on the feature branch — no app code merged to `main` yet.

## 2026-07-05 — Branch-naming rule tightened (no tool-generated names)

All docs and AI-agent configs now require **hand-written, descriptive, lowercase kebab-case** branch names (`<type>/<issue>-<slug>`, e.g. `feat/44-booking-funnel`, `fix/auth-401-loop`) and forbid auto-generated/tool-default names (random suffixes, `claude/...`, `cursor/...`, `codex/...`) — rename with `git branch -m <type>/<issue>-<slug>` before opening a PR.

> ‏كل المستندات وإعدادات وكلاء الذكاء الاصطناعي أصبحت تشترط أسماء فروع مكتوبة يدويًا ووصفية بصيغة `<type>/<issue>-<slug>` (مثل `feat/44-booking-funnel`)، وتمنع الأسماء المولَّدة تلقائيًا من الأدوات (لواحق عشوائية أو `claude/...` أو `cursor/...`) — أعد التسمية بـ `git branch -m` قبل فتح الـ PR.

Touched: `AGENTS.md`, `CONTRIBUTING.md`, `README.md`, `ARCHITECTURE.md`, `OSTA_plan.md`, `OSTA_TODO.md`, `guides/03_how_to_add_new_feature.md`, `CURRENT_STATUS.md`, `.cursor/rules/git-commits.mdc`, `.claude/commands/{add-feature,new-screen}.md`, `.agents/skills/add-feature/SKILL.md`, `.cursor/skills/add-feature/SKILL.md`. Docs-only change.

## 2026-07-05 — `OSTA_TODO.md` zero-to-production checklist

Added [`../OSTA_TODO.md`](../OSTA_TODO.md) — the trackable checkbox roadmap companion to [`../OSTA_plan.md`](../OSTA_plan.md) (the plan is the rulebook; the TODO is the what/when).

> ‏أُضيف [`../OSTA_TODO.md`](../OSTA_TODO.md) — قائمة مهام قابلة للتتبّع بمربّعات اختيار، مرافقة لـ [`../OSTA_plan.md`](../OSTA_plan.md) (الخطة هي كتاب القواعد، وقائمة المهام هي ماذا ومتى).

Phases: 0 foundation (✅ pre-checked) → 1 M0 wrap (l10n #30 + talker/offline/motion chores) → 2–8 the feature milestones with per-epic owners/branches/key ACs and a 🏷️ release tag per phase → **9 production readiness & launch** (platform config, production credentials for Maps/Firebase/social/Paymob/Reverb, signing + store listings with data-safety/privacy labels, release CI, crash-reporting ADR, hardening drills — offline/realtime/push/payments/perf/a11y/security/l10n — beta tracks, staged `v1.0.0` rollout) → 10 post-launch/Phase 2. Cross-linked from `OSTA_plan.md` §0/§14, `INDEX.md`, and `CURRENT_STATUS.md`. Docs-only change.

## 2026-07-05 — `OSTA_plan.md` master build instructions for AI agents

Added [`../OSTA_plan.md`](../OSTA_plan.md) — a root-level, English, system-prompt-style plan that AI agents follow to deliver the 31 open epics on top of the existing M0 foundation.

> ‏أُضيف [`../OSTA_plan.md`](../OSTA_plan.md) — خطة بأسلوب موجّهات النظام (بالإنجليزية) في جذر المستودع يتبعها وكلاء الذكاء الاصطناعي لتسليم الملاحم المفتوحة الـ 31 فوق أساس M0 الحالي.

Contents: the 11 owner mandates (Clean Architecture + BLoC, dark/light, responsive, ar/en RTL, animations/transitions, reusable widgets + centralized colors/fonts/images/icons/text, `talker`, `skeletonizer`, document everything, offline-first, clean git graph with releases/tags); **four explicit amendments to the canon** — `talker_*` replaces `pretty_dio_logger`, `skeletonizer` for all loading states (overrides epic `shimmer` mentions), a new offline-first spec (`lib/core/offline/`: `sqflite` JSON-document cache + pending-operations queue + `SyncEngine` + `connectivity_plus`, with a per-feature cached/queued/online-only policy table), and a SemVer release/tag convention (`v0.<n>.0` per milestone, `v1.0.0` = MVP, annotated tags on `main`); source-of-truth precedence with a warning that the epics' stale codegen/Riverpod package stanza is superseded ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69)); and the milestone-by-milestone execution plan (M0 finish → M1…M5 → Shop/Home/Notifications → M6/Phase 2) with per-epic branch names, key ACs, endpoints, offline policies, and a global/per-epic/never package policy. Docs-only change — no code affected; a follow-up to sync `AGENTS.md` with the four amendments is noted in the plan's appendix.

## 2026-07-05 — Official Dart & Flutter agent skills vendored into `.claude/skills/`

Vendored a curated copy of the official Agent Skills published by the Flutter and Dart teams ([announcement](https://blog.flutter.dev/introducing-skills-for-dart-and-flutter-23837c6ec0ae) · upstream [`flutter/skills`](https://github.com/flutter/skills) @ `0d624f3`, [`dart-lang/skills`](https://github.com/dart-lang/skills) @ `8ce8492`). Claude Code auto-discovers each `SKILL.md` and loads it on demand.

> ‏أُدرجت نسخة منتقاة من «مهارات الوكيل» الرسمية لفريقي Flutter وDart في `.claude/skills/`؛ يكتشفها Claude Code تلقائيًا ويحمّلها عند الحاجة.

- **Installed (14)**: 8 Flutter (integration/widget tests, widget previews, responsive layout, layout debugging, hand-written JSON, go_router routing, ARB/gen-l10n localization) + 6 Dart (unit tests, coverage, runtime errors, package conflicts, static analysis, pattern matching).
- **Excluded (7)**: `flutter-use-http-package` (vs `ApiClient`-only rule), `flutter-apply-architecture-best-practices` (MVVM/`Result` vs BLoC + thrown `Failure`s), `dart-generate-test-mocks` + `dart-use-ffigen` (codegen vs no-codegen rule), `dart-migrate-to-checks-package`, `dart-build-cli-app`, `dart-setup-ffi-assets` (irrelevant).
- **Precedence**: skills are verbatim upstream copies; where generic advice conflicts with OSTA conventions, `AGENTS.md`/`CLAUDE.md` win — deltas and the re-vendor workflow documented in [`.claude/skills/README.md`](../.claude/skills/README.md).
- `CHANGELOG.md`, `CURRENT_STATUS.md`, and the `CLAUDE.md` "Where to look" table updated.

## 2026-07-05 — AI-agent config set (per-tool instruction files)

Added the per-tool agent scaffolding mirroring a proven layout, all adapted to OSTA's plain-Dart stack:

- **Root**: `CONTRIBUTING.md` (branch/commit/PR/quality-gate rules, bilingual), `ARCHITECTURE.md` (layers, data flow, DI, routing, adding a feature — bilingual), `CURSOR.md` (Cursor shim).
- **`.agents/`**: generic `AGENTS.md` shim + 8 scoped rules (`project-scope`, `dart-conventions`, `feature-architecture`, `bloc-patterns`, `api-integration`, `ui-design-system`, `security`, `documentation-updates`) + 3 project-tuned skills (`add-feature`, `add-api`, `add-language`).
- **`.claude/`**: 8 slash commands (`add-feature`, `add-api`, `add-language`, `new-screen`, `review`, `test`, `update-docs`, `clean-build`) + `settings.json` (approved-command allowlist).
- **`.codex/AGENTS.md`**, **`.github/copilot-instructions.md`**, **`.github/workflows/docs.yml`** (markdownlint + lychee link-check).
- **`.cursor/`**: 9 `.mdc` rules (the 8 above + `git-commits`) + skills mirror.

Every file encodes the real stack — sealed `Failure` + `try`/`catch` (no `Either`/`fold`), manual `get_it` (no `injectable`/`build_runner`), `ApiClient`/`ApiException`, no offline queue — and links to `AGENTS.md` + `docs/ROADMAP.md`. Verified: correct frontmatter, no stale-stack leakage, all relative links resolve.

## 2026-07-05 — Synced to the plain-Dart refactor + bilingual (EN/AR)

Re-checked the codebase after the "defer advanced Flutter tooling" refactor ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69)) and corrected the whole doc set, then made it bilingual.

> ‏بعد مراجعة الكود عقب إعادة الهيكلة "تأجيل أدوات Flutter المتقدّمة" ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69))، صُحّحت مجموعة التوثيق بالكامل ثم أُضيفت لها الترجمة العربية.

**Codebase reality now** (see [`docs/ROADMAP.md`](../docs/ROADMAP.md)): no `fpdart`/`Either`/`Result<T>` — a `sealed class Failure implements Exception` thrown with plain `try`/`catch`; no `freezed`/`json_serializable`/`injectable`/`build_runner` — plain `Equatable` models with hand-written `fromJson`/`toJson` and **manual** `get_it` registration; single `BASE_URL` dart-define (no `AppFlavor`/`FLAVOR`); `/gallery` component-gallery route removed; CI collapsed to one `format · analyze · test` job. The advanced tooling is **deferred, not rejected** — phased reintroduction plan in `docs/ROADMAP.md`.

> ‏**واقع الكود الآن** (راجع [`docs/ROADMAP.md`](../docs/ROADMAP.md)): لا يوجد `fpdart`/`Either`/`Result<T>` — بل `sealed class Failure implements Exception` يُرمى ويُلتقط بـ `try`/`catch` عادي؛ ولا يوجد `freezed`/`json_serializable`/`injectable`/`build_runner` — بل نماذج `Equatable` بسيطة بدوالّ `fromJson`/`toJson` مكتوبة يدويًا وتسجيل `get_it` **يدوي**؛ و`BASE_URL` واحد عبر dart-define (بلا `AppFlavor`/`FLAVOR`)؛ وحُذف مسار معرض المكوّنات `/gallery`؛ واختُصر الـ CI إلى مهمّة واحدة `format · analyze · test`. الأدوات المتقدّمة **مؤجّلة لا مرفوضة** — الخطة المرحلية في `docs/ROADMAP.md`.

**Doc changes**:
- `AGENTS.md` + `CLAUDE.md` — corrected (error/DI/model/config/CI/commands) and made bilingual; added a "Plain-Dart, No Codegen" section and ROADMAP pointers.
- `decisions/004` rewritten (sealed `Failure` + `try`/`catch`; fpdart deferred), `decisions/005` rewritten (no codegen; freezed/json_serializable/injectable deferred), `decisions/008` (single CI job).
- All guides, feature docs, and reference docs: stale codegen/fpdart/flavor/gallery/CI facts purged, ROADMAP linked, and Arabic (RTL) prose added alongside English (headings bilingual; identifiers/tables/endpoints stay English).
- `CHANGELOG.md` + `CURRENT_STATUS.md` updated.

## 2026-07-02 — Initial documentation set

Created the full documentation tree, mirroring the structure proven on a sibling project and grounded in the two GitHub issue trackers ([Osta-App](https://github.com/YoussefSalem582/Osta-App/issues) · [osta_backend](https://github.com/YoussefSalem582/osta_backend/issues)) plus the actual M0 codebase:

- **Root**: [`AGENTS.md`](../AGENTS.md) (canonical agent/contributor conventions), [`CLAUDE.md`](../CLAUDE.md) (Claude Code shim), [`CHANGELOG.md`](../CHANGELOG.md) (Keep a Changelog, seeded from the four merged M0 PRs).
- **Index & status**: [`INDEX.md`](INDEX.md) (task-oriented entry point + doc map), [`CURRENT_STATUS.md`](CURRENT_STATUS.md) (M0 snapshot + metrics + epic status).
- **Guides** ([guides/](guides/)): 01 folder structure · 02 architecture · 03 add a feature · 04 wire an API · 05 localization · 06 theme tokens · 07 reusable components · 08 security & environment · 09 API endpoint catalogue (from backend epics, with app-status column) · 10 testing · 11 backend ↔ app connectivity.
- **Feature docs** ([features/](features/README.md)): 22 docs matched 1:1 to the app epics (#28–#62) — bilingual overviews, mockup embeds from the `design-assets` branch, endpoint tables, planned architecture, testing expectations, cross-repo links.
- **Decisions** ([decisions/](decisions/README.md)): 8 ADRs (Clean Architecture + BLoC, single app multi-role, go_router role redirect, fpdart Either, codegen stack, Dio envelope + Sanctum, Arabic-first l10n, GitHub Actions CI).
- **Reference** ([reference/](reference/)): ONBOARDING, GLOSSARY, COMMON_PITFALLS, TROUBLESHOOTING, DELIVERY_PLAN (milestones, owners, cross-repo mirror, build order).

Docs-only change — no code or behaviour affected.
