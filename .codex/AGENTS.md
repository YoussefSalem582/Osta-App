# Codex CLI Instructions — Shim / طبقة تعليمات Codex

> **Canonical conventions live in [`../AGENTS.md`](../AGENTS.md).** OpenAI Codex CLI auto-discovers both that file (repo root) and this one. Read the canonical doc first; this file contains **only Codex-specific runtime guidance**.
>
> ‏الاصطلاحات الأساسية في [`../AGENTS.md`](../AGENTS.md) — اقرأه أولًا. هذا الملفّ يحوي فقط إرشادات التشغيل الخاصة بـ Codex.

## Codex runtime conventions / اصطلاحات تشغيل Codex

- **Approval mode**: default `auto-edit` for documentation, `suggest` for `lib/**`, `ios/**`, `android/**`. Never `full-auto` for native iOS/Android source.
- **Shell**: this project is developed on **macOS / zsh**. Use Unix shell syntax; quote paths (the repo lives under `/Volumes/...`). `&&`/`;` chaining is fine.
- **Network / commands**: Codex may run `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`, `dart format .` without prompting. Anything else (`gh`, `git push`, `curl`, `brew`, dependency changes) requires explicit user approval. **There is no `build_runner`** — the project uses no codegen.

## Codex-specific workflow tips / نصائح سير العمل

### Iterative edits

1. **Plan first** — a numbered list of files + intended changes before editing.
2. **Edit one layer at a time** — domain → data → presentation (the dependency rule). Never edit cross-layer simultaneously.
3. **Verify between layers** — run `flutter analyze` after each layer to catch contract mismatches early.
4. **Update docs last** — `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, `osta_readme_files/CURRENT_STATUS.md`.

### Tool selection

- **Prefer `apply_patch`** over shell `sed`/`awk` for edits — clean diffs.
- **Prefer `rg` (ripgrep)** over `grep`.
- **Use `flutter analyze`** (not `dart analyze`) as the project-wide lint check.
- `flutter gen-l10n` is the **only** generation step — run it after any ARB edit (it also runs automatically on `flutter run`/`build`).

## Skills (read by Codex) / المهارات

Codex reads universal-format `SKILL.md` files from [`../.agents/skills/`](../.agents/skills/) — three project-tuned skills (`add-feature`, `add-api`, `add-language`). Codex has no slash-command system; invoke a skill by reading its `SKILL.md` and following the steps inline.

## Hard constraints (DO NOT) / قيود صارمة

- Do NOT hardcode secrets, API URLs, hex colours, or pixel values in Dart. Use `AppConfig`, `context.appColors`, `AppSpacing`, `AppRadii`, `Theme.of(context).textTheme`.
- Do NOT use raw strings in UI — all user-facing text via `context.l10n.*` (both `app_en.arb` and `app_ar.arb`).
- Do NOT store auth tokens in `SharedPreferences` — use `TokenStorage` (`flutter_secure_storage`).
- Do NOT call Dio directly — go through `ApiClient`.
- Do NOT introduce `Either`/`Result<T>`/`.fold()` or codegen (`freezed`/`injectable`/`json_serializable`/`build_runner`) without following a [`../docs/ROADMAP.md`](../docs/ROADMAP.md) phase — errors are a sealed `Failure` thrown with `try`/`catch`; models and DI are hand-written.
- Do NOT push to remote or amend pushed commits without explicit user permission.
- Do NOT add `Co-authored-by:` / tool-attribution trailers to commit messages.

## Where to look / أين تبحث

| Need | File |
|------|------|
| Canonical project conventions | [`../AGENTS.md`](../AGENTS.md) |
| Deferred tooling & phased plan | [`../docs/ROADMAP.md`](../docs/ROADMAP.md) |
| Onboarding & doc-map | [`../osta_readme_files/INDEX.md`](../osta_readme_files/INDEX.md) |
| Troubleshooting recipes | [`../osta_readme_files/reference/TROUBLESHOOTING.md`](../osta_readme_files/reference/TROUBLESHOOTING.md) |
| Common pitfalls | [`../osta_readme_files/reference/COMMON_PITFALLS.md`](../osta_readme_files/reference/COMMON_PITFALLS.md) |
| Architecture decisions | [`../osta_readme_files/decisions/`](../osta_readme_files/decisions/README.md) |
