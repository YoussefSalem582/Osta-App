# ADR 007 — Arabic-first ARB localization, RTL default

## Status

Accepted (2026-07-02, amended 2026-07-05)

## Context / السياق

OSTA targets the Egyptian market. The primary audience reads Arabic; the backend is Arabic-first (localizes `message`/validation by `Accept-Language`, ar default) and issues/PRs are bilingual. The UI must render correctly right-to-left and show Arabic-Indic digits for money/numbers. See the [localization epic (#30)](https://github.com/YoussefSalem582/Osta-App/issues/30).

> ‏تستهدف OSTA السوق المصري. الجمهور الأساسي يقرأ بالعربية، والـ backend عربي أولًا (يترجم رسالة `message` والتحقق حسب ترويسة `Accept-Language`، والعربية هي الافتراضي)، والـ issues والـ PRs ثنائية اللغة. لذلك يجب أن تُعرض الواجهة من اليمين إلى اليسار بشكل صحيح وأن تُظهر الأرقام العربية للمبالغ والأعداد.

## Decision / القرار

We will use Flutter's **ARB pipeline** (`flutter_localizations` + `intl`) with `app_en.arb` as the template and `app_ar.arb` alongside, **Arabic as the default locale**, and **RTL-first** layouts. Strings are accessed via `context.l10n`; zero hardcoded user-facing text. Money/numbers go through shared formatters (`EgpFormatter`/`NumberFormatter`) that pin bare `ar` → `ar_EG` for Arabic-Indic digits. Text uses the Cairo font. A persisted runtime language switch + an `Accept-Language` request interceptor are part of [#30](https://github.com/YoussefSalem582/Osta-App/issues/30).

> ‏سنستخدم مسار ARB في Flutter (`flutter_localizations` + `intl`) بجعل `app_en.arb` القالب و`app_ar.arb` بجانبه، مع العربية لغةً افتراضية وتخطيطات من اليمين إلى اليسار أولًا. تُقرأ النصوص عبر `context.l10n` دون أي نص ظاهر للمستخدم مكتوب مباشرةً في الكود. تمر المبالغ والأعداد عبر مُنسِّقات مشتركة (`EgpFormatter`/`NumberFormatter`) تُثبّت `ar` المجردة إلى `ar_EG` لإظهار الأرقام العربية. النصوص تستخدم خط Cairo. تبديل اللغة وقت التشغيل مع حفظه، ومُعترِض `Accept-Language`، جزء من [#30](https://github.com/YoussefSalem582/Osta-App/issues/30).

The ARB pipeline is the **one** piece of code generation we keep: `flutter gen-l10n` produces `AppLocalizations` under `lib/core/l10n/`. Everything else in the app is plain Dart — models are `Equatable` classes with hand-written `fromJson`/`toJson`, and dependencies are registered by hand in `get_it`. Broader codegen (`freezed`, `json_serializable`, `injectable`) was deliberately deferred; see [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

> ‏مسار ARB هو الجزء الوحيد من توليد الكود الذي نُبقيه: يُنتج `flutter gen-l10n` الصنف `AppLocalizations` تحت `lib/core/l10n/`. كل ما عدا ذلك في التطبيق هو Dart عادي — النماذج أصناف `Equatable` بدوال `fromJson`/`toJson` مكتوبة يدويًا، والاعتماديات تُسجَّل يدويًا في `get_it`. أُجّل توليد الكود الأوسع (`freezed` و`json_serializable` و`injectable`) عن قصد؛ انظر [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

## Consequences / النتائج

- **Positive / الإيجابيات:**
  - Correct experience for the primary audience out of the box; RTL is the default, not an afterthought.
  - Backend and app agree on locale via one header.
  - `nullable-getter: false` makes a missing Arabic key a compile error — translations can't silently fall back to English.

  > ‏تجربة صحيحة للجمهور الأساسي منذ البداية؛ الاتجاه من اليمين إلى اليسار هو الافتراضي لا إضافة لاحقة. يتفق الـ backend والتطبيق على اللغة عبر ترويسة واحدة. وإعداد `nullable-getter: false` يجعل غياب مفتاح عربي خطأً وقت التصريف، فلا تعود الترجمات بصمت إلى الإنجليزية.

- **Negative / السلبيات:**
  - Every string change touches two ARB files + a `gen-l10n` step.
  - Layouts must be written direction-agnostic (`start`/`end`, `EdgeInsetsDirectional`) — an easy thing to forget.

  > ‏كل تعديل على نص يمسّ ملفَّي ARB مع خطوة `gen-l10n`. ويجب كتابة التخطيطات مستقلة عن الاتجاه (`start`/`end` و`EdgeInsetsDirectional`)، وهو أمر يسهل نسيانه.

- **Alternatives rejected / بدائل مرفوضة:**
  - **`easy_localization`** — runtime JSON keys, weaker compile-time safety than generated getters.
  - **English-default** — wrong for this market; would make RTL the exception.

  > ‏`easy_localization`: مفاتيح JSON وقت التشغيل، وأمان أضعف وقت التصريف مقارنةً بالدوال المولَّدة. والإنجليزية افتراضيًا: خيار خاطئ لهذا السوق، إذ يجعل الاتجاه من اليمين إلى اليسار هو الاستثناء.

- **Follow-ups / متابعات:**
  - See [../guides/05_how_to_add_new_language.md](../guides/05_how_to_add_new_language.md).

  > ‏انظر [../guides/05_how_to_add_new_language.md](../guides/05_how_to_add_new_language.md).
