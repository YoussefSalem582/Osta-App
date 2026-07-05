# /add-language

Add or update a user-facing string across **both** ARB files and regenerate l10n.
Alias of the `add-language` skill — full workflow in
[`.agents/skills/add-language/SKILL.md`](../../.agents/skills/add-language/SKILL.md);
locale/formatters reference in
[`osta_readme_files/guides/05_how_to_add_new_language.md`](../../osta_readme_files/guides/05_how_to_add_new_language.md).

OSTA is Arabic-first / RTL-first: `app_en.arb` is the ARB template, `app_ar.arb` is the
default runtime locale. `nullable-getter: false`, so a key in `app_en.arb` that is
**missing from `app_ar.arb` is a compile error**. The generated `lib/core/l10n/` is the
only generated code — never hand-edit it.

## Steps

1. Add the key to `lib/l10n/app_en.arb` with an `@<key>` entry carrying a `description`.
2. Add the **same** key to `lib/l10n/app_ar.arb` (placeholder value ok, but it must exist).
3. Run `flutter gen-l10n` (also runs on `flutter run`/`build`).
4. Use it via `context.l10n.<key>` — never a string literal.
5. Money/numbers/dates → `EgpFormatter`/`NumberFormatter` (`lib/shared/formatters/app_formatters.dart`), not hand-formatting.
6. Keep layout direction-agnostic: `start`/`end` + `EdgeInsetsDirectional`, never `left`/`right`.
7. New whole locale → add `lib/l10n/app_<code>.arb` with every template key, then `flutter gen-l10n` (persisted runtime switch is open app #30).

## Checklist

- [ ] Key in both ARB files (`@<key>` description in `app_en.arb`).
- [ ] `flutter gen-l10n` run — no missing-key error.
- [ ] Used via `context.l10n.<key>`; money/numbers via formatters.
- [ ] Verified RTL (ar) + LTR (en); no `left`/`right`.
- [ ] `flutter analyze` clean; did NOT edit `lib/core/l10n/` by hand.
- [ ] Updated `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, `osta_readme_files/CURRENT_STATUS.md`.
