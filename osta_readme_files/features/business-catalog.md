> [INDEX](../INDEX.md) > [Features](README.md) > Business Catalog & Pricing

# 🧾 Business Catalog & Pricing / كتالوج النشاط والأسعار

The business shell's control surface for the services catalog and time-bound promotions. Each service carries a name, EGP price, price type (fixed / starting-from / hourly), duration, and active flag; promotions layer percentage or amount discounts over a date window. Active services and live promotions surface on the public center profile that customers browse before booking.

> ‏سطح التحكّم في شِل النشاط لكتالوج الخدمات والعروض المحدّدة بمدّة. تحمل كل خدمة اسمًا وسعرًا بالجنيه المصري ونوع تسعير (ثابت / يبدأ من / بالساعة) ومدّة وعلامة تفعيل؛ وتضيف العروض خصومات بنسبة أو بمبلغ خلال نافذة زمنية. تظهر الخدمات الفعّالة والعروض الحيّة في ملفّ المركز العام الذي يتصفّحه العملاء قبل الحجز.

---

## Status & Issues / الحالة والقضايا

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #56](https://github.com/YoussefSalem582/Osta-App/issues/56) | Business catalog & pricing management | COMPLETE | M5 | p1 | haidy | ready — [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) ✅ |

The backend catalog + promotions CRUD ([backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57)) is shipped, so this epic is unblocked. The initial catalog seed (≥1 preset) happens earlier during business onboarding — see [business-onboarding.md](business-onboarding.md) and [backend #56](https://github.com/YoussefSalem582/osta_backend/issues/56).

> ‏تم تسليم عمليات إنشاء وتعديل وحذف الكتالوج والعروض في الـ backend، لذا فإن هذه المهمّة غير محجوبة. تحدث تهيئة الكتالوج المبدئية (عنصر واحد على الأقل) في وقت أبكر أثناء إعداد النشاط — راجع [business-onboarding.md](business-onboarding.md).

---

## Screens / Mockups

**Services & pricing**

![Services and pricing](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/26-services-and-pricing.png)

---

## Planned architecture / المعمارية المخطّطة

Lives under `lib/features/business/services/` (currently a stub folder). Two BLoCs (or cubits) — one for services, one for promotions — each backed by a repository over `ApiClient`.

> ‏موجودة تحت `lib/features/business/services/` (مجلّد stub حاليًا). عدد اثنين BLoC (أو cubit) — واحد للخدمات وواحد للعروض — كلٌّ مدعوم بـ repository فوق `ApiClient`.

- **Domain**: `Service` and `Promotion` entities; repository contracts that return the parsed data directly (e.g. `Future<List<Service>>` / `Future<Service>`) and **throw** a `Failure` on error; one method per operation (list/create/update/delete).
- **Data**: plain `Equatable` models (`ServiceModel`, `PromotionModel`) with hand-written `fromJson`/`toJson` — no codegen; a remote data source calling the `/business/services` and `/business/promotions` endpoints; the repository catches `ApiException` and rethrows it as a `Failure` (422 field errors surface inline on the form).
- **Presentation**: a management screen listing services (name · price · price-type badge · active toggle) and promotions (title · discount · date window · active), each with add/edit/delete via an `AppBottomSheet` form. Pull-to-refresh, empty state (`EmptyState`), error state (`ErrorState`).

The models are plain `class X extends Equatable` with hand-written `fromJson` / `toJson` / `props` — there is no `@freezed`, no `part '*.g.dart'`, and no `build_runner`. Error handling is `try`/`catch` around a thrown `Failure`, not `Either` or `.fold()`. The service is registered by hand with a `registerLazySingleton` line in `configureDependencies()` (`lib/core/di/injection.dart`) — no `injectable` annotations. This is a deliberate, beginner-friendly baseline; the advanced tooling (freezed, json_serializable, injectable, fpdart) is deferred with a phased plan in [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

> ‏النماذج عبارة عن `class X extends Equatable` بسيطة مع `fromJson` و`toJson` و`props` مكتوبة يدويًا — لا يوجد `@freezed` ولا `part '*.g.dart'` ولا `build_runner`. ومعالجة الأخطاء تتم عبر `try`/`catch` حول `Failure` يُرمى، وليس عبر `Either` أو `.fold()`. ويُسجَّل الـ service يدويًا بسطر `registerLazySingleton` داخل `configureDependencies()` في `lib/core/di/injection.dart` بدون أي annotations لـ `injectable`. هذا أساس مبسّط مقصود ومناسب لفريق جديد على Flutter؛ أما الأدوات المتقدّمة (freezed وjson_serializable وinjectable وfpdart) فهي مؤجَّلة وفق خطة مرحلية في [../../docs/ROADMAP.md](../../docs/ROADMAP.md).

`price_type` is an enum (`fixed | starting_from | hourly`); `discount_type` is `percent | amount`. Cross-center writes are rejected server-side (403) — the app never sends an owner id.

> ‏الحقل `price_type` عبارة عن enum بقيم (`fixed | starting_from | hourly`)، و`discount_type` بقيم `percent | amount`. تُرفَض الكتابات عبر مركز آخر من جهة الخادم (403) — والتطبيق لا يرسل مطلقًا معرّف المالك.

---

## API endpoints / نقاط النهاية

The endpoints below are the backend contract for the catalog and promotions.

> ‏نقاط النهاية التالية هي عقد الـ backend للكتالوج والعروض.

| Method | Path | Purpose | Source | App status |
|---|---|---|---|---|
| GET | `/api/v1/business/services` | List the center's services | [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Shipped |
| POST | `/api/v1/business/services` | Create a service | [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Shipped |
| PUT | `/api/v1/business/services/{id}` | Update a service | [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Shipped |
| DELETE | `/api/v1/business/services/{id}` | Soft-delete a service | [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Shipped |
| GET | `/api/v1/business/promotions` | List promotions | [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Shipped |
| POST | `/api/v1/business/promotions` | Create a promotion | [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Shipped |
| PUT | `/api/v1/business/promotions/{id}` | Update a promotion | [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Shipped |
| DELETE | `/api/v1/business/promotions/{id}` | Delete a promotion | [backend #57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Shipped |
| GET | `/api/v1/centers/{id}/services` | Public reflection (active only) | [backend #42](https://github.com/YoussefSalem582/osta_backend/issues/42) | Shipped |

Field reference: service = `{ name, price (EGP decimal), price_type, duration_minutes, is_active }`; promotion = `{ title, description, discount_type, discount_value, starts_at, ends_at, is_active }`. Full catalogue: [../guides/09_api_endpoints.md](../guides/09_api_endpoints.md).

---

## Packages & shared widgets / الحزم والودجات

- **Reuse**: `AppTextField`, `AppButton`, `AppBottomSheet`, `AppCard`, `EmptyState`/`ErrorState`/`LoadingState`, `EgpFormatter` (price display), `AdaptiveSwitch`-style active toggle (build if not present).
- **New**: date-range picker for promotion windows; a price-type segmented control.

> ‏أعِد استخدام الودجات المشتركة الموجودة قدر الإمكان، ولا تضِف سوى منتقي المدى الزمني للعروض وعنصر تحكّم مقسّم لنوع التسعير.

---

## Testing expectations / توقّعات الاختبار

- **Widget**: service list renders; add/edit/delete update the list; active toggle flips; promotion date-window validation blocks bad ranges.
- **Unit**: repository maps the envelope and rethrows a `Failure`; 422 field errors surface per field.
- **Golden**: management screen in light/dark + RTL.

> ‏اختبارات الودجات تتحقّق من عرض القائمة وتحديثها بعد الإضافة والتعديل والحذف ومن التحقّق من نافذة تاريخ العرض؛ واختبارات الوحدة تتحقّق من قراءة الـ repository للمغلّف وإعادة رمي `Failure` وظهور أخطاء 422 لكل حقل؛ واختبارات الـ golden تغطّي الشاشة في الوضعين الفاتح والداكن ومع اتجاه RTL.

---

## Related docs / روابط ذات صلة

- Public surface that consumes this: [center-profile.md](center-profile.md)
- Initial seed step: [business-onboarding.md](business-onboarding.md)
- [../reference/DELIVERY_PLAN.md](../reference/DELIVERY_PLAN.md) · [../guides/04_how_to_add_new_api.md](../guides/04_how_to_add_new_api.md)
