# Official Dart & Flutter Agent Skills — vendored / مهارات Dart وFlutter الرسمية

> Curated copy of the official **Agent Skills** published by the Flutter and Dart teams
> ([announcement](https://blog.flutter.dev/introducing-skills-for-dart-and-flutter-23837c6ec0ae) ·
> [docs](https://docs.flutter.dev/ai/agent-skills)). Each skill is a self-contained
> `SKILL.md` that Claude Code auto-discovers from this folder and loads on demand
> when a task matches its description.
>
> ‏نسخة منتقاة من «مهارات الوكيل» الرسمية التي نشرها فريقا Flutter وDart. كل مهارة ملفّ
> ‏`SKILL.md` مستقلّ يكتشفه Claude Code تلقائيًا من هذا المجلد ويحمّله عند الحاجة.

## Provenance / المصدر

| Upstream | Commit pinned | Installed |
|----------|---------------|-----------|
| [`flutter/skills`](https://github.com/flutter/skills) | `0d624f3` | 2026-07-05 |
| [`dart-lang/skills`](https://github.com/dart-lang/skills) | `8ce8492` | 2026-07-05 |

Files are copied **verbatim** from upstream — do not edit them locally; re-vendor instead.

## Precedence / الأسبقية

**[`AGENTS.md`](../../AGENTS.md) and [`CLAUDE.md`](../../CLAUDE.md) always win** where a
skill's generic advice conflicts with OSTA conventions. Known deltas:

- `dart-add-unit-test` shows a `mockito`/`build_runner` mocking example — OSTA has a
  **no-codegen** rule; use hand-written fakes or `http_mock_adapter` instead.
- `dart-collect-coverage` mentions `mockito` in passing — same rule applies.
- Skills that reference the `http` package in examples do not override the
  **`ApiClient`-only** networking rule (never call Dio — or any HTTP client — directly).

> ‏عند أي تعارض بين نصيحة عامة في مهارة واصطلاحات المشروع، فالأولوية دائمًا لـ
> ‏`AGENTS.md` و`CLAUDE.md`: لا توليد كود (استخدم بدائل يدوية أو `http_mock_adapter`)،
> ‏ولا اتصال شبكي إلا عبر `ApiClient`.

## Installed skills (14) / المهارات المثبّتة

### Flutter (8)

| Skill | Use for |
|-------|---------|
| `flutter-add-integration-test` | `integration_test` flows driven end-to-end |
| `flutter-add-widget-preview` | Interactive widget previews (`previews.dart`) |
| `flutter-add-widget-test` | `WidgetTester` component tests |
| `flutter-build-responsive-layout` | `LayoutBuilder`/`MediaQuery` adaptive UI |
| `flutter-fix-layout-issues` | RenderFlex overflows, unbounded constraints |
| `flutter-implement-json-serialization` | Hand-written `fromJson`/`toJson` (matches our no-codegen models) |
| `flutter-setup-declarative-routing` | `go_router` + `MaterialApp.router` (our router) |
| `flutter-setup-localization` | ARB + `l10n.yaml` + gen-l10n (our exact l10n mechanism) |

### Dart (6)

| Skill | Use for |
|-------|---------|
| `dart-add-unit-test` | `package:test`-style unit-test structure |
| `dart-collect-coverage` | Coverage + LCOV reports |
| `dart-fix-runtime-errors` | Stack-trace-driven runtime debugging |
| `dart-resolve-package-conflicts` | `pub get` version-conflict workflow |
| `dart-run-static-analysis` | `dart analyze` + `dart fix --apply` |
| `dart-use-pattern-matching` | Switch expressions & patterns (pairs with our `sealed Failure`) |

## Excluded on purpose (7) / المستبعَدة عمدًا

| Skill | Why excluded |
|-------|--------------|
| `flutter-use-http-package` | Teaches `package:http` — conflicts with the **`ApiClient`-only** rule (Dio under the hood) |
| `flutter-apply-architecture-best-practices` | Prescribes MVVM + `ChangeNotifier` ViewModels + `Result` wrappers — conflicts with **BLoC** and **errors are thrown, not returned** |
| `dart-generate-test-mocks` | `mockito` + `build_runner` codegen — conflicts with the **no-codegen** rule |
| `dart-migrate-to-checks-package` | Would invite migrating tests off `flutter_test` matchers — not wanted |
| `dart-build-cli-app` | CLI apps — irrelevant to this Flutter app |
| `dart-setup-ffi-assets` | FFI — irrelevant |
| `dart-use-ffigen` | FFI + codegen — irrelevant and conflicts with no-codegen |

> ‏استُبعدت سبع مهارات لأنها تخالف اصطلاحات المشروع (لا `http` مباشر بل `ApiClient`؛
> ‏BLoC لا MVVM؛ لا توليد كود) أو لا تخصّ تطبيق Flutter (CLI/FFI).

## Updating / التحديث

Re-vendor from upstream (keeps this curation):

```bash
git clone --depth 1 https://github.com/flutter/skills.git /tmp/flutter-skills
git clone --depth 1 https://github.com/dart-lang/skills.git /tmp/dart-skills
# copy only the 14 folders listed above into .claude/skills/, then refresh
# the pinned commits in the Provenance table and re-check the Excluded list
```

Upstream's own installer (`npx skills add flutter/skills --skill '*' --agent universal --yes`)
installs **all** skills into `.agents/skills/` — don't use it here; it bypasses this curation.
