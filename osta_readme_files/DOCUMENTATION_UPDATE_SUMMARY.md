# Documentation Update Summary

> [INDEX](INDEX.md) > Documentation Update Summary
>
> Dated log of documentation changes, newest first. Add an entry here after every meaningful change (see [`../AGENTS.md`](../AGENTS.md) § Mandatory Documentation).

## 2026-07-05 — `OSTA_plan.md` master build instructions for AI agents

Added [`../OSTA_plan.md`](../OSTA_plan.md) — a root-level, English, system-prompt-style plan that AI agents follow to deliver the 31 open epics on top of the existing M0 foundation.

> ‏أُضيف [`../OSTA_plan.md`](../OSTA_plan.md) — خطة بأسلوب موجّهات النظام (بالإنجليزية) في جذر المستودع يتبعها وكلاء الذكاء الاصطناعي لتسليم الملاحم المفتوحة الـ 31 فوق أساس M0 الحالي.

Contents: the 11 owner mandates (Clean Architecture + BLoC, dark/light, responsive, ar/en RTL, animations/transitions, reusable widgets + centralized colors/fonts/images/icons/text, `talker`, `skeletonizer`, document everything, offline-first, clean git graph with releases/tags); **four explicit amendments to the canon** — `talker_*` replaces `pretty_dio_logger`, `skeletonizer` for all loading states (overrides epic `shimmer` mentions), a new offline-first spec (`lib/core/offline/`: `sqflite` JSON-document cache + pending-operations queue + `SyncEngine` + `connectivity_plus`, with a per-feature cached/queued/online-only policy table), and a SemVer release/tag convention (`v0.<n>.0` per milestone, `v1.0.0` = MVP, annotated tags on `main`); source-of-truth precedence with a warning that the epics' stale codegen/Riverpod package stanza is superseded ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69)); and the milestone-by-milestone execution plan (M0 finish → M1…M5 → Shop/Home/Notifications → M6/Phase 2) with per-epic branch names, key ACs, endpoints, offline policies, and a global/per-epic/never package policy. Docs-only change — no code affected; a follow-up to sync `AGENTS.md` with the four amendments is noted in the plan's appendix.

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

> ‏بعد مراجعة الكود عقب إعادة الهيكلة "تأجيل أدوات Flutter المتقدّمة" ([PR #69](https://github.com/YoussefSalem582/Osta-App/pull/69))، صُحِّحت مجموعة التوثيق بالكامل ثم أُضيفت لها الترجمة العربية.

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
