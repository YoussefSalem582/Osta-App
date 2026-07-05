# Contributing / المساهمة

Thanks for working on OSTA. Read [`AGENTS.md`](AGENTS.md) (canonical conventions) and [`ARCHITECTURE.md`](ARCHITECTURE.md) before your first change. Most features are specified by open GitHub epics — read the matching epic and its [feature doc](osta_readme_files/features/README.md) before building.

> ‏قبل أوّل تغيير اقرأ [`AGENTS.md`](AGENTS.md) (الاصطلاحات الأساسية) و[`ARCHITECTURE.md`](ARCHITECTURE.md). معظم الميزات مُحدَّدة في epics مفتوحة على GitHub — اقرأ الـ epic المطابق و[ملفّ الميزة](osta_readme_files/features/README.md) قبل البناء.

## Branch model / نموذج الفروع

- **`main`** — always stable and releasable. PRs target it.
- **Working branches** — one unit of work each, branched from `main`: `feat/<issue>-<slug>` (e.g. `feat/35-auth-email-password`), plus `fix/<scope>`, `refactor/<scope>`, `test/<scope>`, `docs/<scope>`, `chore/<scope>`.

Never commit directly to `main`. Never mix unrelated changes in one branch.

> ‏فرع `main` مستقرّ دائمًا وقابل للإصدار، وطلبات الدمج تستهدفه. كل فرع عمل مهمّة واحدة مُفرَّعة من `main` بصيغة `feat/<issue>-<slug>`. ممنوع الالتزام المباشر على `main` أو خلط تغييرات غير مترابطة في فرع واحد.

## Commits / الالتزامات

**Conventional Commits:** `type(scope): imperative summary`.

- Types: `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `style`, `chore` (matches the repo history — `feat(ui): …`, `test(theme): …`).
- Subject ≤ 72 chars; add a body when the *why* isn't obvious.
- Each commit is one logical change that compiles, passes `flutter analyze`, and keeps tests green.
- Inside a feature branch, commit layer by layer (domain → data → presentation → tests → docs).
- **No AI/agent attribution** — no `Co-authored-by:` or `Made-with:` trailers.
- Forbidden subjects: `WIP`, `update`, `misc`, `fixes`.

> ‏الالتزامات تتبع Conventional Commits؛ كل التزام تغيير منطقي واحد يمرّ بـ `flutter analyze` والاختبارات خضراء؛ ممنوع نسب أي أداة/وكيل في رسالة الالتزام؛ وممنوع رسائل مثل `WIP`/`update`/`misc`.

## Pull requests / طلبات الدمج

- PR base is `main`.
- **Description is bilingual — Arabic + English** (matches the epic style).
- Link the GitHub issue it closes/advances.
- After any meaningful change, update the docs (below).

> ‏قاعدة الـ PR هي `main`، ووصفه **ثنائي اللغة عربي + إنجليزي**، ويربط الـ issue المعنيّ، ويُحدّث التوثيق.

## Local quality gate / بوابة الجودة المحلية

Run before every commit:

```bash
flutter analyze
flutter test
dart format .
```

There is **no `build_runner`** — the project uses no codegen. Only localizations generate, via `flutter gen-l10n` (which also runs automatically on `flutter run`/`build`). After editing any ARB file, run `flutter gen-l10n`.

> ‏شغّل `flutter analyze` و`flutter test` و`dart format .` قبل كل التزام. **لا يوجد `build_runner`** — لا توليد كود؛ فقط الترجمة تُولَّد بـ `flutter gen-l10n` بعد أي تعديل على ملفّات ARB.

## Mandatory documentation / التوثيق الإلزامي

After every meaningful change, update:

1. [`CHANGELOG.md`](CHANGELOG.md) — entry under Unreleased (Keep a Changelog).
2. [`osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md`](osta_readme_files/DOCUMENTATION_UPDATE_SUMMARY.md) — dated entry at top.
3. [`osta_readme_files/CURRENT_STATUS.md`](osta_readme_files/CURRENT_STATUS.md) — status + metrics.
4. The relevant [feature doc](osta_readme_files/features/README.md) when a feature lands or its scope changes.

> ‏بعد أي تغيير مؤثّر حدّث `CHANGELOG.md`، و`DOCUMENTATION_UPDATE_SUMMARY.md`، و`CURRENT_STATUS.md`، وملفّ الميزة المعنيّ.

## Hard rules / قواعد صارمة

Never bypass design tokens (`AppSpacing`/`AppRadii`/`context.appColors`), never hardcode user-facing strings (use `context.l10n` + both ARB files), never store tokens in `SharedPreferences` (use `TokenStorage`), never call Dio directly (go through `ApiClient`), never add `Either`/`Result<T>`/`.fold()` or codegen packages without following a [`docs/ROADMAP.md`](docs/ROADMAP.md) phase. Full list: [`osta_readme_files/reference/COMMON_PITFALLS.md`](osta_readme_files/reference/COMMON_PITFALLS.md).

## Example graph / مثال للرسم البياني

```
*   Merge feat/29-design-system-theming into main (#65)
|\
| * feat(ui): shared components, EGP/number formatters, and component gallery
| * feat(theme): design tokens, Cairo typography, and persisted theme mode
|/
*   Merge feat/31-api-client-networking into main (#64)
|\
| * feat(network): Sanctum auth interceptor with 401 refresh-retry-once
| * feat(network): envelope-aware ApiClient with typed errors and pagination
|/
* feat: feature-first single-app scaffold (core, features, shared)
```
