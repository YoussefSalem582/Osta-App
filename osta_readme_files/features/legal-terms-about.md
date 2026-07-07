# 📜 Terms, Privacy & About / الشروط والخصوصية وعن التطبيق

> [INDEX](../INDEX.md) > [Features](README.md) > Terms, Privacy & About

## Overview / نظرة عامة

Legal and app-information screens shared by both role shells. The app renders Terms of Service and Privacy Policy fetched from the backend (`GET /legal/terms`, `GET /legal/privacy` — public endpoints, `Accept-Language` aware, Arabic default), makes acceptance a **mandatory checkbox with links** on the registration form, and provides an About screen with app info, version, contact details, and an explainer for the user's `support_id`. External links open via `url_launcher`. Specified by epic [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38); the backend side ([backend #58](https://github.com/YoussefSalem582/osta_backend/issues/58)) is already merged.

> ‏شاشات قانونية ومعلومات التطبيق مشتركة بين واجهتي الأدوار. يعرض التطبيق شروط الاستخدام وسياسة الخصوصية من الخادم (`GET /legal/terms` و`GET /legal/privacy` — نقاط عامة تدعم `Accept-Language` والعربية هي الافتراضية)، ويجعل الموافقة عليها **خانة اختيار إلزامية مع روابط** في نموذج التسجيل، بالإضافة إلى شاشة "عن التطبيق" التي تعرض معلومات التطبيق والإصدار وبيانات التواصل وشرحًا لمعرّف الدعم `support_id`. تُفتح الروابط الخارجية عبر `url_launcher`. محددة في الإصدار [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38)، والجانب الخلفي ([backend #58](https://github.com/YoussefSalem582/osta_backend/issues/58)) مدموج بالفعل.

## Status & Issues / الحالة والمهام

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38) | Terms, Privacy & About | Open | M1 | p1 | roaa | [backend #58](https://github.com/YoussefSalem582/osta_backend/issues/58) — closed, **ready** |

Backend #58 shipped the `/legal/*` endpoints, seeded `legal_documents` rows, added `users.support_id` (Crockford base32, backfilled) and `terms_accepted_version/at` columns, and records `accept_terms` at registration. Nothing on the app side is blocked.

> ‏شحن الجانب الخلفي #58 نقاط `/legal/*`، وأضاف صفوف `legal_documents`، وعمود `users.support_id` (بترميز Crockford base32 مع تعبئة رجعية) وعمودَي `terms_accepted_version/at`، ويسجّل `accept_terms` عند التسجيل. لا شيء في جانب التطبيق محجوب.

## Screens / Mockups / الشاشات والتصاميم

### Terms, Privacy & account deletion / الشروط والخصوصية وحذف الحساب

![Terms, privacy and account deletion](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/20-terms-privacy-and-account-deletion.png)

The About screen and the registration accept-checkbox are specified in the epic text; dedicated mockups are TBD — see [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38) (registration form appears in `04-create-account-email.png` under [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35), the More-hub entry point in `19-account-and-settings.png` under [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40)).

> ‏شاشة "عن التطبيق" وخانة الموافقة في التسجيل محددتان في نص الإصدار؛ أما التصاميم المخصصة فلم تُحدَّد بعد — راجع [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38) (نموذج التسجيل يظهر في `04-create-account-email.png` ضمن [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)، ونقطة الدخول لواجهة "المزيد" في `19-account-and-settings.png` ضمن [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40)).

## Planned architecture / البنية المخطّطة

**Nothing is built yet.** There is no dedicated `features/legal/` folder; per the feature-area grouping in the tracker, these screens hang off `features/auth/` (terms gate on registration, [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)) and `features/customer/profile/` (More-hub entries, [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40)) — both currently stub directories with no Dart files.

> ‏لم يُبنَ أي شيء بعد. لا يوجد مجلد مخصص `features/legal/`؛ ووفق تجميع مجالات المزايا في المتتبّع، تتبع هذه الشاشات مجلد `features/auth/` (بوابة الشروط عند التسجيل، [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)) و`features/customer/profile/` (مداخل واجهة "المزيد"، [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40)) — وكلاهما حاليًا مجلدان جذعيان بلا ملفات Dart.

Planned shape, following the repo's Clean Architecture + BLoC conventions:

> ‏الشكل المخطّط، متّبعًا أعراف المستودع في العمارة النظيفة و BLoC:

- **Presentation** — a `LegalDocScreen` (named in the epic) rendering one legal document (terms or privacy), plus an About screen. Loading/error/empty phases reuse `LoadingState` / `ErrorState` from `shared/ui/status_states.dart`. A Cubit (name TBD — see epic) holds the fetch state.
- **Data flow** — repository → `ApiClient` (`lib/core/network/api_client.dart`), which unwraps the `{success, data}` envelope and throws typed `ApiException`s. The repository catches those and rethrows a `sealed Failure` (`lib/core/error/failure.dart`); the Cubit uses plain `try`/`catch` — no `Either`, no `.fold()`. The endpoints are **public** (no bearer token needed) and localized server-side via the `Accept-Language` header (Arabic default; runtime header wiring is part of [app #30](https://github.com/YoussefSalem582/Osta-App/issues/30)).
- **Response model** — `{version, locale, title, body_html, updated_at}` per backend #58; a plain `class` extending `Equatable` with a hand-written `fromJson` factory and `props`, consistent with existing models like `PaginationMeta` and `AuthTokenModel`. No `freezed`, no `json_serializable`, no `*.g.dart` (codegen deferred — see [ROADMAP](../../docs/ROADMAP.md) Phases 1–3).
- **DI** — a hand-written `registerLazySingleton` line in `configureDependencies()` (`core/di/injection.dart`), the same manual `get_it` pattern as `ApiClient` / `TokenStorage` today. No `injectable`, no `build_runner`.
- **Routing** — new `go_router` routes (paths TBD — see epic) added to `core/router/app_router.dart` (currently only `/splash`, `/role`). Reached from the registration form links ([app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)) and the Account & More hub ([app #40](https://github.com/YoussefSalem582/Osta-App/issues/40)).
- **About screen data** — app version/info plus the `support_id` explainer; `support_id` is delivered in `UserResource` from `GET /me` ([backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39)), so About reads it from the account/profile layer rather than calling a legal endpoint.
- **Registration tie-in** — the register form must show a mandatory accept checkbox with links to both documents; the backend stores `terms_accepted_version/at` when `accept_terms` is sent.

> ‏العرض — شاشة `LegalDocScreen` (مسمّاة في الإصدار) تعرض وثيقة قانونية واحدة (الشروط أو الخصوصية)، بالإضافة إلى شاشة "عن التطبيق". أطوار التحميل والخطأ والفراغ تعيد استخدام `LoadingState` / `ErrorState` من `shared/ui/status_states.dart`. ويحمل Cubit (اسمه غير محدد بعد — راجع الإصدار) حالة الجلب.

> ‏تدفّق البيانات — المستودع → `ApiClient` الذي يفكّ غلاف `{success, data}` ويرمي `ApiException` مُصنّفة. يلتقط المستودع تلك الاستثناءات ويعيد رمي `Failure` من نوع sealed (`lib/core/error/failure.dart`)، ويستخدم Cubit `try`/`catch` عادية — بلا `Either` وبلا `.fold()`. النقاط عامة (لا حاجة إلى رمز حامل) ومترجمة في الخادم عبر ترويسة `Accept-Language` (العربية افتراضيًا؛ ربط الترويسة أثناء التشغيل جزء من [app #30](https://github.com/YoussefSalem582/Osta-App/issues/30)).

> ‏نموذج الاستجابة — `{version, locale, title, body_html, updated_at}` حسب الجانب الخلفي #58؛ عبارة عن `class` عادي يرث `Equatable` مع `fromJson` و`props` مكتوبَين يدويًا، متوافقًا مع النماذج الحالية مثل `PaginationMeta` و`AuthTokenModel`. بلا `freezed` وبلا `json_serializable` وبلا `*.g.dart` (توليد الكود مؤجَّل — راجع [ROADMAP](../../docs/ROADMAP.md) المراحل 1–3).

> ‏حقن التبعيات — سطر `registerLazySingleton` مكتوب يدويًا داخل `configureDependencies()` (`core/di/injection.dart`)، بنفس نمط `get_it` اليدوي المتّبع مع `ApiClient` / `TokenStorage` اليوم. بلا `injectable` وبلا `build_runner`.

> ‏التوجيه — مسارات `go_router` جديدة (المسارات غير محددة بعد — راجع الإصدار) تُضاف إلى `core/router/app_router.dart` (حاليًا فقط `/splash` و`/role`). يُوصَل إليها من روابط نموذج التسجيل ([app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)) ومن واجهة الحساب و"المزيد" ([app #40](https://github.com/YoussefSalem582/Osta-App/issues/40)).

> ‏بيانات شاشة "عن التطبيق" — إصدار التطبيق ومعلوماته إلى جانب شرح `support_id`؛ يُسلَّم `support_id` ضمن `UserResource` من `GET /me` ([backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39))، لذا تقرأه شاشة "عن التطبيق" من طبقة الحساب/الملف الشخصي بدلًا من استدعاء نقطة قانونية.

> ‏ربط التسجيل — يجب أن يعرض نموذج التسجيل خانة موافقة إلزامية مع روابط للوثيقتين؛ ويخزّن الخادم `terms_accepted_version/at` عند إرسال `accept_terms`.

## API endpoints / نقاط نهاية الـ API

Arabic caption: النقاط أدناه عامة وتدعم `Accept-Language`.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/legal/terms` | Terms of Service — `{version, locale, title, body_html, updated_at}`, public, `Accept-Language` (ar default) | [backend #58](https://github.com/YoussefSalem582/osta_backend/issues/58) / [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38) | Planned |
| GET | `/legal/privacy` | Privacy Policy — same shape and behaviour | [backend #58](https://github.com/YoussefSalem582/osta_backend/issues/58) / [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38) | Planned |

Base URL `/api/v1`, standard `{success, data}` envelope. `GET /me` (source of `support_id` for the About screen) belongs to the account feature — see [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) and [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40).

> ‏عنوان القاعدة `/api/v1`، وغلاف `{success, data}` القياسي. نقطة `GET /me` (مصدر `support_id` لشاشة "عن التطبيق") تتبع مجال الحساب — راجع [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) و[app #40](https://github.com/YoussefSalem582/Osta-App/issues/40).

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages (from the epic, not yet in `pubspec.yaml`):**

> ‏حزم مخطّطة (من الإصدار، ليست بعد في `pubspec.yaml`):

| Package | Use |
|---|---|
| `url_launcher` | Open contact/support and external links from the About screen |

**Existing shared components to reuse:**

> ‏مكوّنات مشتركة قائمة يُعاد استخدامها:

- `AppTopBar` (RTL-safe app bar) for each screen
- `LoadingState` / `ErrorState` (`shared/ui/status_states.dart`) with the existing retry l10n key
- `AppCard` for About-screen info sections
- `AppButton` where actions are needed
- `context.l10n` (`shared/extensions/context_ext.dart`) for all strings — new ARB keys required in `lib/l10n/app_en.arb` + `app_ar.arb`

## Testing expectations / توقعات الاختبار

From [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38):

> ‏من [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38):

- **Golden tests** — `LegalDocScreen` in ar/en × light/dark, following the design-system golden pattern from [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29) (light/dark × RTL/LTR).
- Unit/widget coverage beyond that is TBD — see epic; network fakes already exist in `test/core/network/fakes.dart` for repository/Cubit tests.

> ‏اختبارات golden لشاشة `LegalDocScreen` بالعربية/الإنجليزية × فاتح/داكن، متّبعةً نمط golden لنظام التصميم من [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29). أما تغطية الوحدة/الودجت الأوسع فغير محددة بعد — راجع الإصدار؛ وتوجد بالفعل بدائل الشبكة في `test/core/network/fakes.dart` لاختبارات المستودع/Cubit.

## Related docs / وثائق ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Features index](README.md)
- Sibling features: [Authentication](auth.md) (accept checkbox on register, [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35)) · [Account & More hub](account-more.md) (legal entries + `support_id` display, [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40))
