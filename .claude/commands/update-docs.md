# Update the mandatory docs

Sync the three mandatory docs (and the feature doc, if a feature changed) after a code change, then remind about the bilingual PR description. Run this before opening a PR.

## Steps

1. **`CHANGELOG.md` — Unreleased**
   - Add an entry under `## [Unreleased]` in the right group (`Added` / `Changed` / `Fixed` / `Removed`). Create the heading if missing.
   - One concise line per user-visible or structural change. Keep newest at the top of its group.

2. **`osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md` — dated top entry**
   - Add a new entry at the **top**, dated today (`YYYY-MM-DD`).
   - Say what changed and list the files touched (relative paths).

3. **`osta_readme_files/CURRENT_STATUS.md` — status + metrics**
   - Update the status prose for the affected feature/area.
   - Refresh any metrics the change moved: dart file count, Cubits/BLoCs, repos, use-cases, pages, shared UI widgets, l10n key count, test file count.

4. **Feature doc — only if a feature changed**
   - Update the matching doc in `osta_readme_files/features/` (scope, status, endpoints). Don't invent scope beyond the feature's GitHub epic.

5. **Verify + PR reminder**
   - `flutter gen-l10n` (only if ARB files changed), then `flutter analyze` and `flutter test`.
   - `dart format .` if you touched Dart.
   - Reminder: the PR description must be **bilingual (Arabic + English)**, base branch `main`, conventional-commit title, and **no AI co-author trailers**.

## Notes

- Stack is plain Dart — **no `build_runner`**. Only l10n generates (`flutter gen-l10n`, also runs on `flutter run`/`build`). Don't reference `*.g.dart` / `*.freezed.dart` / `*.config.dart`.
- Reference files by relative path.
- Cross-links from a doc to the deferral plan use a relative path (e.g. from `osta_readme_files/` it is `../docs/ROADMAP.md`).
