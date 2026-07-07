# Cursor Instructions — Shim / طبقة تعليمات Cursor

> **Canonical conventions live in [`AGENTS.md`](AGENTS.md).** Read it first.
> This file (plus the auto-attached rules in [`.cursor/rules/`](.cursor/rules/)) contains only Cursor-specific runtime guidance. Architecture, design tokens, BLoC, API, DI, localization, security, and roadmap pointers all live in the canonical doc.
>
> ‏الاصطلاحات الأساسية في [`AGENTS.md`](AGENTS.md) — اقرأه أولًا. هذا الملفّ (مع القواعد في [`.cursor/rules/`](.cursor/rules/)) يحوي فقط إرشادات التشغيل الخاصة بـ Cursor.

## Rules (auto-attached) / القواعد

Scoped `.mdc` rules in [`.cursor/rules/`](.cursor/rules/) attach automatically by file glob: `project-scope`, `dart-conventions`, `feature-architecture`, `bloc-patterns`, `api-integration`, `ui-design-system`, `security`, `documentation-updates`, `git-commits`. They mirror [`.agents/rules/`](.agents/rules/) — edit both, or edit `.agents/rules/` and regenerate.

## Skills / المهارات

Project-tuned skills live in [`.cursor/skills/`](.cursor/skills/) (`add-feature`, `add-api`, `add-language`) — the same content as [`.agents/skills/`](.agents/skills/). Invoke one by reading its `SKILL.md` and following the steps.

## Runtime rules / قواعد التشغيل

- **Read before edit.** Prefer targeted edits over rewrites.
- **Never bypass design tokens** — `AppSpacing`/`AppRadii`/`context.appColors`, not raw values.
- **Never hardcode user-facing strings** — `context.l10n.<key>` + both ARB files + `flutter gen-l10n`.
- **Never store tokens in `SharedPreferences`** — use `TokenStorage`.
- **Never call Dio directly** — go through `ApiClient`.
- **Errors are thrown, not returned** — sealed `Failure` + `try`/`catch`; no `Either`/`Result<T>`/`.fold()`.
- **No codegen** — plain `Equatable` models, manual `get_it`; no `build_runner`/`freezed`/`injectable` without a [`docs/ROADMAP.md`](docs/ROADMAP.md) phase.
- **Git**: never add `Co-authored-by:`/`Made-with:` trailers. Disable Cursor Settings → Agents → Attribution.
- **Shell**: macOS/zsh — Unix syntax; quote paths under `/Volumes/...`.
- After every meaningful change, update `CHANGELOG.md` + `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md` + `osta_readme_files/CURRENT_STATUS.md`.

## Where to look / أين تبحث

| Need | File |
|------|------|
| Canonical conventions | [`AGENTS.md`](AGENTS.md) |
| Deferred tooling & phased plan | [`docs/ROADMAP.md`](docs/ROADMAP.md) |
| Doc index | [`osta_readme_files/INDEX.md`](osta_readme_files/INDEX.md) |
| Pitfalls / troubleshooting | [`osta_readme_files/reference/COMMON_PITFALLS.md`](osta_readme_files/reference/COMMON_PITFALLS.md) · [`TROUBLESHOOTING.md`](osta_readme_files/reference/TROUBLESHOOTING.md) |
