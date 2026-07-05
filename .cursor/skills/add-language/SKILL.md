---
name: add-language
description: Add or update localization strings across app_en.arb + app_ar.arb and regenerate. Use for any user-facing string.
---

# Add a Localization String

OSTA is **Arabic-first and RTL-first** (Egyptian market). English (`app_en.arb`) is
the ARB template; Arabic (`app_ar.arb`) is the default runtime locale. Zero hardcoded
user-facing strings — every visible string goes through `context.l10n.<key>`.

The generated output under `lib/core/l10n/` is the **only** generated code in this
project — there is no `build_runner`, no `*.g.dart`, no `*.freezed.dart`, no
`injection.config.dart`. Everything else is plain hand-written Dart (models are
`Equatable`, DI is manual `get_it`, errors are a sealed `Failure` thrown/caught).
Codegen for models/DI is deferred, not rejected — see [../../../docs/ROADMAP.md](../../../docs/ROADMAP.md).

Full workflow reference: [../../../osta_readme_files/guides/05_how_to_add_new_language.md](../../../osta_readme_files/guides/05_how_to_add_new_language.md).

## When to Use

- Adding any new user-facing string (button label, title, error message, empty state).
- Changing the wording of an existing string.
- Adding a whole new locale (e.g. French) — see the last instruction.
- Any time you'd otherwise write a literal like `Text('Book now')` — don't; localize it.

## Instructions

1. **Add the key to the template `lib/l10n/app_en.arb`**, with an `@<key>` metadata
   entry that has a `description` (context for translators):

   ```jsonc
   // lib/l10n/app_en.arb
   "bookNow": "Book now",
   "@bookNow": { "description": "CTA on the center card" }
   ```

2. **Add the SAME key to `lib/l10n/app_ar.arb`** (no `@` metadata needed there).
   `l10n.yaml` sets `nullable-getter: false`, so a key present in `app_en.arb` but
   **missing from `app_ar.arb` is a compile error**. The Arabic value may be a
   placeholder if translation is pending, but it must exist:

   ```jsonc
   // lib/l10n/app_ar.arb
   "bookNow": "احجز الآن"
   ```

3. **Regenerate** (also runs automatically on `flutter run`/`flutter build`):

   ```bash
   flutter gen-l10n
   ```

4. **Use it via the `context.l10n` extension** (`lib/shared/extensions/context_ext.dart`) —
   never a string literal:

   ```dart
   Text(context.l10n.bookNow)
   ```

5. **For money / numbers / dates, do NOT hand-format** — use the shared formatters in
   `lib/shared/formatters/app_formatters.dart`, which emit Arabic-Indic digits under
   `ar_EG`:

   ```dart
   EgpFormatter.format(1250.5, locale);    // "١٬٢٥٠٫٥٠ ج.م." (ar) / "EGP 1,250.50" (en)
   NumberFormatter.compact(12500, locale); // "١٢٫٥ ألف" / "12.5K"
   ```

6. **Keep layouts direction-agnostic (RTL-first)** — use `start`/`end` and
   `EdgeInsetsDirectional`, never `left`/`right`. Flutter derives direction from the
   locale; Arabic uses the Cairo font (configured in `AppTypography`).

7. **To add a whole new locale**: create `lib/l10n/app_<code>.arb` containing **every**
   key from the template, then `flutter gen-l10n`. `supportedLocales` is generated from
   the ARB set — confirm `MaterialApp.router` in `lib/app.dart` wires the generated
   `AppLocalizations.supportedLocales` + delegates, then add a switcher entry. (A
   persisted runtime language switch + `Accept-Language` interceptor is specified by
   open [app #30](https://github.com/YoussefSalem582/Osta-App/issues/30).)

## Post-Completion Checklist

- [ ] Key exists in **both** `lib/l10n/app_en.arb` (with `@<key>` description) and `lib/l10n/app_ar.arb`.
- [ ] `flutter gen-l10n` run; no missing-key compile error.
- [ ] String used via `context.l10n.<key>` — no hardcoded literals; money/numbers via `EgpFormatter`/`NumberFormatter`.
- [ ] Verified in both directions (RTL Arabic + LTR English); layout uses `start`/`end`, not `left`/`right`.
- [ ] `flutter analyze` clean.
- [ ] Did NOT edit generated `lib/core/l10n/` by hand.
- [ ] Updated `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, `osta_readme_files/CURRENT_STATUS.md`.
