# ADR 003 — GoRouter with role-based redirect + StatefulShellRoute

## Status

Accepted (2026-07-02) (amended 2026-07-05)

## Context / السياق

Routing must (a) branch users into the consumer or provider shell by role ([app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)), (b) gate the first-run flow (splash → language → role → onboarding, shown once) ([app #32](https://github.com/YoussefSalem582/Osta-App/issues/32)), (c) support deep links for notifications ([app #52](https://github.com/YoussefSalem582/Osta-App/issues/52)), and (d) keep bottom-nav state across tab switches. The current router is minimal (`/splash`, `/role`).

> ‏لازم التوجيه (routing) يعمل أربع حاجات: (أ) يوزّع المستخدمين على واجهة العميل أو مقدّم الخدمة حسب الدور، (ب) يتحكّم في تدفّق أول تشغيل (splash ← اللغة ← الدور ← onboarding) بحيث يظهر مرّة واحدة، (ج) يدعم الروابط العميقة (deep links) للإشعارات، (د) يحافظ على حالة شريط التنقّل السفلي عند التبديل بين التبويبات. الراوتر الحالي بسيط ويحتوي على `/splash` و `/role` فقط.

## Decision / القرار

We will use **`go_router`** with a top-level `redirect` as the single gate: it reads auth state + persisted `activeRole`, verified against `me.type`, and sends users to the ConsumerShell or ProviderShell. Each shell is a **`StatefulShellRoute`** (bottom-nav branches that preserve state). Route paths are declared as `static const path` on the page widgets and wired in `lib/core/router/app_router.dart`; navigation uses those constants, never hardcoded path strings.

> ‏هنستخدم **`go_router`** مع `redirect` على المستوى الأعلى كبوابة وحيدة: بتقرأ حالة المصادقة و `activeRole` المحفوظ، وتتحقّق منهم مقابل `me.type`، وتوجّه المستخدم إلى ConsumerShell أو ProviderShell. كل shell عبارة عن **`StatefulShellRoute`** (فروع لشريط التنقّل السفلي تحافظ على حالتها). مسارات الصفحات معرّفة كـ `static const path` على ودجت كل صفحة وموصّلة في `lib/core/router/app_router.dart`، والتنقّل بيستخدم الثوابت دي مش نصوص مسار مكتوبة بالإيد.

## Consequences / النتائج

- **Positive:**
  - One place decides "which shell / are you allowed here", including auth gating and wrong-shell auto-correct (with a toast).
  - `StatefulShellRoute` keeps tab state for free (no manual `IndexedStack`).
  - Deep links work with per-platform intent filters only.

> ‏الإيجابيات: مكان واحد بيقرّر «أي shell / هل مسموح لك هنا»، بما في ذلك التحكّم في المصادقة والتصحيح التلقائي لو المستخدم في الـ shell الغلط (مع toast). و `StatefulShellRoute` بيحافظ على حالة التبويبات من غير `IndexedStack` يدوي. والروابط العميقة بتشتغل بمرشّحات النوايا (intent filters) لكل منصّة فقط.

- **Negative:**
  - Coupled to go_router's API; major bumps occasionally rename things.
  - Complex redirect logic must stay centralized or it becomes hard to reason about.

> ‏السلبيات: مرتبطين بواجهة go_router؛ والإصدارات الكبيرة أحيانًا بتغيّر أسماء الحاجات. ومنطق الـ redirect المعقّد لازم يفضل مركزيًّا وإلا هيبقى صعب فهمه.

- **Alternatives rejected:**
  - **Navigator 2.0 raw** — far more boilerplate for the same result.
  - **auto_route** — another generator to maintain; the codebase deliberately avoids codegen (plain Dart for a Flutter-new team, see [../../docs/ROADMAP.md](../../docs/ROADMAP.md)), and go_router covers our needs without it.

> ‏البدائل المرفوضة: **Navigator 2.0 الخام** بيتطلّب كود تكراري أكتر بكتير لنفس النتيجة؛ و**auto_route** مولّد كود إضافي محتاج صيانة، والكودبيس بيتجنّب توليد الكود عمدًا (Dart بسيط لفريق جديد على Flutter، شوف [../../docs/ROADMAP.md](../../docs/ROADMAP.md))، و go_router بيغطّي احتياجاتنا من غيره.

- **Follow-ups:**
  - Build the redirect when auth lands ([app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)/[#35](https://github.com/YoussefSalem582/Osta-App/issues/35)). See [../features/role-selection-and-routing.md](../features/role-selection-and-routing.md) and [../guides/02_architecture.md](../guides/02_architecture.md) § Routing.

> ‏المتابعات: نبني الـ redirect لمّا تتوصّل المصادقة (شوف [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)/[#35](https://github.com/YoussefSalem582/Osta-App/issues/35)). راجع [../features/role-selection-and-routing.md](../features/role-selection-and-routing.md) و [../guides/02_architecture.md](../guides/02_architecture.md) قسم Routing.
