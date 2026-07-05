> [INDEX](../INDEX.md) > [Features](README.md) > Business More hub

# 🧰 Business More hub + management extras (Phase 2) / مركز "المزيد" للأعمال وإضافات الإدارة

## Overview / نظرة عامة

The Business More hub is the provider-side counterpart of the customer "Account & More" tab: everything a business owner needs outside the day-to-day booking flow, collected in one place. It extends the shared More hub with management extras — editing the public business profile, adjusting weekly capacity, viewing analytics/KPIs, and a reviews inbox with reply and report actions. This is a **Phase 2** epic ([app #58](https://github.com/YoussefSalem582/Osta-App/issues/58), milestone M6) and is currently **backend:blocked**: the backend M6 analytics, capacity-management, and review-reply APIs are Phase-2 work tracked in [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62). Nothing in this feature is built yet — the `lib/features/business/` folder is a stub with empty subdirectories.

> ‏مركز "المزيد" للأعمال هو النظير الخاص بمقدّم الخدمة لتبويب "الحساب والمزيد" لدى العميل: كل ما يحتاجه صاحب النشاط خارج تدفق الحجوزات اليومي في مكان واحد. يضيف إلى المركز المشترك أدوات إدارية — تعديل الملف التجاري العام، ضبط السعة الأسبوعية، عرض التحليلات ومؤشرات الأداء، وصندوق مراجعات مع إمكانية الرد والإبلاغ. هذه ملحمة من المرحلة الثانية (التطبيق ‎#58، معلم M6) وهي حاليًا محجوبة على الخادم: واجهات التحليلات والسعة والرد على المراجعات ضمن أعمال المرحلة الثانية في الخادم (‎#62). لم يُبنَ أي جزء من هذه الميزة بعد — مجلد `lib/features/business/` مجرد هيكل فارغ.

## Status & Issues / الحالة والمهام

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) | Business More hub + extras | Open (phase:2, backend:blocked) | M6 | p2 | haneen | [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) — **blocked** (Phase 2 backlog, open) |

Related: the customer-side [Account & More hub (app #40)](https://github.com/YoussefSalem582/Osta-App/issues/40) defines the baseline More tab that this hub extends; its account endpoints are already shipped in [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) (closed — ready).

> ‏ذات صلة: مركز "الحساب والمزيد" لدى العميل (التطبيق ‎#40) يُعرّف تبويب "المزيد" الأساسي الذي يمتد منه هذا المركز، ونقاط نهاية الحساب الخاصة به مُسلّمة بالفعل في الخادم (‎#39 — مغلق وجاهز).

## Screens / Mockups / الشاشات والتصاميم

| Screen | Mockup |
|---|---|
| Wallet & earnings (Business More hub) | ![Wallet and earnings](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/28-wallet-and-earnings.png) |

Other screens named by the epic (public business profile editor, capacity settings, analytics/KPIs, reviews inbox) — mockups TBD, see [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58).

> ‏بقية الشاشات التي تسمّيها الملحمة (محرّر الملف التجاري العام، إعدادات السعة، التحليلات ومؤشرات الأداء، صندوق المراجعات) تصاميمها قيد الإعداد — راجع التطبيق ‎#58.

## Planned architecture / البنية المخطّطة

Everything below is **planned** — specified by epic [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58). `lib/features/business/` currently contains only empty stub directories (`bookings/`, `dashboard/`, `services/`, `team/`, `wallet/`); the More-hub extras map to `business/wallet/` per the feature-area grouping in the MVP tracker ([app #61](https://github.com/YoussefSalem582/Osta-App/issues/61)).

> ‏كل ما يلي **مخطّط له** — محدّد في الملحمة (التطبيق ‎#58). يحتوي `lib/features/business/` حاليًا على مجلدات هيكلية فارغة فقط (`bookings/` و`dashboard/` و`services/` و`team/` و`wallet/`)، وتنتمي إضافات مركز "المزيد" إلى `business/wallet/` حسب تجميع مجالات الميزات في متتبّع الـ MVP (التطبيق ‎#61).

- **Layers**: layered feature structure (data → domain ← presentation) like every feature — data sources call `ApiClient` (`lib/core/network/api_client.dart`), repositories **throw** a `Failure` (`sealed class Failure implements Exception`, from `core/error/failure.dart`) on error, and models are plain `class X extends Equatable` with hand-written `fromJson`/`toJson`/`props`.
- **State**: BLoC/Cubit (`flutter_bloc`) per screen area — planned cubits for business profile, capacity, analytics, and the reviews inbox. Exact names TBD — see epic.
- **DI**: registrations via **manual** `get_it` — a hand-written `registerLazySingleton` line per service in `configureDependencies()` (`core/di/injection.dart`). No annotations, no codegen.
- **Routing**: lives inside the provider (business) shell planned by [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34) (`StatefulShellRoute` on `go_router`); the current router only has `/splash` and `/role` — no shells yet. The hub reuses the customer More-hub items from [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40) (profile, settings, legal, feedback, logout, soft delete) and adds the management entries. The team/mechanics roster entry point ([app #62](https://github.com/YoussefSalem582/Osta-App/issues/62)) also lives under Business More → Business management.
- **Errors**: typed `ApiException`s from `core/network/api_exception.dart` are caught and converted to a `Failure`; blocs handle them with plain `try`/`catch`. Paginated lists (e.g. reviews inbox) use `PaginationMeta`.

The models, DI, and error style above are all **plain Dart with no codegen** — a deliberate choice to keep a Flutter-new team productive. `freezed`, `json_serializable`, `injectable`, and `fpdart`/`Either` are **deferred, not rejected**; the phased reintroduction plan lives in [ROADMAP](../../docs/ROADMAP.md). Only l10n is generated (`flutter gen-l10n`).

> ‏نمط النماذج وحقن التبعيات ومعالجة الأخطاء أعلاه كلّها **دارت عادي بلا توليد كود** — اختيار مقصود لإبقاء فريق جديد على Flutter منتجًا. حزم `freezed` و`json_serializable` و`injectable` و`fpdart`/`Either` **مؤجَّلة وليست مرفوضة**، وخطة إعادة إدخالها على مراحل موجودة في [ROADMAP](../../docs/ROADMAP.md). الكود المولّد الوحيد هو l10n (`flutter gen-l10n`).

## API endpoints / نقاط نهاية الـ API

All endpoints are **future** per the epic — none exist on the backend yet ([backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) open). Note: a `PUT /business/profile` and `PUT /business/capacity` already shipped for onboarding in [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56); the epic lists the hub variants below as future work.

> ‏كل نقاط النهاية **مستقبلية** حسب الملحمة — لا وجود لأيٍّ منها على الخادم بعد (‎#62 مفتوح). ملاحظة: `PUT /business/profile` و`PUT /business/capacity` مُسلّمتان بالفعل للتهيئة الأولية في الخادم (‎#56)، وتُدرج الملحمة نسخ المركز أدناه كأعمال مستقبلية.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/business/profile` | Read public business profile for editing | [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) | Blocked |
| PATCH | `/business/profile` | Update public business profile | [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) | Blocked |
| PATCH | `/business/capacity` | Adjust capacity settings | [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) | Blocked |
| GET | `/business/analytics?range=` | Analytics / KPIs for a date range | [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) | Blocked |
| GET | `/reviews?reviewable=service_center&id=` | Reviews inbox for the center | [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) | Blocked |
| POST | `/reviews/{id}/reply` | Reply to a review | [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) | Blocked |
| POST | `/reviews/{id}/report` | Report a review | [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) | Blocked |

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages**: none specific listed in the epic — TBD, see [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58). (The baseline customer More hub it extends, [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40), plans `image_picker` and `url_launcher`.)

> ‏الحزم المخطّطة: لا شيء محدّد في الملحمة — قيد التحديد، راجع التطبيق ‎#58. (المركز الأساسي لدى العميل الذي يمتد منه، التطبيق ‎#40، يخطّط لاستخدام `image_picker` و`url_launcher`.)

**Existing shared components to reuse** (`lib/shared/ui/`):

> ‏مكوّنات مشتركة قائمة لإعادة استخدامها (`lib/shared/ui/`):

- `AppTopBar` / `AppBottomNavBar` — shell navigation (RTL-safe, badge support).
- `AppCard` — hub entries, KPI/analytics cards.
- `AppButton`, `AppTextField`, `AppBottomSheet` — profile/capacity forms and review-reply input.
- `EmptyState` / `ErrorState` / `LoadingState` (`status_states.dart`) — list and detail states.
- `EgpFormatter` / `NumberFormatter` (`shared/formatters/app_formatters.dart`) — EGP revenue figures and Arabic-Indic digits in analytics.
- `context.l10n` (`shared/extensions/context_ext.dart`) — all strings via ARB, Arabic default.

## Testing expectations / توقعات الاختبار

From the epic and repo conventions — TBD in detail, see [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58):

> ‏من الملحمة وأعراف المستودع — التفاصيل قيد التحديد، راجع التطبيق ‎#58:

- **Widget tests** for hub navigation and each management screen's states (loading/empty/error via the shared status states).
- **Golden tests** following the design-system pattern from [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29): light/dark × RTL/LTR per screen.
- **Unit tests** for cubits and repository mapping (`ApiException` → `Failure`), using the fakes pattern in `test/core/network/fakes.dart`.

## Related docs / مستندات ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [ROADMAP — deferred tooling plan](../../docs/ROADMAP.md)
- [Business dashboard](business-dashboard.md) — [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54)
- [Business bookings management](business-bookings.md) — [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55)
- [Business catalog & pricing](business-catalog.md) — [app #56](https://github.com/YoussefSalem582/Osta-App/issues/56)
- [Business team & mechanics](business-bookings.md) — [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62)
- [Account & More hub (customer)](account-more.md) — [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40)
