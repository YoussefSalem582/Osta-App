# Onboarding / الإعداد الأولي

> [INDEX](../INDEX.md) > Onboarding
>
> Day-1 checklist for humans and AI agents picking up the codebase cold.

This is the day-1 checklist for anyone — human or AI agent — picking up the codebase cold. The stack is deliberately plain, readable Dart: no code generation beyond localizations, so you can be productive on day one even if you are new to Flutter.

> ‏دي قائمة اليوم الأول لأي حد — إنسان أو وكيل ذكاء اصطناعي — بيبدأ يشتغل على الكود من الصفر. المكدس مبني عن قصد بلغة Dart بسيطة وواضحة: مفيش أي توليد كود غير ملفات الترجمة، عشان تقدر تنتج من أول يوم حتى لو انت جديد على Flutter.

The advanced tooling (freezed, injectable, fpdart, build flavors) was **deferred, not rejected** — the phased plan to reintroduce it lives in [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

> ‏الأدوات المتقدمة (freezed و injectable و fpdart وتعدد الـ build flavors) اتأجلت، ماترفضتش — والخطة المرحلية لإرجاعها موجودة في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

## First commands / أوامر البداية

Four steps and you are running. There is no `build_runner` step — the only generated code is localizations.

> ‏أربع خطوات وتكون شغّال. مفيش خطوة `build_runner` — الكود الوحيد المولّد هو ملفات الترجمة.

```bash
# 1. Install packages
flutter pub get

# 2. Regenerate localizations (only generated code in the repo)
flutter gen-l10n

# 3. Analyze + test
flutter analyze
flutter test

# 4. Run the app
flutter run --dart-define=BASE_URL=https://osta.technology92.com/api/v1
```

There is a single `BASE_URL` dart-define — no `--flavor`, no `FLAVOR`. Multi-flavor builds are deferred (see [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md), Phase 4).

> ‏فيه تعريف واحد بس `BASE_URL` عن طريق dart-define — مفيش `--flavor` ولا `FLAVOR`. تعدّد الـ flavors مؤجَّل (شوف [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md)، المرحلة 4).

## Read these in order / اقرأ دول بالترتيب

Work through these top to bottom on your first day; each one builds on the last.

> ‏اقرأهم من فوق لتحت في أول يوم؛ كل واحد بيبني على اللي قبله.

| Step | File | Why |
|------|------|-----|
| 1 | [`../../README.md`](../../README.md) | Pitch, setup, CI. |
| 2 | [`../../AGENTS.md`](../../AGENTS.md) | Canonical conventions (the everything-doc). |
| 3 | [02_architecture.md](../guides/02_architecture.md) | Clean Architecture + BLoC + HTTP lifecycle. |
| 4 | [DELIVERY_PLAN.md](DELIVERY_PLAN.md) | What's built, what's next, who owns what. |
| 5 | [04_how_to_add_new_api.md](../guides/04_how_to_add_new_api.md) | The most common task. |
| 6 | [COMMON_PITFALLS.md](COMMON_PITFALLS.md) | Don't-X-do-Y — saves an hour. |
| 7 | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) | When something breaks. |
| 8 | [decisions/](../decisions/README.md) | Why the project is the way it is. |

## Current stage — set expectations / المرحلة الحالية — اضبط توقعاتك

The app is at **M0**: a solid foundation (manual DI, config, networking, theme, l10n scaffolding, 8 shared components, CI), but `lib/features/` is mostly **stub folders** — only `splash` and `role` have screens. Every feature is an open GitHub epic. **Read the epic + its feature doc before writing feature code** — see [DELIVERY_PLAN.md](DELIVERY_PLAN.md) and [../features/README.md](../features/README.md).

> ‏التطبيق في مرحلة **M0**: أساس متين (حقن تبعيات يدوي، إعدادات، طبقة شبكة، ثيم، هيكل ترجمة، 8 مكوّنات مشتركة، تكامل مستمر)، لكن `lib/features/` معظمه **مجلدات هيكلية** — بس `splash` و `role` عندهم شاشات. كل ميزة عبارة عن epic مفتوح على GitHub. **اقرأ الـ epic ووثيقة الميزة قبل ما تكتب كود الميزة** — شوف [DELIVERY_PLAN.md](DELIVERY_PLAN.md) و [../features/README.md](../features/README.md).

Errors follow a plain pattern: repositories **throw** a `sealed Failure` (`lib/core/error/failure.dart`) and callers use ordinary `try`/`catch` — no `Either`, no `.fold()`, no `Result<T>`. Models are plain `Equatable` classes with hand-written `fromJson`/`toJson`, and services are registered by hand in `lib/core/di/injection.dart`.

> ‏الأخطاء بتمشي بنمط بسيط: الـ repositories بترمي `sealed Failure` (`lib/core/error/failure.dart`) والمستدعِي بيستخدم `try`/`catch` عادي — مفيش `Either` ولا `.fold()` ولا `Result<T>`. الموديلات كلاسات `Equatable` عادية بـ `fromJson`/`toJson` مكتوبين باليد، والخدمات بتتسجّل يدويًا في `lib/core/di/injection.dart`.

## Where to look for X / فين تلاقي كل حاجة

The table maps a common need to the file that answers it.

> ‏الجدول بيربط كل احتياج شائع بالملف اللي بيجاوب عليه.

| You need to … | Open … |
|---------------|--------|
| Know what to build next | [DELIVERY_PLAN.md](DELIVERY_PLAN.md) + app tracker [#61](https://github.com/YoussefSalem582/Osta-App/issues/61) |
| Understand a feature | [../features/](../features/README.md) (matched to epics) |
| Add a feature | [03_how_to_add_new_feature.md](../guides/03_how_to_add_new_feature.md) |
| Wire an endpoint | [04_how_to_add_new_api.md](../guides/04_how_to_add_new_api.md) + [09_api_endpoints.md](../guides/09_api_endpoints.md) |
| Add/change a translation | [05_how_to_add_new_language.md](../guides/05_how_to_add_new_language.md) |
| Change theme/tokens | [06_how_to_change_theme_colors.md](../guides/06_how_to_change_theme_colors.md) + `lib/core/theme/` |
| Build a shared widget | [07_how_to_create_reusable_component.md](../guides/07_how_to_create_reusable_component.md) + `lib/shared/ui/` |
| Add a secret / env value | [08_security_and_environment.md](../guides/08_security_and_environment.md) |
| Write tests | [10_testing.md](../guides/10_testing.md) |
| Find the router | `lib/core/router/app_router.dart` |
| Find DI | `lib/core/di/injection.dart` |
| Find a BLoC | `lib/features/<feature>/presentation/bloc/` |
| See mockups | `design-assets` branch → `mockups/*.png` |
| See what changed | [`../../CHANGELOG.md`](../../CHANGELOG.md) + [DOCUMENTATION_UPDATE_SUMMARY.md](../DOCUMENTATION_UPDATE_SUMMARY.md) |

## Approved commands (no prompt needed for agents) / الأوامر المعتمدة

Agents may run these without asking. Note there is no `build_runner` command — only l10n is generated.

> ‏الوكلاء يقدروا يشغّلوا الأوامر دي من غير ما يسألوا. لاحظ إن مفيش أمر `build_runner` — بس الترجمة هي اللي بتتولّد.

| Command | Purpose |
|---------|---------|
| `flutter pub get` | Install packages |
| `flutter gen-l10n` | Regenerate localizations |
| `flutter analyze` | Static analysis |
| `flutter test` | Run tests |
| `dart format .` | Format (CI enforces) |

Anything else — `git push`, dependency upgrades, store/signing — needs explicit permission.

> ‏أي حاجة تانية — `git push` أو ترقية الاعتماديات أو التوقيع/النشر على المتجر — محتاجة إذن صريح.
