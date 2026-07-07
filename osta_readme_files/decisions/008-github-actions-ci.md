# ADR 008 — GitHub Actions for CI

## Status / الحالة

Accepted (2026-07-02, amended 2026-07-05)

## Context / السياق

Every PR should be gated on formatting, static analysis, and tests. The repo is on GitHub; there are no store deployments yet (the app is pre-release at `1.0.0+1`). We want the quality gate free and close to where PRs live ([scaffolding epic #28](https://github.com/YoussefSalem582/Osta-App/issues/28)).

> ‏كل Pull Request لازم يعدّي على بوابة جودة: التنسيق، والتحليل الساكن، والاختبارات. المستودع على GitHub، ولسه مفيش أي نشر على المتاجر (التطبيق قبل الإصدار عند `1.0.0+1`). عايزين بوابة الجودة تكون مجانية وقريبة من المكان اللي فيه الـ PRs.

The codebase was deliberately simplified for a team new to Flutter — no codegen, no build flavors — so the CI pipeline was simplified to match. Platform build jobs and multi-flavor builds are deferred, not rejected; the phased plan lives in [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

> ‏الكود اتبسّط عن قصد لفريق جديد على Flutter — من غير codegen، ومن غير build flavors — فبالتالي خطّ الـ CI اتبسّط عشان يماشيه. مهام بناء المنصّات والبناء متعدّد الـ flavors مؤجّلة، مش مرفوضة؛ الخطة المرحلية موجودة في [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

## Decision / القرار

We will use **GitHub Actions** (`.github/workflows/ci.yml`) with a **single** job named "format · analyze · test" on Ubuntu. It runs `flutter pub get` → `flutter gen-l10n` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`. Flutter is pinned to **3.44.1**; the single `BASE_URL` dart-define is injected where needed.

> ‏هنستخدم **GitHub Actions** (`.github/workflows/ci.yml`) بمهمة **واحدة** اسمها "format · analyze · test" على Ubuntu. بتشغّل `flutter pub get` ثم `flutter gen-l10n` ثم `dart format --set-exit-if-changed` ثم `flutter analyze` ثم `flutter test`. إصدار Flutter مثبّت على **3.44.1**؛ ويتم حقن الـ dart-define الوحيد `BASE_URL` حيث يلزم.

There is **no `build_runner` step** — l10n is the only generated code, and `flutter gen-l10n` produces it. There are **no `build-android` / `build-ios` jobs** — platform builds and a signing pipeline are deferred to [../../docs/ROADMAP.md](../../docs/ROADMAP.md) Phase 4.

> ‏مفيش خطوة `build_runner` — الـ l10n هو الكود الوحيد المُولَّد، و`flutter gen-l10n` هو اللي بيولّده. ومفيش مهام `build-android` أو `build-ios` — بناء المنصّات وخطّ التوقيع مؤجّلين للمرحلة الرابعة في [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

## Consequences / النتائج

- **Positive:**
  - Free for the repo, native PR integration, no external CI account.
  - A red format/analyze/test blocks the PR; the pipeline is fast on a single Linux runner.
  - Nothing to regenerate in CI beyond l10n — no codegen to drift or break the build.
- **Negative:**
  - Platform builds are not proven in CI yet — a change that compiles on the runner could still break an Android/iOS build. That coverage is future work.
- **Alternatives rejected:**
  - **Codemagic / Bitrise** — better for signed store deploys, but heavier than needed pre-release; revisit when publishing nears.
  - **No CI** — unacceptable for a 5-person team on one branch.
- **Follow-ups:**
  - Add platform build jobs, then a signing + store-deploy pipeline (Actions + fastlane, or Codemagic), when the app approaches release. See [../../docs/ROADMAP.md](../../docs/ROADMAP.md) Phase 4, [../guides/10_testing.md](../guides/10_testing.md), and [../guides/08_security_and_environment.md](../guides/08_security_and_environment.md).

> ‏النتائج باختصار: مجاني ومدمج مع الـ PRs وسريع على مشغّل Linux واحد، ومفيش codegen يبوّظ البناء. في المقابل بناء المنصّات لسه مش مُغطّى في الـ CI. اترفض Codemagic/Bitrise لأنهم أتقل من اللازم قبل الإصدار، ورُفض غياب الـ CI تمامًا. المتابعة: نضيف مهام بناء المنصّات ثم خطّ توقيع ونشر لمّا نقرب من الإصدار (المرحلة الرابعة في docs/ROADMAP.md).
