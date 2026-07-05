---
description: "Design tokens, shared components, RTL"
globs: "lib/**/*.dart"
alwaysApply: false
---

# UI & Design System

Osta is **Arabic-default, RTL-first**. Every visual value comes from a token; every reusable widget comes from `lib/shared/ui/`. Check this file before hardcoding a number or building a component.

## Never hardcode

| Need | Use | Never |
|------|-----|-------|
| Color | `context.appColors.<role>` (semantic) or `Theme.of(context).colorScheme.<role>` (primary/surface/error) | `Color(0xFF...)`, `Colors.*` in widgets |
| Spacing / padding | `AppSpacing.md` etc. | raw `16`, `EdgeInsets.all(16)` |
| Corner radius | `AppRadii.md` etc. | raw `BorderRadius.circular(12)` |
| Elevation / shadow | `AppElevation.low` etc. | raw `elevation: 1` |
| Text style | `Theme.of(context).textTheme.<style>` (Cairo via `AppTypography`) | inline `TextStyle(fontSize:...)`, `GoogleFonts.*` |
| Asset path | `AppImages.<name>` (`lib/core/constants/app_images.dart`) | raw `'assets/...'` string |
| Money | `EgpFormatter.format(amount, locale: ...)` | manual `'$x EGP'` |

Hex colors live in **exactly one place**: `lib/core/theme/app_colors.dart`. Nowhere else.

## Token scales

```dart
AppSpacing   xs=4  sm=8  md=16  lg=24  xl=32          // app_tokens.dart
AppRadii     sm=8  md=12 lg=16  pill=999
AppElevation none=0 low=1 medium=3 high=6
```

Colors — `AppColors` is a `ThemeExtension` (access via `context.appColors`):
- Brand: `AppColors.brandGreen` (#0E7A3B seed), `AppColors.brandLime` (#B2D235).
- Semantic roles: `accent`/`onAccent`, `success`/`onSuccess`, `warning`/`onWarning` (each defined for `light` **and** `dark`).
- Everything else (primary/secondary/surface/error/onX) comes from the M3 `ColorScheme` seeded from `brandGreen` — use `Theme.of(context).colorScheme`.

Typography — `AppTypography.textTheme(base)` maps the whole M3 scale onto the bundled **Cairo** variable font (`fontFamily = 'Cairo'`, covers Arabic + Latin). There is **no `AppTextStyles` class** — always read from `Theme.of(context).textTheme.*`.

## Shared UI catalogue — check before building

All in `lib/shared/ui/`:

| Widget | For |
|--------|-----|
| `AppButton` | buttons — `AppButtonVariant.{primary,secondary,text}`, has `loading` state |
| `AppTopBar` | app bar (implements `PreferredSizeWidget`) |
| `AppBottomNavBar` (+ `AppBottomNavItem`) | bottom navigation |
| `AppCard` | elevated/outlined content container |
| `AppTextField` | form inputs |
| `AppBottomSheet` | modal bottom sheets |
| `EmptyState` / `ErrorState` / `LoadingState` | async/list placeholder states (`status_states.dart`) |

> The dev-only `/gallery` route and `ComponentGalleryPage` were **removed** — do not reference them.

Missing a variant? Extend the existing widget; don't fork a one-off.

## RTL rules (Arabic-first)

- **Arabic is the default locale**; layouts must mirror correctly.
- Use **`EdgeInsetsDirectional`** (`start`/`end`/`top`/`bottom`), never `EdgeInsets.only(left/right:)`.
- Use directional properties: `AlignmentDirectional`, `PositionedDirectional`, `start`/`end` — never `left`/`right`.
- User-facing text via `context.l10n.<key>` only (both ARB files + `flutter gen-l10n`) — never hardcode strings.
- Numbers/money via `EgpFormatter` / `NumberFormatter` (`ar_EG` → Arabic-Indic digits).

## Adding a color token

A new semantic role must be added to **both** `AppColors.light` and `AppColors.dark` (+ the constructor, `copyWith`, and `lerp`), then covered by a WCAG contrast test — see `test/core/theme/contrast_test.dart`.
