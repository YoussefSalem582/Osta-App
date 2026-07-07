# ADR 002 — Single app hosting all roles (no monorepo)

## Status / الحالة

Accepted (2026-07-02) (amended 2026-07-05)

## Context / السياق

OSTA serves four roles: customer, business, and (Phase 2) solo-mechanic and tow-truck. They share a brand, design system, networking core, auth, and localization. The alternatives were separate apps per role, a Melos monorepo of role packages, or one app. A single store listing and shared onboarding are product requirements; there is no guest mode. See the [first-run canonical epic (#32)](https://github.com/YoussefSalem582/Osta-App/issues/32) and [tracker #61](https://github.com/YoussefSalem582/Osta-App/issues/61).

> ‏تخدم OSTA أربعة أدوار: العميل، والنشاط التجاري، و(في المرحلة الثانية) الميكانيكي الفردي وسيارة السحب. جميعها تتشارك الهوية البصرية، ونظام التصميم، ونواة الشبكة، والمصادقة، والترجمة. البدائل كانت تطبيقات منفصلة لكل دور، أو مستودع Melos أحادي يضم حزمة لكل دور، أو تطبيق واحد. وجود إدراج واحد في المتجر وتهيئة مشتركة عند أول تشغيل من متطلبات المنتج، ولا يوجد وضع ضيف.

## Decision / القرار

We will ship **one Flutter target** with a feature-first `lib/` that hosts every role. The role split happens **at runtime**: a persisted `activeRole` (chosen in the role chooser) routes the user into a **ConsumerShell** (`/home`) or a **ProviderShell** (`/dashboard`), verified against `me.type` from the backend. The provider shell is built generically so future solo-mechanic / tow-truck roles reuse it; those render as disabled "coming soon" cards until Phase 2.

> ‏سنُطلق **هدف Flutter واحد** بمجلد `lib/` منظّم حسب الميزة يستضيف كل الأدوار. يحدث فصل الأدوار **وقت التشغيل**: قيمة `activeRole` المحفوظة (المُختارة في شاشة اختيار الدور) تُوجّه المستخدم إلى **ConsumerShell** (`/home`) أو **ProviderShell** (`/dashboard`)، ويُتحقق منها مقابل `me.type` القادم من الخادم. صُمّمت واجهة مزوّد الخدمة بشكل عام لتُعيد أدوار الميكانيكي الفردي وسيارة السحب المستقبلية استخدامها، وتظهر تلك الأدوار كبطاقات "قريباً" مُعطّلة حتى المرحلة الثانية.

## Consequences / النتائج

- **Positive:**
  - One codebase, one design system, one CI, one store listing — no cross-repo drift for shared code.
  - Adding a role later is a shell branch + onboarding, not a new app.
  - Matches the backend, which is one API with role-bound registration ([backend #40](https://github.com/YoussefSalem582/osta_backend/issues/40)).

> ‏الإيجابيات: قاعدة كود واحدة، ونظام تصميم واحد، ومسار تكامل مستمر واحد، وإدراج واحد في المتجر — بلا انحراف بين المستودعات في الكود المشترك. إضافة دور لاحقاً تصبح تفريعة في الواجهة مع تهيئة، لا تطبيقاً جديداً. وهذا يطابق الخادم، وهو واجهة برمجية واحدة بتسجيل مرتبط بالدور.

- **Negative:**
  - The binary carries code for roles a given user never sees (acceptable — mostly UI).
  - Routing must be disciplined so a customer never reaches provider screens (guarded by the redirect, [ADR 003](003-go-router-role-redirect.md)).

> ‏السلبيات: يحمل الملف التنفيذي كوداً لأدوار قد لا يراها المستخدم أبداً (مقبول — معظمه واجهة). ويجب أن يكون التوجيه منضبطاً كي لا يصل عميل إلى شاشات مزوّد الخدمة (يحرسه التحويل في ADR 003).

- **Alternatives rejected:**
  - **Separate apps per role** — duplicated shared layers, 2–4× the maintenance.
  - **Melos monorepo** — package overhead without a real need; one team, one app.
  - **Build flavors per role** — can't switch roles at runtime (a user can be both a customer and a business). Note: the app also carries **no build flavors at all** today — a single `BASE_URL` dart-define replaces the earlier flavor idea, with multi-flavor deferred (see [ROADMAP](../../docs/ROADMAP.md) Phase 4).

> ‏البدائل المرفوضة: **تطبيق منفصل لكل دور** — طبقات مشتركة مُكرّرة وصيانة بمقدار ٢ إلى ٤ أضعاف. **مستودع Melos أحادي** — عبء حزم بلا حاجة فعلية؛ فريق واحد وتطبيق واحد. **نكهات بناء لكل دور** — لا تسمح بتبديل الدور وقت التشغيل (قد يكون المستخدم عميلاً ونشاطاً تجارياً معاً). وللعلم، لا يحمل التطبيق حالياً أي نكهات بناء إطلاقاً — يحل محلها تعريف `BASE_URL` واحد عبر dart-define، مع تأجيل تعدد النكهات (راجع ROADMAP المرحلة الرابعة).

- **Follow-ups:**
  - See [../features/role-selection-and-routing.md](../features/role-selection-and-routing.md) and [../features/provider-roles-backlog.md](../features/provider-roles-backlog.md).

> ‏المتابعات: راجع ملفي اختيار الدور والتوجيه، ومتأخرات أدوار مزوّد الخدمة.
