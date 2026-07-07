# 🧱 How to Create a Reusable Component

> [INDEX](../INDEX.md) > How to Create a Reusable Component

Shared UI lives in `lib/shared/ui/`. Check the existing catalogue before building — half of "new" widgets already exist.

> ‏عناصر الواجهة المشتركة موجودة في `lib/shared/ui/`. راجع القائمة الحالية قبل ما تبني حاجة جديدة — نص "المكوّنات الجديدة" اللي بتفكّر فيها موجودة أصلًا.

---

## Existing catalogue / القائمة الحالية

The components below already ship in `lib/shared/ui/`. Reuse before you rebuild.

> ‏المكوّنات التالية موجودة بالفعل في `lib/shared/ui/`. أعد استخدامها قبل ما تعيد بناءها.

| Component | Purpose |
|---|---|
| `AppButton` | Primary / secondary / text variants; built-in loading spinner; icon + label |
| `AppTopBar` | AppBar wrapper, RTL-safe back button, consistent title style |
| `AppBottomNavBar` (+ `AppBottomNavItem`) | Material nav bar with badge support |
| `AppCard` | Card with token padding + optional tap |
| `AppTextField` | `TextFormField` wrapper (label, hint, error, obscure, keyboard type) |
| `AppBottomSheet` | `showModalBottomSheet` wrapper (title, scrollable, token padding) |
| `EmptyState` / `ErrorState` / `LoadingState` | Standard list/screen states (`status_states.dart`) |

Formatters (`shared/formatters/`): `EgpFormatter`, `NumberFormatter` (both `ar_EG`). Extension (`shared/extensions/`): `context.l10n`.

> ‏المنسّقات في `shared/formatters/`: `EgpFormatter` و `NumberFormatter` (الاتنين بلوكيل `ar_EG`). والامتداد في `shared/extensions/`: `context.l10n`.

There is no component gallery. A dev-only gallery page and its `/gallery` route were removed; browse the widgets and their tests directly instead. Reviewing components visually as part of a shared showcase is deferred — see the team plan in [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

> ‏لا يوجد معرض للمكوّنات. صفحة المعرض الخاصة بالمطوّرين ومسار `/gallery` بتاعها اتشالوا؛ تصفّح الودجت واختباراتها مباشرةً بدل كده. مراجعة المكوّنات بصريًا في معرض مشترك مؤجّلة — راجع خطة الفريق في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

---

## Conventions / القواعد

1. **Name it `App*`** and file it as `snake_case.dart` under `lib/shared/ui/`.
2. **Tokens only** — `AppSpacing`/`AppRadii`/`AppElevation`, `context.appColors`, `Theme.of(context).textTheme.*`. No raw colors/sizes ([06_how_to_change_theme_colors.md](06_how_to_change_theme_colors.md)).
3. **RTL-safe** — `EdgeInsetsDirectional`, `start`/`end`, no hardcoded `left`/`right`.
4. **l10n-ready** — take strings as params or use `context.l10n`; never hardcode display text.
5. **Stateless where possible**; expose a clean, minimal API (required params first).
6. **Add a widget test** under `test/shared/ui/` so the component stays reviewable and regression-proof.

The component is a plain Flutter widget — no code generation is involved. It carries no `@freezed`, `@JsonSerializable`, or `part '*.g.dart'` directives, and it needs no `build_runner` step. The only generated code in the repo is localization (`flutter gen-l10n`).

> ‏المكوّن مجرد ودجت Flutter عادية — مفيش أي توليد كود. مفيش `@freezed` ولا `@JsonSerializable` ولا `part '*.g.dart'`، ومش محتاج خطوة `build_runner`. الكود المُولَّد الوحيد في المشروع هو الترجمة (`flutter gen-l10n`).

---

## shared/ui vs feature widgets / المشترك مقابل ودجت الميزة

Decide where a widget belongs by who consumes it and whether it carries feature logic.

> ‏قرّر مكان الودجت حسب مين اللي بيستخدمها وهل بتحمل منطق خاص بالميزة ولا لأ.

- Goes in **`shared/ui/`** if two+ features would use it and it carries no feature logic (pure presentation).
- Goes in **`features/<x>/presentation/widgets/`** if it's specific to one feature or depends on that feature's entities/bloc.

When unsure, start in the feature; promote to `shared/ui/` on the second consumer.

> ‏لو مش متأكد، ابدأ داخل الميزة؛ وارفعها لـ `shared/ui/` أول ما تلاقي مستهلك تاني ليها.

---

## Tests / الاختبارات

Every shared widget gets a widget test. Cover rendering plus the interactions that matter (tap, loading, error, badge, and each state).

> ‏كل ودجت مشتركة لازم يكون ليها اختبار ودجت. غطِّ العرض بالإضافة للتفاعلات المهمة (الضغط، التحميل، الخطأ، الشارة، وكل حالة).

- Widget tests in `test/shared/ui/` (see existing `components_test.dart`, `navigation_test.dart`): render, interaction (tap/loading/error), badge/state. Tests use `flutter_test` with hand-written fakes — no mocking framework.
- Golden tests (light/dark × RTL/LTR), per the [design system epic (#29)](https://github.com/YoussefSalem582/Osta-App/issues/29) convention, are planned rather than wired up today — see [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

> ‏اختبارات الجولدن (فاتح/غامق × RTL/LTR)، حسب اتفاقية [epic نظام التصميم (#29)](https://github.com/YoussefSalem582/Osta-App/issues/29)، مخطّطة لكنها لسه مش متوصّلة النهارده — راجع [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

---

## Related / روابط ذات صلة

- [06_how_to_change_theme_colors.md](06_how_to_change_theme_colors.md) · [10_testing.md](10_testing.md) · [`../../AGENTS.md`](../../AGENTS.md) § Shared UI Components
