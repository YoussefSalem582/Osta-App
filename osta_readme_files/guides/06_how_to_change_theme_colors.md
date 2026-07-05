# 🎨 Theme & Design Tokens / الثيم ورموز التصميم

> [INDEX](../INDEX.md) > Theme & Design Tokens

All visual constants are tokens in `lib/core/theme/`. Never hardcode a color, spacing, radius, or `TextStyle`. See [ADR 001](../decisions/001-clean-architecture-bloc.md) for the design-system rationale and the [design system epic (#29)](https://github.com/YoussefSalem582/Osta-App/issues/29).

> ‏كل الثوابت البصرية عبارة عن رموز (tokens) موجودة في `lib/core/theme/`. ممنوع تكتب أي لون أو مسافة أو نصف قطر أو `TextStyle` بشكل ثابت في الكود. راجع [ADR 001](../decisions/001-clean-architecture-bloc.md) لمعرفة سبب اختيار نظام التصميم و[ملحمة نظام التصميم (#29)](https://github.com/YoussefSalem582/Osta-App/issues/29).

---

## Where tokens live / أماكن الرموز

The table below maps each theme file to what it holds.

> ‏الجدول التالي بيوضّح كل ملف من ملفات الثيم وإيه اللي جواه.

| File | Contents |
|---|---|
| `app_tokens.dart` | `AppSpacing`, `AppRadii`, `AppElevation` |
| `app_colors.dart` | `AppColors` — a `ThemeExtension`; brand seeds + semantic pairs; `context.appColors` |
| `app_theme.dart` | `AppTheme.light()` / `AppTheme.dark()` — Material 3 `ThemeData` |
| `app_typography.dart` | `AppTypography` — Cairo variable font, full `TextTheme` |
| `theme_mode_controller.dart` | `ThemeModeController` (Cubit) — persists the mode |

**Scales:**

- `AppSpacing`: `xs=4`, `sm=8`, `md=16`, `lg=24`, `xl=32`
- `AppRadii`: `sm=8`, `md=12`, `lg=16`, `pill=999`
- `AppElevation`: `none=0`, `low=1`, `medium=3`, `high=6`

---

## Colors / الألوان

Brand seeds: **green `#0E7A3B`** (primary seed) + **lime `#B2D235`**. `AppColors` is a `ThemeExtension` carrying semantic pairs (accent/onAccent, success/onSuccess, warning/onWarning) that differ per brightness, with `lerp`/`copyWith` for animation. Read them via:

> ‏بذور العلامة التجارية: الأخضر `#0E7A3B` (البذرة الأساسية) + الليموني `#B2D235`. الكلاس `AppColors` هو `ThemeExtension` بيحمل أزواج دلالية (accent/onAccent وsuccess/onSuccess وwarning/onWarning) بتختلف حسب السطوع، ومعاه `lerp`/`copyWith` علشان الأنيميشن. اقرأها كده:

```dart
final c = context.appColors;      // Theme.of(context).extension<AppColors>()!
container.color = c.accent;
```

Material roles (`primary`, `surface`, `error`, …) come from the seeded `ColorScheme` — use `Theme.of(context).colorScheme.*` for those.

> ‏الأدوار الخاصة بـ Material (زي `primary` و`surface` و`error`) بتيجي من `ColorScheme` المبني على البذرة — استخدم `Theme.of(context).colorScheme.*` للحاجات دي.

### Add a new color token / إضافة رمز لون جديد

The steps below are all plain-Dart edits — no code generation is involved.

> ‏الخطوات التالية كلها تعديلات Dart عادية — مفيش أي توليد كود (codegen) في الموضوع.

1. Add the field to `AppColors` (constructor + `lerp` + `copyWith`).
2. Provide **both** a light and a dark value where `AppTheme.light()`/`dark()` construct the extension.
3. Add a contrast assertion to `test/core/theme/contrast_test.dart` (WCAG) if it's a text/background pair.
4. Verify the change (see [Verify visually](#verify-visually--التحقق-البصري) below).

---

## Typography / الخطوط

Cairo is a **variable font**; `AppTypography` sets weights via `FontVariation.weight` per `TextTheme` slot — **do not** apply synthetic bold. Use `Theme.of(context).textTheme.titleMedium` etc., never an inline `TextStyle`.

> ‏خط Cairo خط متغيّر (variable font)؛ الكلاس `AppTypography` بيظبط الأوزان عن طريق `FontVariation.weight` لكل خانة في `TextTheme` — **ما تستخدمش** التخانة الصناعية (synthetic bold). استخدم `Theme.of(context).textTheme.titleMedium` وهكذا، وما تكتبش `TextStyle` مضمّن أبدًا.

---

## Theme mode / وضع الثيم

`ThemeModeController` (Cubit) persists the choice under `theme_mode` in `SharedPreferences` and drives `MaterialApp.router`'s `themeMode`. Call `setMode(ThemeMode)` to change it; `cycle()` steps through the modes for a dev/settings toggle.

> ‏الكلاس `ThemeModeController` (Cubit) بيحفظ الاختيار تحت المفتاح `theme_mode` في `SharedPreferences` وبيتحكم في `themeMode` بتاعة `MaterialApp.router`. استدعِ `setMode(ThemeMode)` علشان تغيّره، و`cycle()` بيلف على الأوضاع لزرار تبديل في الإعدادات أو أثناء التطوير.

---

## Verify visually / التحقق البصري

There is no component gallery route — it was removed with the rest of the deferred dev tooling (see [`docs/ROADMAP.md`](../../docs/ROADMAP.md)). To eyeball a token change, run the app and drive it to the screen you care about:

> ‏مفيش راوت لمعرض المكوّنات (component gallery) — اتشال مع باقي أدوات التطوير المؤجَّلة (راجع [`docs/ROADMAP.md`](../../docs/ROADMAP.md)). علشان تشوف تأثير أي تغيير في الرموز بعينك، شغّل التطبيق وروح للشاشة اللي يهمّك تشوفها:

```bash
flutter run --dart-define=BASE_URL=https://api.osta.dev/api/v1
```

Toggle light/dark via `ThemeModeController` (or the platform brightness) and switch the app to Arabic to check RTL. For a repeatable check, add a golden test — see [10_testing.md](10_testing.md).

> ‏بدّل بين الفاتح والغامق عن طريق `ThemeModeController` (أو سطوع النظام)، وحوّل التطبيق للعربي علشان تتأكد من اتجاه RTL. ولو عايز تحقُّق متكرِّر، ضيف اختبار golden — راجع [10_testing.md](10_testing.md).

A shared UI test at `test/shared/ui/components_test.dart` covers the components without a gallery.

> ‏فيه اختبار للواجهة المشتركة في `test/shared/ui/components_test.dart` بيغطّي المكوّنات من غير الحاجة لمعرض.

---

## Related / روابط ذات صلة

- [07_how_to_create_reusable_component.md](07_how_to_create_reusable_component.md) · [10_testing.md](10_testing.md) (golden tests) · [../reference/COMMON_PITFALLS.md](../reference/COMMON_PITFALLS.md) § Design tokens
