# 🧪 Testing / الاختبارات

> [INDEX](../INDEX.md) > Testing

Testing conventions and the current suite. CI gates every PR on format → analyze → **test** in a single job.

> ‏اصطلاحات الاختبار ومجموعة الاختبارات الحالية. الـ CI يفحص كل PR على مرحلة format ثم analyze ثم **test** في وظيفة واحدة.

---

## Current suite (M0) / مجموعة الاختبارات الحالية

11 files, ~32 cases.

> ‏عدد ملفات الاختبار 11 ملف وتغطي حوالي 32 حالة.

الجدول التالي يوضح المناطق المُغطّاة وملفات كل منها.

| Area | File(s) | Covers |
|---|---|---|
| Networking | `core/network/api_client_test.dart` | envelope parsing, error mapping, 401 retry, pagination |
| | `core/network/auth_interceptor_test.dart` | token attach, 401 refresh, queued refresh, token rotation |
| | `core/network/social_token_exchange_test.dart` | social exchange flow |
| | `core/network/fakes.dart` | `FakeDio`, `FakeTokenStorage` helpers |
| Theme | `core/theme/theme_mode_controller_test.dart` | load / set / persist |
| | `core/theme/contrast_test.dart` | WCAG contrast |
| Shared UI | `shared/ui/components_test.dart` | button loading, text-field error, status states |
| | `shared/ui/navigation_test.dart` | top bar back, nav bar selection, badge |
| Formatters | `shared/formatters/app_formatters_test.dart` | EGP format, compact, Arabic/Latin digits |
| Model | `auth_token_model_test.dart` | hand-written dual-token JSON (`fromJson`/`toJson`) |
| Smoke | `widget_test.dart` | app boots |

`auth_token_model_test.dart` exercises a plain `Equatable` model with hand-written `fromJson`/`toJson` — there is no generated JSON to test, since the codebase does not use `json_serializable` or `freezed`.

> ‏ملف `auth_token_model_test.dart` يختبر موديل بسيط من نوع `Equatable` مع دوال `fromJson`/`toJson` مكتوبة باليد؛ لا يوجد JSON مُولَّد لاختباره لأن الكود لا يستخدم `json_serializable` ولا `freezed`.

---

## Tooling / الأدوات

- `flutter_test` (widget/unit).
- `http_mock_adapter` for Dio responses.
- Hand-rolled fakes (`test/core/network/fakes.dart`) — **no mockito/mocktail yet**.

When feature work needs richer mocks, prefer `mocktail` (no codegen) over `mockito`. Adopting a mocking library is deferred; see the team plan in [ROADMAP](../../docs/ROADMAP.md).

> ‏لمّا شغل الفيتشرات يحتاج mocks أغنى، فضّل `mocktail` (بدون codegen) على `mockito`. تبنّي مكتبة mocking مؤجَّل؛ راجع خطة الفريق في [ROADMAP](../../docs/ROADMAP.md).

---

## Commands / الأوامر

There is no codegen step before tests — the only generated code is l10n, and `flutter test` picks it up automatically.

> ‏مفيش خطوة codegen قبل الاختبارات — الكود المُولَّد الوحيد هو l10n، و`flutter test` بيلتقطه تلقائيًا.

```bash
flutter test                                   # whole suite
flutter test test/core/network/                # one directory
flutter test test/core/network/api_client_test.dart
```

---

## Conventions for feature work (from the epics) / اصطلاحات شغل الفيتشرات

- **Unit** — repositories (envelope mapping, `ApiException` → `Failure`) and BLoCs (state sequences) with mocked data sources. Repositories **throw** a sealed `Failure` and BLoCs catch it with plain `try`/`catch` — there is no `Either`, no `.fold()`, no `Result<T>`. Assert state sequences with `bloc_test` if adopted, or plain `emitsInOrder`.

  > ‏**Unit** — الريبوزيتوريز (تحويل الـ envelope، و`ApiException` → `Failure`) والـ BLoCs (تسلسل الحالات) مع مصادر بيانات مزيّفة. الريبوزيتوري **يرمي** `Failure` من نوع sealed والـ BLoC يمسكه بـ `try`/`catch` عادي — مفيش `Either` ولا `.fold()` ولا `Result<T>`. تحقّق من تسلسل الحالات بـ `bloc_test` لو اتبنّى، أو بـ `emitsInOrder` العادي.

- **Widget** — flow gates and interactions: the add-car gate blocking Home ([app #39](https://github.com/YoussefSalem582/Osta-App/issues/39)), onboarding-seen flag ([#37](https://github.com/YoussefSalem582/Osta-App/issues/37)), payment WebView → polling → receipt ([#46](https://github.com/YoussefSalem582/Osta-App/issues/46)), per-section feed states ([#51](https://github.com/YoussefSalem582/Osta-App/issues/51)).

  > ‏**Widget** — بوابات التدفّق والتفاعلات: بوابة إضافة العربية اللي بتحجب الـ Home ([app #39](https://github.com/YoussefSalem582/Osta-App/issues/39))، وعلَم onboarding-seen ([#37](https://github.com/YoussefSalem582/Osta-App/issues/37))، ومسار الدفع WebView ← polling ← receipt ([#46](https://github.com/YoussefSalem582/Osta-App/issues/46))، وحالات الـ feed لكل قسم ([#51](https://github.com/YoussefSalem582/Osta-App/issues/51)).

- **Golden** — the [design-system epic (#29)](https://github.com/YoussefSalem582/Osta-App/issues/29) sets the standard: every screen/component in **light/dark × RTL/LTR**. Golden files checked into the repo; regenerate with `flutter test --update-goldens` when intentional.

  > ‏**Golden** — [إبيك نظام التصميم (#29)](https://github.com/YoussefSalem582/Osta-App/issues/29) بيحدّد المعيار: كل شاشة/كومبوننت في **light/dark × RTL/LTR**. ملفات الـ golden متسجّلة في الريبو؛ أعِد توليدها بـ `flutter test --update-goldens` لما يكون التغيير مقصود.

---

## CI / التكامل المستمر

`.github/workflows/ci.yml` runs a **single** job named "format · analyze · test" on ubuntu: `flutter pub get` → `flutter gen-l10n` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`. There is no `build_runner` step and no separate android/ios build jobs. A red test fails the PR.

> ‏ملف `.github/workflows/ci.yml` بيشغّل وظيفة **واحدة** اسمها "format · analyze · test" على ubuntu: `flutter pub get` ← `flutter gen-l10n` ← `dart format --set-exit-if-changed` ← `flutter analyze` ← `flutter test`. مفيش خطوة `build_runner` ولا وظائف build منفصلة لـ android/ios. أي اختبار أحمر بيفشّل الـ PR.

Platform build jobs (android APK, iOS) are deferred, not removed — the phased plan lives in [ROADMAP](../../docs/ROADMAP.md) (Phase 4).

> ‏وظائف الـ build حسب المنصّة (android APK و iOS) مؤجَّلة مش محذوفة — الخطة المرحلية موجودة في [ROADMAP](../../docs/ROADMAP.md) (المرحلة 4).

---

## Related / روابط ذات صلة

- [03_how_to_add_new_feature.md](03_how_to_add_new_feature.md) § Tests · [07_how_to_create_reusable_component.md](07_how_to_create_reusable_component.md) · [../reference/TROUBLESHOOTING.md](../reference/TROUBLESHOOTING.md)
