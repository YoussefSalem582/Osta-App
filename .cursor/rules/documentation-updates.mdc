---
description: "The docs to update after every change"
globs: "**/*.md"
alwaysApply: false
---

# Documentation Updates

After **every meaningful change** (feature landed, behavior changed, deps/config touched), update the docs below **in the same PR**. Canonical rules: [`../../AGENTS.md`](../../AGENTS.md) § Mandatory Documentation.

## The four updates

| # | File | What to write |
|---|------|---------------|
| 1 | [`../../CHANGELOG.md`](../../CHANGELOG.md) | Keep a Changelog format — add a bullet under `## [Unreleased]` (Added / Changed / Fixed / Removed). |
| 2 | [`../../osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`](../../osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md) | New **dated entry at the top** (newest first): date + one-line what/why. |
| 3 | [`../../osta_readme_files/CURRENT_STATUS.md`](../../osta_readme_files/CURRENT_STATUS.md) | Bump status + metrics (dart file count, pages, cubits, tests, feature status). |
| 4 | The relevant **feature doc** | When a feature lands or changes → update its doc under [`../../osta_readme_files/features/`](../../osta_readme_files/features/). |

## Rules

- All four when a **feature** lands. Docs 1–3 for any other meaningful change.
- **Skip** for trivial no-behavior edits (typo, comment, formatting-only).
- Keep entries **short**: one line each, present-tense, no filler.
- Update docs **as part of the change**, not a follow-up PR.

## PR description — bilingual

Every PR description is **AR + EN**. State what changed and why in both. Conventional-commit title; **no AI co-author trailers**.

## Also update when relevant

- Deferred-tooling / phased-plan changes → [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).
- New/changed endpoint → endpoint catalogue [`../../osta_readme_files/guides/09_api_endpoints.md`](../../osta_readme_files/guides/09_api_endpoints.md).
- Architectural decision → new ADR under [`../../osta_readme_files/decisions/`](../../osta_readme_files/decisions/).
