# 🌍 Localization Workflow / سير عمل التوطين

> [INDEX](../INDEX.md) > Localization Workflow

OSTA is **Arabic-first and RTL-first** (Egyptian market). English is the ARB template; Arabic is the default runtime locale. Zero hardcoded user-facing strings. See [ADR 007](../decisions/007-arabic-first-l10n.md).

> ‏تطبيق OSTA مبني على مبدأ "العربية أولاً" ومن اليمين لليسار أولاً (السوق المصري). ملف الـ ARB الإنجليزي هو القالب، والعربية هي اللغة الافتراضية وقت التشغيل. ممنوع تمامًا كتابة أي نص يظهر للمستخدم داخل الكود مباشرةً. راجع [ADR 007](../decisions/007-arabic-first-l10n.md).

---

## The ARB pipeline / خط أنابيب الـ ARB

الجدول التالي يوضّح أماكن ملفات التوطين ونقطة الوصول إليها.

| Piece | Location |
|---|---|
| Source strings (template) | `lib/l10n/app_en.arb` |
| Source strings (Arabic) | `lib/l10n/app_ar.arb` |
| Config | `l10n.yaml` |
| Generated output | `lib/core/l10n/app_localizations*.dart` (git-ignored) |
| Access helper | `context.l10n` (`lib/shared/extensions/context_ext.dart`) |

`l10n.yaml`: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, output to `lib/core/l10n`, class `AppLocalizations`, `nullable-getter: false`.

> ‏تحتوي إعدادات `l10n.yaml` على مجلد الـ ARB، وملف القالب `app_en.arb`، ووجهة الإخراج `lib/core/l10n`، والفئة `AppLocalizations`، مع `nullable-getter` مضبوطة على `false`.

The l10n output under `lib/core/l10n/` is the **only** generated code in this project — there is no `build_runner`, and no `*.g.dart` / `*.freezed.dart` / `injection.config.dart`. Everything else is plain, hand-written Dart. Codegen for models and DI is deferred, not rejected — see [the roadmap](../../docs/ROADMAP.md).

> ‏مخرجات التوطين تحت `lib/core/l10n/` هي الكود الوحيد المُولَّد في المشروع — لا يوجد `build_runner` ولا ملفات `*.g.dart` أو `*.freezed.dart` أو `injection.config.dart`. كل شيء آخر عبارة عن Dart عادي مكتوب باليد. توليد الكود للنماذج وحقن الاعتماديات مؤجَّل وليس مرفوضًا — راجع [خريطة الطريق](../../docs/ROADMAP.md).

> Because `nullable-getter` is **false**, a key present in `app_en.arb` but **missing from `app_ar.arb`** is a compile error — always add to both.

> ‏لأن `nullable-getter` مضبوطة على `false`، فإن أي مفتاح موجود في `app_en.arb` وغير موجود في `app_ar.arb` يُسبّب خطأ في الترجمة (compile error) — أضِف المفتاح دائمًا في الملفين معًا.

---

## Add or change a string / إضافة أو تعديل نص

1. Add the key to **both** ARB files (same key; Arabic value can be a placeholder if translation is pending, but it must exist):

> ‏أضِف المفتاح في **كلا** ملفي الـ ARB (نفس المفتاح؛ ويمكن أن تكون القيمة العربية مؤقتة لو الترجمة لسه ناقصة، لكن لازم تكون موجودة):

```jsonc
// app_en.arb
"bookNow": "Book now",
"@bookNow": { "description": "CTA on the center card" }
// app_ar.arb
"bookNow": "احجز الآن"
```

2. Regenerate:

> ‏أعِد التوليد:

```bash
flutter gen-l10n
```

3. Use it:

> ‏استخدمه:

```dart
Text(context.l10n.bookNow)
```

Never write `Text('Book now')` — Arabic users would see English and the RTL audit breaks ([../reference/COMMON_PITFALLS.md](../reference/COMMON_PITFALLS.md)).

> ‏لا تكتب `Text('Book now')` أبدًا — المستخدم العربي هيشوف إنجليزي وهيتكسر تدقيق الاتجاه من اليمين لليسار ([../reference/COMMON_PITFALLS.md](../reference/COMMON_PITFALLS.md)).

---

## Numbers, money, dates / الأرقام والأموال والتواريخ

Don't hand-format. Use the shared formatters (`lib/shared/formatters/app_formatters.dart`), which emit Arabic-Indic digits under `ar_EG`:

> ‏لا تُنسّق الأرقام يدويًا. استخدم المُنسّقات المشتركة (`lib/shared/formatters/app_formatters.dart`)، التي تُخرج الأرقام العربية الهندية تحت `ar_EG`:

```dart
EgpFormatter.format(1250.5, locale);   // "١٬٢٥٠٫٥٠ ج.م." (ar) / "EGP 1,250.50" (en)
NumberFormatter.compact(12500, locale); // "١٢٫٥ ألف" / "12.5K"
```

`EgpFormatter`/`NumberFormatter` pin bare `ar` → `ar_EG` and `en` → `en_EG` so Egypt conventions apply.

> ‏تُثبّت `EgpFormatter`/`NumberFormatter` اللغة `ar` المجردة على `ar_EG` و`en` على `en_EG` حتى تُطبَّق أعراف مصر.

---

## RTL / الاتجاه من اليمين لليسار

- Layouts must be direction-agnostic (`start`/`end`, not `left`/`right`; `EdgeInsetsDirectional`). Flutter derives direction from the locale.
- Arabic uses the Cairo font (configured in `AppTypography`).
- Verify both directions in a real screen and in golden tests (light/dark × RTL/LTR).

> ‏يجب أن تكون التخطيطات محايدة تجاه الاتجاه (استخدم `start`/`end` بدل `left`/`right`، و`EdgeInsetsDirectional`)؛ فلاتر يستنتج الاتجاه من اللغة. العربية تستخدم خط Cairo (المضبوط في `AppTypography`). تحقّق من الاتجاهين في شاشة فعلية وفي اختبارات الـ golden (فاتح/غامق × من اليمين لليسار/من اليسار لليمين).

---

## Add a whole new locale / إضافة لغة جديدة كاملة

1. Add `app_<code>.arb` with every key.
2. Ensure `supportedLocales` includes it (generated from the ARB set; confirm `MaterialApp.router` in `lib/app.dart` wires the generated `AppLocalizations.supportedLocales` + delegates).
3. `flutter gen-l10n`, then add a switcher entry.

> ‏أضِف ملف `app_<code>.arb` بكل المفاتيح، ثم تأكد أن `supportedLocales` تشمله (تُولَّد من مجموعة ملفات الـ ARB؛ راجع `MaterialApp.router` في `lib/app.dart` وتأكد أنه يربط `AppLocalizations.supportedLocales` المُولَّدة مع المفوّضات)، ثم شغّل `flutter gen-l10n` وأضِف عنصرًا في مبدّل اللغة.

---

## Runtime language switch (planned) / تبديل اللغة وقت التشغيل (مخطَّط له)

A persisted runtime switch + `Accept-Language` request interceptor is specified by [app #30](https://github.com/YoussefSalem582/Osta-App/issues/30) (still open). Store the choice in `SharedPreferences`; the backend localizes API `message`/validation by the header.

> ‏مبدّل لغة مُخزَّن وقت التشغيل مع معترِض طلبات `Accept-Language` محدَّد في [app #30](https://github.com/YoussefSalem582/Osta-App/issues/30) (ما زال مفتوحًا). احفظ اختيار المستخدم في `SharedPreferences`؛ والخلفية تُوطّن رسائل الـ API والتحقق بناءً على الترويسة.

---

## Related / روابط ذات صلة

- [06_how_to_change_theme_colors.md](06_how_to_change_theme_colors.md) (Cairo typography) · [04_how_to_add_new_api.md](04_how_to_add_new_api.md) (Accept-Language) · [ADR 007](../decisions/007-arabic-first-l10n.md)
