> [INDEX](../INDEX.md) > [Features](README.md) > Shop

# 🛍️ Shop — two-sided marketplace / المتجر — سوق ثنائي الاتجاه

## Overview / نظرة عامة

The Shop is OSTA's two-sided marketplace for car parts and products: any user — a customer or a service center — can list products, and everyone can browse them. Customers browse a searchable grid with category filters, open a product detail page (image carousel, EGP price, seller card) and reach out via an enquiry or the seller's public profile — there is **no cart or checkout** in MVP (product rule from tracker [app #61](https://github.com/YoussefSalem582/Osta-App/issues/61)). Sellers manage their own listings through `/me/products`, where the backend resolves the owner polymorphically (User for customers, ServiceCenter for businesses). The feature is specified by three open epics — browse/detail/catalog ([app #48](https://github.com/YoussefSalem582/Osta-App/issues/48)), customer public profile ([app #49](https://github.com/YoussefSalem582/Osta-App/issues/49), Phase 2) and business shop management ([app #57](https://github.com/YoussefSalem582/Osta-App/issues/57)) — and its backend is already merged. On the app side, `lib/features/shop/` is currently an empty stub.

> ‏المتجر هو سوق أُسطى ثنائي الاتجاه لقطع غيار ومنتجات السيارات: أي مستخدم — عميل أو مركز خدمة — يمكنه عرض منتجات، والجميع يمكنهم التصفح. يتصفح العملاء شبكة منتجات مع بحث وتصنيفات، ويفتحون صفحة تفاصيل المنتج (معرض صور، السعر بالجنيه المصري، بطاقة البائع) ويتواصلون عبر استفسار أو الملف العام للبائع — لا توجد سلة أو دفع في النسخة الأولى. يدير البائعون منتجاتهم عبر `‎/me/products` حيث يحدد الخادم المالك تلقائيًا (مستخدم أو مركز خدمة). الميزة موصوفة في ثلاث مهام مفتوحة (‎#48 و‎#49 مرحلة ثانية و‎#57) والواجهة الخلفية لها مكتملة بالفعل، بينما مجلد `lib/features/shop/` في التطبيق ما يزال فارغًا.

## Status & Issues / الحالة والمهام

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48) | Shop — browse + detail + catalog (two-sided) | Open | Shop | p1 | adel | [backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52) — ready (closed) |
| [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) | Customer public profile (My Shop + Reviews) | Open (phase:2) | Shop | p2 | adel | [backend #53](https://github.com/YoussefSalem582/osta_backend/issues/53) — ready (closed) |
| [app #57](https://github.com/YoussefSalem582/Osta-App/issues/57) | Business shop management | Open | Shop | p1 | haidy | [backend #53](https://github.com/YoussefSalem582/osta_backend/issues/53) — ready (closed) |

Both backend Shop epics are merged, so nothing here is backend-blocked — all app work is **Planned**, not started.

> ‏كلتا مهمتي الواجهة الخلفية للمتجر مكتملتان، لذا لا شيء هنا محجوب بسبب الخادم — كل عمل التطبيق **مخطط له** ولم يبدأ بعد.

## Screens / Mockups / الشاشات والتصاميم

| Screen | Mockup |
|---|---|
| Store & product details (browse grid, product page, seller card — [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48)) | ![Store and product details](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/16-store-and-product-details.png) |
| Customer profile & reviews (My Shop tab + Reviews tab — [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49)) | ![Customer profile and reviews](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/17-customer-profile-and-reviews.png) |
| Store management — products (business side — [app #57](https://github.com/YoussefSalem582/Osta-App/issues/57)) | ![Store management products](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/27-store-management-products.png) |

## Planned architecture / البنية المخطط لها

Everything below is **planned** — `lib/features/shop/` today contains only empty `data/`, `domain/`, `presentation/` directories (no Dart files).

> ‏كل ما يلي **مخطط له** — مجلد `lib/features/shop/` حاليًا يحتوي فقط على أدلة فارغة `data/` و`domain/` و`presentation/` بدون أي ملفات Dart.

Following the repo's Clean Architecture + BLoC conventions (data → domain ← presentation), and the repo's deliberately plain-Dart, no-codegen setup (advanced tooling is deferred — see [ROADMAP](../../docs/ROADMAP.md)):

> ‏باتباع أعراف المستودع في المعمارية النظيفة وBLoC (data ← domain → presentation)، وإعداد المستودع المتعمَّد القائم على Dart البسيط بدون توليد كود (الأدوات المتقدمة مؤجلة — انظر [ROADMAP](../../docs/ROADMAP.md)):

- **Data**: plain `Equatable` product models with hand-written `fromJson`/`toJson` mapping the backend's polymorphic Product (UUID, name, description, category, EGP decimal price, images json, is_active) — no codegen, following the pattern of `lib/features/auth/data/models/auth_token_model.dart`. Repository implementations call the shared `core/network` `ApiClient` (envelope-aware, returns `ApiResult<T>` with `PaginationMeta` for the paginated browse list, throws typed `ApiException`s — e.g. `ValidationException` for 422 on the product form).
- **Domain**: repository contracts that **throw** a `Failure` on error — the sealed `Failure` type in `core/error/failure.dart` (`NetworkFailure` / `ServerFailure` / `UnknownFailure`). No `Either`, no `Result<T>`; callers use plain `try`/`catch`. (fpdart is deferred — see [ROADMAP](../../docs/ROADMAP.md).)
- **Presentation** (Cubits/Blocs planned per epic scope):
  - Browse list cubit — search + category filter + pagination ([app #48](https://github.com/YoussefSalem582/Osta-App/issues/48)).
  - Product detail cubit — carousel, seller card, Enquire / View profile actions.
  - Seller storefront cubit — per-center (`/centers/{id}/products`) and per-user (`/users/{id}/products`) listings.
  - My-products management cubit — `ProductFormSheet` add/edit, deactivate toggle (no hard delete) for the customer My Shop tab ([app #49](https://github.com/YoussefSalem582/Osta-App/issues/49)); the same `/me/products` flow serves business centers, with owner resolved server-side ([app #57](https://github.com/YoussefSalem582/Osta-App/issues/57)).
- **DI**: register cubits and repositories by **hand** with `get_it` — add a `registerLazySingleton` line in `configureDependencies()` (`lib/core/di/injection.dart`), the same manual pattern used for existing core singletons. No `injectable`, no annotations, no `build_runner`.
- **Routing**: routes TBD — see epics. Route paths are `static const path` on the page widgets. The router currently only has `/splash` (`SplashPage`) → `/role` (`RoleSelectionPage`); shop routes will land inside the role shells planned by [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34). Business-side surfaces also appear in the center profile Shop strip ([app #42](https://github.com/YoussefSalem582/Osta-App/issues/42)) and global browse.

The error contract callers should follow — repository throws, cubit catches:

> ‏عقد الأخطاء الذي يجب أن يتبعه المستدعون — المستودع يرمي استثناءً والـ cubit يلتقطه:

```dart
// repository — throws on failure, no Either / no Result<T>
try {
  final res = await apiClient.get<ProductModel>('/products/$id');
  return res.data;
} on ApiException catch (e) {
  throw ServerFailure(e.message); // sealed Failure from core/error/failure.dart
}

// cubit — plain try/catch
try {
  final product = await repository.getProduct(id);
  emit(ProductLoaded(product));
} on Failure catch (f) {
  emit(ProductError(f.message));
}
```

## API endpoints / نقاط النهاية

All under base `/api/v1`, Sanctum bearer, standard `{success, data, meta?}` envelope.

> ‏كل النقاط تحت المسار الأساسي `/api/v1`، بمصادقة Sanctum bearer، وبمغلّف الاستجابة القياسي `{success, data, meta?}`.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/products?q=&category=&page=` | Browse grid with search + category filter (paginated) | [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48) / [backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| GET | `/products/{id}` | Product detail | [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48) / [backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| GET | `/centers/{id}/products` | Center storefront | [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48) / [backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| GET | `/users/{id}/products` | User (customer seller) storefront | [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48) / [backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| POST | `/products/{id}/enquiries` | Send enquiry `{message}` to seller | [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48) / [backend #52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| GET | `/me/products` | List own products (owner server-resolved) | [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) / [backend #53](https://github.com/YoussefSalem582/osta_backend/issues/53) | Planned |
| POST | `/me/products` | Create product | [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) / [backend #53](https://github.com/YoussefSalem582/osta_backend/issues/53) | Planned |
| PUT | `/me/products/{id}` | Update product (incl. deactivate via `is_active`) | [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) / [backend #53](https://github.com/YoussefSalem582/osta_backend/issues/53) | Planned |
| DELETE | `/me/products/{id}` | Remove product (soft delete) | [backend #53](https://github.com/YoussefSalem582/osta_backend/issues/53) | Planned |
| GET | `/users/{id}/reviews` | Reviews received by a seller (+ average) | [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) / [backend #53](https://github.com/YoussefSalem582/osta_backend/issues/53) | Planned |
| GET | `/users/{id}` | Seller public profile | [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) | Planned |

Note: [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) lists PATCH for `/me/products/{id}`; the backend epic ([backend #53](https://github.com/YoussefSalem582/osta_backend/issues/53)) documents PUT — reconcile when wiring. User-to-shop reviews are moderated server-side (pending until approved).

> ‏ملاحظة: المهمة ‎#48 تذكر PATCH لـ `/me/products/{id}` بينما مهمة الواجهة الخلفية ‎#53 توثّق PUT — يُوفَّق بينهما عند الربط. مراجعات المستخدم للمتجر تُدار من الخادم (معلّقة حتى الموافقة).

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages** (from the epics, not yet in `pubspec.yaml`):

> ‏حزم مخطط لها (من المهام، لم تُضف بعد إلى `pubspec.yaml`):

| Package | Used for | Epic |
|---|---|---|
| `carousel_slider` | Product image carousel on detail page | [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48) |
| `share_plus` | Share product / profile links | [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48), [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) |
| `url_launcher` | Contact seller actions | [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48) |
| `image_picker` | Product photos in the management form | [app #57](https://github.com/YoussefSalem582/Osta-App/issues/57) |

**Existing shared components to reuse** (already in the repo):

> ‏مكوّنات مشتركة موجودة يُعاد استخدامها (متوفرة بالفعل في المستودع):

- `shared/ui/`: `AppCard` (product cards), `AppButton` (Enquire / Save), `AppTextField` (search, product form), `AppBottomSheet` (`ProductFormSheet`, enquiry sheet), `AppTopBar` / `AppBottomNavBar`, `EmptyState` / `ErrorState` / `LoadingState` for grid states.
- `shared/formatters/app_formatters.dart`: `EgpFormatter` for prices (ar_EG Arabic-Indic digits), `NumberFormatter` for review counts/averages.
- `cached_network_image` (already a dependency) for product images.
- `context.l10n` for all strings — no hardcoded text.

## Testing expectations / توقعات الاختبار

Per repo conventions, tests use `flutter_test`, `http_mock_adapter`, and hand-written fakes (no mockito/mocktail):

> ‏وفق أعراف المستودع، تستخدم الاختبارات `flutter_test` و`http_mock_adapter` وبدائل مكتوبة يدويًا (بدون mockito/mocktail):

- **Unit tests**: cubits and repositories against fakes (reuse the `test/core/network/fakes.dart` pattern); envelope parsing and pagination of `/products` via `ApiResult<T>`; 422 `ValidationException` mapping to field errors on the product form; repositories throwing the sealed `Failure` on error and cubits catching it with `try`/`catch`.
- **Widget tests**: browse grid (loading/empty/error states), product detail actions, `ProductFormSheet` validation, deactivate toggle behavior (no hard delete).
- **Golden tests**: key screens light/dark × RTL/LTR (deferred with the rest of the golden-test setup — see [ROADMAP](../../docs/ROADMAP.md)).

Exact test lists are TBD — see epics [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48), [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49), [app #57](https://github.com/YoussefSalem582/Osta-App/issues/57).

## Related docs / روابط ذات صلة

- [API endpoints](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- Sibling feature docs: [Home dashboard](home-dashboard.md) · [Map & discovery](map-discovery.md) · [Center profile](center-profile.md) · [Account & More](account-more.md) · [Auth](auth.md) · [Role selection & routing](role-selection-and-routing.md)
