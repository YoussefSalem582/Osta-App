# Claude Code Instructions — Shim / طبقة تعليمات Claude Code

> **Canonical conventions live in [`AGENTS.md`](AGENTS.md).** Read it first.
> This file contains **only Claude-Code-specific runtime guidance**. Architecture, design tokens, BLoC, API, DI, localization, security, and roadmap pointers all live in the canonical doc.
>
> ‏الاصطلاحات الأساسية في [`AGENTS.md`](AGENTS.md) — اقرأه أولًا. هذا الملفّ يحوي فقط إرشادات التشغيل الخاصة بـ Claude Code.

## Response Guidelines / إرشادات الردّ

- Be concise — lead with the action or answer.
- Reference files with relative paths (e.g. `lib/core/network/api_client.dart`).
- One task at a time — complete it fully before moving on.
- After every meaningful change: update `CHANGELOG.md`, `osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`, and `osta_readme_files/CURRENT_STATUS.md`.

> ‏كن مختصرًا وابدأ بالإجراء أو الجواب؛ أشِر إلى الملفّات بمسارات نسبية؛ مهمّة واحدة في كل مرّة؛ وبعد أي تغيير مؤثّر حدّث ملفّات التوثيق الثلاثة.

## Environment / البيئة

- **Platform**: macOS (zsh) — Unix shell syntax; quote paths (repo lives under `/Volumes/files/...`).
- **Flutter**: SDK on PATH; CI pins Flutter 3.44.1.
- **No codegen**: the project uses **no `build_runner`** — models are plain `Equatable`, DI is manual `get_it`, errors are a `sealed Failure` (see [`docs/ROADMAP.md`](docs/ROADMAP.md) for the deferred codegen plan). Only l10n is generated, and `flutter gen-l10n` runs automatically on `flutter run`/`build`.
- **Approved commands** (no prompt needed): `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`, `dart format .`
- **Run the app**: `flutter run --dart-define=BASE_URL=https://api.osta.dev/api/v1` (single `BASE_URL`; no `--flavor`).

## Tool-use rules / قواعد استخدام الأدوات

- **Read before edit** — always.
- **Never bypass design tokens** — `AppSpacing`/`AppRadii`/`context.appColors`, not raw values.
- **Never hardcode user-facing strings** — `context.l10n.<key>` + both ARB files + `flutter gen-l10n`.
- **Never store tokens in SharedPreferences** — use `TokenStorage`.
- **Never call Dio directly** — go through `ApiClient`.
- **Errors are thrown, not returned** — `sealed Failure` + `try`/`catch`; there is no `Either`/`Result<T>`/`.fold()`.
- **No codegen** — do not add `freezed`/`injectable`/`json_serializable`/`build_runner` without following a [`docs/ROADMAP.md`](docs/ROADMAP.md) phase; models are hand-written, DI is registered by hand.
- **Never edit generated l10n** (`lib/core/l10n/`) — regenerate instead.
- **Before building a feature**: read its epic + feature doc (`osta_readme_files/features/`) — most features are stubs specified by open GitHub epics; don't invent scope.
- No interactive commands (`git rebase -i` etc.); pre-fill all args.
- No AI attribution in commits.

## Where to look / أين تبحث

| Need | File |
|------|------|
| Project conventions (everything-doc) | [`AGENTS.md`](AGENTS.md) |
| Official Dart/Flutter agent skills (curated, auto-discovered) | [`.claude/skills/README.md`](.claude/skills/README.md) |
| Deferred tooling & phased plan | [`docs/ROADMAP.md`](docs/ROADMAP.md) |
| Doc index & task map | [`osta_readme_files/INDEX.md`](osta_readme_files/INDEX.md) |
| What to build next (milestones/owners) | [`osta_readme_files/reference/DELIVERY_PLAN.md`](osta_readme_files/reference/DELIVERY_PLAN.md) |
| Endpoint catalogue | [`osta_readme_files/guides/09_api_endpoints.md`](osta_readme_files/guides/09_api_endpoints.md) |
| Pitfalls / troubleshooting | [`osta_readme_files/reference/COMMON_PITFALLS.md`](osta_readme_files/reference/COMMON_PITFALLS.md) · [`TROUBLESHOOTING.md`](osta_readme_files/reference/TROUBLESHOOTING.md) |
| Why-decisions (ADRs) | [`osta_readme_files/decisions/`](osta_readme_files/decisions/) |
