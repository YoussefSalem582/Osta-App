# Agent Instructions — Generic Shim / طبقة عامّة

> **Canonical conventions live in [`../AGENTS.md`](../AGENTS.md).** Read it first.
> This file is a thin shim for generic agents reading from `.agents/`. It contains only the rules/skills folder map; everything else (architecture, tokens, BLoC, API, DI, localization, security, docs requirements) lives in the canonical doc.
>
> ‏الاصطلاحات الأساسية في [`../AGENTS.md`](../AGENTS.md) — اقرأه أولًا. هذا الملفّ طبقة رفيعة للوكلاء العامّين تحوي فقط خريطة القواعد والمهارات.

## Scope / النطاق

- Edit files **only** inside this repo (`osta_app`). Do not touch the sibling backend repo.

## Rules (in this directory) / القواعد

Universal-format rules in [`./rules/`](./rules/) — any agent scanning this folder picks them up:

| Rule | Covers |
|------|--------|
| `project-scope` | What to edit / what's off-limits; approved commands |
| `dart-conventions` | Naming, plain-Dart (no codegen), formatting, lints |
| `feature-architecture` | Clean Architecture layers + dependency rule |
| `bloc-patterns` | BLoC/Cubit event/state conventions |
| `api-integration` | `ApiClient` envelope, `ApiResult`/`ApiException`, error flow |
| `ui-design-system` | Design tokens, shared components, RTL |
| `security` | Tokens, secrets, `--dart-define`, logging redaction |
| `documentation-updates` | The three docs to update after every change |

## Skills (in this directory) / المهارات

Project-tuned skills in [`./skills/`](./skills/) (universal `SKILL.md` format), tuned to OSTA's Clean Architecture + hand-written `ApiClient` + ARB pipeline:

- `add-feature` — scaffold a Clean Architecture feature (data/domain/presentation + manual DI + routing + l10n)
- `add-api` — wire a backend endpoint end-to-end through the `ApiClient` envelope
- `add-language` — add/update localization strings across `app_en.arb` + `app_ar.arb`

> **Note**: OSTA uses **no codegen** and has no `npx skills`-managed official skills — these three are the full set. Do not add `freezed`/`injectable`/`build_runner` skills without following a [`../docs/ROADMAP.md`](../docs/ROADMAP.md) phase.

## Where to look for everything else / أين تبحث

| Need | File |
|------|------|
| Project overview, architecture, tokens, BLoC, API, security | [`../AGENTS.md`](../AGENTS.md) |
| Deferred tooling & phased plan | [`../docs/ROADMAP.md`](../docs/ROADMAP.md) |
| Onboarding & doc-map | [`../osta_readme_files/INDEX.md`](../osta_readme_files/INDEX.md) |
| Troubleshooting recipes | [`../osta_readme_files/reference/TROUBLESHOOTING.md`](../osta_readme_files/reference/TROUBLESHOOTING.md) |
| Common pitfalls | [`../osta_readme_files/reference/COMMON_PITFALLS.md`](../osta_readme_files/reference/COMMON_PITFALLS.md) |
| Architecture decisions (ADRs) | [`../osta_readme_files/decisions/`](../osta_readme_files/decisions/README.md) |
