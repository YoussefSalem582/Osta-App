# Documentation Update Summary

> [INDEX](INDEX.md) > Documentation Update Summary
>
> Dated log of documentation changes, newest first. Add an entry here after every meaningful change (see [`../AGENTS.md`](../AGENTS.md) § Mandatory Documentation).

## 2026-07-05 — Official Dart & Flutter agent skills vendored into `.claude/skills/`

Vendored a curated copy of the official Agent Skills published by the Flutter and Dart teams ([announcement](https://blog.flutter.dev/introducing-skills-for-dart-and-flutter-23837c6ec0ae) · upstream [`flutter/skills`](https://github.com/flutter/skills) @ `0d624f3`, [`dart-lang/skills`](https://github.com/dart-lang/skills) @ `8ce8492`). Claude Code auto-discovers each `SKILL.md` and loads it on demand.

> ‏أُدرجت نسخة منتقاة من «مهارات الوكيل» الرسمية لفريقي Flutter وDart في `.claude/skills/`؛ يكتشفها Claude Code تلقائيًا ويحمّلها عند الحاجة.

- **Installed (14)**: 8 Flutter (integration/widget tests, widget previews, responsive layout, layout debugging, hand-written JSON, go_router routing, ARB/gen-l10n localization) + 6 Dart (unit tests, coverage, runtime errors, package conflicts, static analysis, pattern matching).
- **Excluded (7)**: `flutter-use-http-package` (vs `ApiClient`-only rule), `flutter-apply-architecture-best-practices` (MVVM/`Result` vs BLoC + thrown `Failure`s), `dart-generate-test-mocks` + `dart-use-ffigen` (codegen vs no-codegen rule), `dart-migrate-to-checks-package`, `dart-build-cli-app`, `dart-setup-ffi-assets` (irrelevant).
- **Precedence**: skills are verbatim upstream copies; where generic advice conflicts with OSTA conventions, `AGENTS.md`/`CLAUDE.md` win — deltas and the re-vendor workflow documented in [`.claude/skills/README.md`](../.claude/skills/README.md).
- `CHANGELOG.md`, `CURRENT_STATUS.md`, and the `CLAUDE.md` "Where to look" table updated.

## 2026-07-05 — AI-agent config set (per-tool instruction files)

Added the per-tool agent scaffolding mirroring a proven layout, all adapted to OSTA's plain-Dart stack:

- **Root**: `CONTRIBUTING.md` (branch/commit/PR/quality-gate rules, bilingual), `ARCHITECTURE.md` (layers, data flow, DI, routing, adding a feature — bilingual), `CURSOR.md` (Cursor shim).
- **`.agents/`**: generic `AGENTS.md` shim + 8 scoped rules (`project-scope`, `dart-conventions`, `feature-architecture`, `bloc-patterns`, `api-integration`, `ui-design-system`, `security`, `documentation-updates`) + 3 project-tuned skills (`add-feature`, `add-api`, `add-language`).
- **`.claude/`**: 8 slash commands (`add-feature`, `add-api`, `add-language`, `new-screen`, `review`, `test`, `update-docs`, `clean-build`) + `settings.json` (approved-command allowlist).
- **`.codex/AGENTS.md`**, **`.github/copilot-instructions.md`**, **`.github/workflows/docs.yml`** (markdownlint + lychee link-check).
- **`.cursor/`**: 9 `.mdc` rules (the 8 above + `git-commits`) + skills mirror.

Every file encodes the real stack — sealed `Failure` + `try`/`catch` (no `Either`/`fold`), manual `get_it` (no `injectable`/`build_runner`), `ApiClient`/`ApiException`, no offline queue — and links to `AGENTS.md` + `docs/ROADMAP.md`. Verified: correct frontmatter, no stale-stack leakage, all relative links resolve.

## 2026-07-05 — Synced to the plain-Dart refactor + bilingual (EN/AR)

Re-checked the codebase after the "defer advanced Flutter tooling" refactor ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69)) and corrected the whole doc set, then made it bilingual.

> ‏بعد مراجعة الكود عقب إعادة الهيكلة "تأجيل أدوات Flutter المتقدّمة" ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69))، صُحّحت مجموعة التوثيق بالكامل ثم أُضيفت لها الترجمة العربية.

**Codebase reality now** (see [`docs/ROADMAP.md`](../docs/ROADMAP.md)): no `fpdart`/`Either`/`Result<T>` — a `sealed class Failure implements Exception` thrown with plain `try`/`catch`; no `freezed`/`json_serializable`/`injectable`/`build_runner` — plain `Equatable` models with hand-written `fromJson`/`toJson` and **manual** `get_it` registration; single `BASE_URL` dart-define (no `AppFlavor`/`FLAVOR`); `/gallery` component-gallery route removed; CI collapsed to one `format · analyze · test` job. The advanced tooling is **deferred, not rejected** — phased reintroduction plan in `docs/ROADMAP.md`.

> ‏**واقع الكود الآن** (راجع [`docs/ROADMAP.md`](../docs/ROADMAP.md)): لا يوجد `fpdart`/`Either`/`Result<T>` — بل `sealed class Failure implements Exception` يُرمى ويُلتقط بـ `try`/`catch` عادي؛ ولا يوجد `freezed`/`json_serializable`/`injectable`/`build_runner` — بل نماذج `Equatable` بسيطة بدوالّ `fromJson`/`toJson` مكتوبة يدويًا وتسجيل `get_it` **يدوي**؛ و`BASE_URL` واحد عبر dart-define (بلا `AppFlavor`/`FLAVOR`)؛ وحُذف مسار معرض المكوّنات `/gallery`؛ واختُصر الـ CI إلى مهمّة واحدة `format · analyze · test`. الأدوات المتقدّمة **مؤجّلة لا مرفوضة** — الخطة المرحلية في `docs/ROADMAP.md`.

**Doc changes**:
- `AGENTS.md` + `CLAUDE.md` — corrected (error/DI/model/config/CI/commands) and made bilingual; added a "Plain-Dart, No Codegen" section and ROADMAP pointers.
- `decisions/004` rewritten (sealed `Failure` + `try`/`catch`; fpdart deferred), `decisions/005` rewritten (no codegen; freezed/json_serializable/injectable deferred), `decisions/008` (single CI job).
- All guides, feature docs, and reference docs: stale codegen/fpdart/flavor/gallery/CI facts purged, ROADMAP linked, and Arabic (RTL) prose added alongside English (headings bilingual; identifiers/tables/endpoints stay English).
- `CHANGELOG.md` + `CURRENT_STATUS.md` updated.

## 2026-07-02 — Initial documentation set

Created the full documentation tree, mirroring the structure proven on a sibling project and grounded in the two GitHub issue trackers ([Osta-App](https://github.com/YoussefSalem582/Osta-App/issues) · [osta_backend](https://github.com/YoussefSalem582/osta_backend/issues)) plus the actual M0 codebase:

- **Root**: [`AGENTS.md`](../AGENTS.md) (canonical agent/contributor conventions), [`CLAUDE.md`](../CLAUDE.md) (Claude Code shim), [`CHANGELOG.md`](../CHANGELOG.md) (Keep a Changelog, seeded from the four merged M0 PRs).
- **Index & status**: [`INDEX.md`](INDEX.md) (task-oriented entry point + doc map), [`CURRENT_STATUS.md`](CURRENT_STATUS.md) (M0 snapshot + metrics + epic status).
- **Guides** ([guides/](guides/)): 01 folder structure · 02 architecture · 03 add a feature · 04 wire an API · 05 localization · 06 theme tokens · 07 reusable components · 08 security & environment · 09 API endpoint catalogue (from backend epics, with app-status column) · 10 testing · 11 backend ↔ app connectivity.
- **Feature docs** ([features/](features/README.md)): 22 docs matched 1:1 to the app epics (#28–#62) — bilingual overviews, mockup embeds from the `design-assets` branch, endpoint tables, planned architecture, testing expectations, cross-repo links.
- **Decisions** ([decisions/](decisions/README.md)): 8 ADRs (Clean Architecture + BLoC, single app multi-role, go_router role redirect, fpdart Either, codegen stack, Dio envelope + Sanctum, Arabic-first l10n, GitHub Actions CI).
- **Reference** ([reference/](reference/)): ONBOARDING, GLOSSARY, COMMON_PITFALLS, TROUBLESHOOTING, DELIVERY_PLAN (milestones, owners, cross-repo mirror, build order).

Docs-only change — no code or behaviour affected.
