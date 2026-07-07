# ADR 001 — Clean Architecture + BLoC

## Status

Accepted (2026-07-02, amended 2026-07-05)

## Context / السياق

OSTA is one app hosting multiple role flows (customer, business, and later solo-mechanic + tow-truck) built by a **five-person team** ([owners in the issues](https://github.com/YoussefSalem582/Osta-App/issues): youssef, haidy, haneen, adel, roaa) against a large API surface (~30 backend epics). Parallel feature work needs a uniform, testable structure so any contributor can drop into any feature and find the same shape. State is non-trivial (async loads, realtime, offline-ish flows).

> ‏تطبيق OSTA تطبيق واحد يضم أكثر من مسار حسب الدور (العميل، النشاط التجاري، ولاحقًا الميكانيكي المستقل وسيارة السحب)، ويطوّره **فريق من خمسة أفراد** أمام سطح واجهة برمجية كبير (حوالي 30 epic في الـ backend). العمل المتوازي على المزايا يحتاج بنية موحّدة وقابلة للاختبار، بحيث يقدر أي مساهم يدخل على أي feature ويلاقي نفس الشكل. حالة التطبيق ليست بسيطة (تحميل غير متزامن، وقت حقيقي، وتدفقات شبه أوفلاين).

## Decision / القرار

We will use **Clean Architecture** — three layers per feature (`data` → `domain` ← `presentation`) with a strict dependency rule (domain is pure Dart, zero Flutter imports) — and **`flutter_bloc`** for state (BLoC for feature flows, Cubit for simple state). Value types (entities, events, states) use plain **`Equatable`** classes with hand-written fields — no codegen. Feature folders are pre-created as stubs so the layout is visible before code lands.

> ‏هنستخدم **Clean Architecture** — ثلاث طبقات لكل feature (`data` ← `domain` → `presentation`) بقاعدة اعتماد صارمة (الـ domain دارت خالص من غير أي استيراد لـ Flutter) — و**`flutter_bloc`** لإدارة الحالة (BLoC للتدفقات، وCubit للحالات البسيطة). أنواع القيم (الكيانات والأحداث والحالات) تستخدم كلاسات **`Equatable`** عادية بحقول مكتوبة يدويًا — من غير أي توليد كود. مجلدات المزايا متجهّزة كـ stubs مسبقًا علشان الشكل يبان قبل ما يوصل الكود.

## Consequences / النتائج

- **Positive:**
  - Uniform mental model across every feature; reviewers know where things go.
  - Domain is trivially unit-testable (no Flutter/Dio); repositories are the only place exceptions map to failures (a sealed `Failure`, caught with plain `try`/`catch`).
  - Presentation swaps freely (a screen redesign never touches domain).

> ‏الإيجابيات: نموذج ذهني موحّد لكل feature فالمراجعون يعرفون مكان كل حاجة؛ والـ domain سهل اختباره كوحدات (من غير Flutter أو Dio)، والـ repositories هي المكان الوحيد اللي تتحوّل فيه الاستثناءات إلى أعطال (`Failure` من نوع sealed تُلتقط بـ `try`/`catch` عادي)؛ وطبقة العرض تتبدّل بحرية (إعادة تصميم الشاشة ما تلمسش الـ domain).

- **Negative:**
  - Boilerplate per feature (entity + model + contract + impl + use case + bloc). We keep it hand-written and readable on purpose — no codegen — and lean on the add-feature guide instead. Advanced tooling (freezed / injectable) is **deferred, not rejected** — see [ADR 005](005-codegen-stack-injectable-freezed.md) and the phased plan in [../../docs/ROADMAP.md](../../docs/ROADMAP.md).
  - Overkill for the tiniest screens — Cubit is the pressure valve there.

> ‏السلبيات: في كود متكرر لكل feature (كيان + model + عقد + تنفيذ + use case + bloc)، وبنخليه مكتوب يدويًا ومقروء بشكل مقصود — من غير توليد كود — ونعتمد على دليل إضافة feature بدل كده. الأدوات المتقدمة (freezed / injectable) **مؤجَّلة مش مرفوضة** — راجع [ADR 005](005-codegen-stack-injectable-freezed.md) والخطة المرحلية في [../../docs/ROADMAP.md](../../docs/ROADMAP.md). وبالنسبة لأصغر الشاشات فالبنية دي زيادة عن اللزوم، والـ Cubit هو صمام الأمان هنا.

- **Alternatives rejected:**
  - **MVVM / provider-only** — less structure, harder to keep 5 people consistent.
  - **Feature-monolith (no layers)** — faster at first, unmaintainable at this scope.

> ‏البدائل المرفوضة: **MVVM / provider لوحده** — بنية أقل، وأصعب في الحفاظ على اتساق 5 أفراد. و**feature بلا طبقات (monolith)** — أسرع في البداية لكن غير قابل للصيانة على المقياس ده.

- **Follow-ups:**
  - The [auth feature (#35)](https://github.com/YoussefSalem582/Osta-App/issues/35) becomes the canonical reference; match it. See [../guides/02_architecture.md](../guides/02_architecture.md) and [../guides/03_how_to_add_new_feature.md](../guides/03_how_to_add_new_feature.md).

> ‏المتابعات: تصبح [ميزة المصادقة (#35)](https://github.com/YoussefSalem582/Osta-App/issues/35) هي المرجع القياسي؛ اتبعها. راجع [../guides/02_architecture.md](../guides/02_architecture.md) و[../guides/03_how_to_add_new_feature.md](../guides/03_how_to_add_new_feature.md).
