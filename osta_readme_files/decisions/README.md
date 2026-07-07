# Architecture Decision Records / سجلّات قرارات المعمارية

> [INDEX](../INDEX.md) > Decisions
>
> Short markdown files capturing **why** a design choice was made. Format follows [Michael Nygard's ADR template](https://github.com/joelparkerhenderson/architecture-decision-record): Context → Decision → Consequences. Several of these were decided during M0 (see git history) and are documented retroactively.

Short markdown files capturing **why** a design choice was made — not how the code works, but the reasoning and the alternatives weighed at the time.

> ‏ملفّات markdown قصيرة توثّق **لماذا** اتُّخذ كل قرار تصميمي — مش إزاي الكود شغّال، لكن المنطق والبدائل اللي اتوزنت وقتها.

Some of these ADRs were **amended on 2026-07-05** to match the deferral refactor (PR #69), which removed the advanced Flutter tooling in favour of plain, readable Dart. The original decision dates stay `2026-07-02`; the phased plan to reintroduce the deferred tooling lives in [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

> ‏بعض السجلّات دي **اتعدّلت في 2026-07-05** عشان تطابق إعادة الهيكلة (PR #69) اللي شالت أدوات Flutter المتقدّمة لصالح Dart بسيط وسهل القراءة. تواريخ القرارات الأصلية فضلت `2026-07-02`؛ والخطة المرحلية لإعادة إدخال الأدوات المؤجّلة موجودة في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

## Index / الفهرس

The table below lists every ADR with its current status. Titles for 004, 005, and 008 reflect the amended decisions.

> ‏الجدول التالي يسرد كل سجلّ ADR بحالته الحالية. عناوين 004 و005 و008 بتعكس القرارات بعد التعديل.

| # | Title | Status | Date |
|---|-------|--------|------|
| [001](001-clean-architecture-bloc.md) | Clean Architecture + BLoC | Accepted | 2026-07-02 |
| [002](002-single-app-multi-role-shells.md) | Single app hosting all roles (no monorepo) | Accepted | 2026-07-02 |
| [003](003-go-router-role-redirect.md) | GoRouter with role-based redirect + StatefulShellRoute | Accepted | 2026-07-02 |
| [004](004-fpdart-either-error-handling.md) | Sealed `Failure` + try/catch (fpdart deferred) | Accepted (amended 2026-07-05) | 2026-07-02 |
| [005](005-codegen-stack-injectable-freezed.md) | No codegen: plain Equatable + manual get_it (freezed/injectable deferred) | Accepted (amended 2026-07-05) | 2026-07-02 |
| [006](006-dio-envelope-client-sanctum.md) | Dio behind an envelope-aware ApiClient + Sanctum tokens | Accepted | 2026-07-02 |
| [007](007-arabic-first-l10n.md) | Arabic-first ARB localization, RTL default | Accepted | 2026-07-02 |
| [008](008-github-actions-ci.md) | GitHub Actions for CI (single analyze + test job) | Accepted (amended 2026-07-05) | 2026-07-02 |

## Template / القالب

Copy this when adding a new ADR. Number sequentially (009, 010, …).

> ‏انسخ القالب ده لما تضيف سجلّ ADR جديد. رقّمه بالتسلسل (009، 010، …).

```markdown
# ADR NNN — Title

## Status

[Proposed | Accepted | Deprecated | Superseded by ADR-XXX] (YYYY-MM-DD)

## Context

What problem are we solving? What forces are at play (technical, team,
project-local)? 2–4 sentences.

## Decision

What did we decide? Phrase as a direct statement: "We will …". 2–4 sentences.

## Consequences

- **Positive:** …
- **Negative:** …
- **Alternatives rejected:** … (with why)
- **Follow-ups:** …
```
