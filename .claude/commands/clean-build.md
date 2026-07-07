# Clean Build

Reset the OSTA build from scratch and confirm the analyzer is green. macOS/zsh.

OSTA has **no codegen** — models are plain `Equatable`, DI is hand-written `get_it`, errors are a sealed `Failure`. The **only** generated code is l10n (`lib/core/l10n/`). So there is **no `build_runner` step** — do not run it. See [`docs/ROADMAP.md`](../../docs/ROADMAP.md) for the deferred-codegen plan.

Run these in order, stopping if any step fails:

1. `flutter clean` — remove `build/` and `.dart_tool/`.
2. `flutter pub get` — restore dependencies.
3. `flutter gen-l10n` — regenerate localizations from `lib/l10n/app_en.arb` + `app_ar.arb` into `lib/core/l10n/`.
4. `flutter analyze` — confirm zero issues (this is the green check).

**Do NOT run `dart run build_runner ...`** — there is no `freezed`/`json_serializable`/`injectable` in this project.

Report the final `flutter analyze` result. If it is not clean, list the issues; do not attempt fixes unless asked.
