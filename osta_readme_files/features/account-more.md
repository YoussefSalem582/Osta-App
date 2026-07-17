> [INDEX](../INDEX.md) > [Features](README.md) > Account & More hub

# 👤 Account & More hub · الحساب والمزيد

## Overview / نظرة عامة

The Account & More hub is the "More" tab shown in both the customer and business shells. It groups everything account-related in one place: Profile (with avatar swap and the user's `support_id`), Settings, My cars, My Shop, saved addresses, legal pages, feedback, logout, and soft account deletion. The hub is specified by epic [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40) (M1, b2c, p1, owner roaa). The profile screens are **built** and, as of 2026-07-17, live at `lib/features/shared/profile/` (moved out of `customer/` so both shells render the same `ProfileView`), with an offline-first read-cache and skeleton loading; the remaining hub entries (addresses CRUD, legal, feedback) are still planned. The backend side ([backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39)) is already merged, so the app work is unblocked.

> ‏تبويب "المزيد" هو مركز الحساب في واجهتي العميل والنشاط التجاري معًا: الملف الشخصي (مع تغيير الصورة وعرض مُعرّف الدعم `support_id`)، الإعدادات، سياراتي، متجري، العناوين المحفوظة، الصفحات القانونية، إرسال الملاحظات، تسجيل الخروج، والحذف المرن للحساب. الميزة بأكملها **مخططة** ولم تُبنَ بعد — موصوفة في المهمة app ‎#40، ومجلد الميزة في التطبيق ما يزال فارغًا، بينما واجهات الخادم المقابلة (backend ‎#39) مدموجة وجاهزة.

## Status & Issues / الحالة والمهام

The table below tracks the epic, its state, and the backend issue that unblocks it.

> ‏الجدول التالي يتتبّع المهمة وحالتها ومهمة الخادم التي تفتح العمل عليها.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40) | Account & More hub | Open | M1 | p1 | roaa | [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) — **ready** (closed) |

Related epics: the hub's "My Shop" entry is detailed in [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) (Phase 2), legal pages in [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38), "My cars" in [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50), and the business-shell extension of this hub in [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) (Phase 2, backend:blocked).

> ‏مهام ذات صلة: مدخل "متجري" داخل المركز موصوف في app ‎#49 (المرحلة 2)، والصفحات القانونية في app ‎#38، و"سياراتي" في app ‎#50، وامتداد المركز إلى واجهة النشاط التجاري في app ‎#58 (المرحلة 2، backend:blocked).

## Screens / Mockups / الشاشات والتصاميم

**Account & Settings**

![Account and settings mockup](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/19-account-and-settings.png)

## Planned architecture / البنية المخططة

The profile/settings surface is **built** at `lib/features/shared/profile/` (cubit, repo, `ProfileScreen`/`EditProfileScreen`, avatar, delete, plus the cache-then-network `ProfileCache`); the sections below describe the remaining hub entries (addresses CRUD, legal, feedback) that are still planned.

> ‏واجهة الملف/الإعدادات **مبنية** في `lib/features/shared/profile/`؛ وما يلي يصف بقية عناصر المركز (العناوين والصفحات القانونية والملاحظات) التي لم تُبنَ بعد.

- **Layers**: Clean Architecture, `data → domain ← presentation`. Models are plain `Equatable` classes with hand-written `fromJson`/`toJson`, mirroring the backend `UserResource` shape `{id, first_name, last_name, username, email, phone, language_preference, avatar_url, type, roles[], support_id}` ([backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39)). No `freezed`/`json_serializable` codegen — that stack is deferred; see [ROADMAP](../../docs/ROADMAP.md).
- **State management**: BLoC/Cubit (`flutter_bloc` 9). Expect cubits for profile load/update, avatar upload, addresses CRUD, and account deletion/logout flows — exact naming TBD, see epic [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40).
- **Data flow**: presentation cubit → domain repository → remote data source → `ApiClient` (`core/network/api_client.dart`), which unwraps the `{success, data, meta?}` envelope into `ApiResult<T>` or throws typed `ApiException`s. The repository catches those and rethrows a `sealed class Failure` (`core/error/failure.dart`); the cubit uses plain `try`/`catch` — no `Either`, no `.fold()`, no `Result<T>`.
- **DI**: registrations via **manual** `get_it` — a hand-written `registerLazySingleton` line in `configureDependencies()` (`core/di/injection.dart`). No `injectable` codegen; see [ROADMAP](../../docs/ROADMAP.md).
- **Routing**: the More tab lives inside the planned role shells (`StatefulShellRoute`, epic [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)) — today `app_router.dart` only has `/splash` and `/role`. Logout and soft delete clear `TokenStorage`; a 401 / session expiry fires `AuthEvents.onSessionExpired` and redirects to login.
- **Avatar swap**: `image_picker` → multipart `POST /me/avatar`.
- **Shared hub**: the same hub is reused by the business shell; management extras (analytics, capacity, reviews inbox) are layered on top in Phase 2 by [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58).

> ‏النماذج عبارة عن أصناف `Equatable` عادية مع `fromJson`/`toJson` مكتوبة يدويًا، تعكس شكل `UserResource` في الخادم — بلا توليد كود `freezed`/`json_serializable` (مؤجَّل، انظر ROADMAP). إدارة الحالة عبر BLoC/Cubit. تدفّق البيانات: الـ cubit ← المستودع ← مصدر البيانات البعيد ← `ApiClient`، الذي يفكّ المغلّف إلى `ApiResult<T>` أو يرمي `ApiException`؛ ثم يلتقطها المستودع ويرمي `Failure` مغلقًا (sealed) ويعالجه الـ cubit عبر `try`/`catch` عادي — بلا `Either` ولا `.fold()` ولا `Result<T>`. حقن التبعية عبر `get_it` **يدويًا** (`registerLazySingleton` مكتوب يدويًا) بلا توليد `injectable`. التوجيه عبر أصداف الأدوار المخططة، وتسجيل الخروج والحذف المرن يمسحان `TokenStorage`.

## API endpoints / نقاط النهاية

All under base `/api/v1`, Sanctum-authenticated, envelope `{success, data, meta?}`.

> ‏كل النقاط تحت المسار `/api/v1`، موثّقة عبر Sanctum، وتستخدم المغلّف `{success, data, meta?}`.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| GET | `/me` | Load profile (incl. `support_id`, `language_preference`) | [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40) / [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| PUT | `/me` | Update profile fields | [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40) / [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| POST | `/me/avatar` | Upload avatar (multipart) | [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40) / [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| GET | `/me/addresses` | List saved addresses | [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| POST | `/me/addresses` | Add address (PostGIS point) | [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| PUT | `/me/addresses/{id}` | Update address (owner-only policy) | [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| DELETE | `/me/addresses/{id}` | Delete address | [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| DELETE | `/me` | Soft-delete account + revoke tokens | [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40) / [backend #39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| POST | `/auth/logout` | Logout (hub action) | [backend #37](https://github.com/YoussefSalem582/osta_backend/issues/37) via [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34) | Planned |

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages** (from the epic, not yet in `pubspec.yaml`):

> ‏حزم مخططة (من المهمة، وليست بعد في `pubspec.yaml`):

| Package | Use |
|---|---|
| `image_picker` | Avatar swap |
| `url_launcher` | Feedback / external legal & support links |

**Existing shared components to reuse** (`lib/shared/ui/`): `AppTopBar`, `AppBottomNavBar` (+`AppBottomNavItem` — the More tab itself), `AppCard` (hub list tiles), `AppButton`, `AppTextField` (profile edit), `AppBottomSheet` (confirm logout / delete), `EmptyState`/`ErrorState`/`LoadingState`. Strings via `context.l10n` (`shared/extensions/context_ext.dart`); theme tokens from `core/theme/app_tokens.dart`.

> ‏مكوّنات مشتركة قائمة يُعاد استخدامها من `lib/shared/ui/`: `AppTopBar`، `AppBottomNavBar` (وتبويب "المزيد" نفسه)، `AppCard` لبطاقات المركز، `AppButton`، `AppTextField` لتعديل الملف، `AppBottomSheet` لتأكيد الخروج/الحذف، وحالات `EmptyState`/`ErrorState`/`LoadingState`. النصوص عبر `context.l10n` ورموز الثيم من `core/theme/app_tokens.dart`.

## Testing expectations / توقّعات الاختبار

The epic does not enumerate a fixed test list (TBD — see [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40)); repo conventions imply:

> ‏لا تُعدّد المهمة قائمة اختبارات ثابتة (قيد التحديد — انظر app ‎#40)؛ لكن أعراف المستودع تقتضي:

- **Widget tests**: hub renders all entries, profile edit validation, avatar-swap and delete/logout confirmation flows.
- **Golden tests**: light/dark × RTL/LTR per the design-system pattern established by epic [app #29](https://github.com/YoussefSalem582/Osta-App/issues/29).
- **Unit tests**: repository/cubit mapping of `ApiException` → `Failure` (reuse `test/core/network/fakes.dart` helpers).

All gated by CI — a single "format · analyze · test" job (`flutter pub get` → `flutter gen-l10n` → `dart format --set-exit-if-changed` → `flutter analyze` → `flutter test`). No `build_runner` step; platform build jobs are deferred, see [ROADMAP](../../docs/ROADMAP.md).

> ‏كل ذلك محكوم بالـ CI عبر مهمة واحدة "format · analyze · test": `flutter pub get` ثم `flutter gen-l10n` ثم فحص التنسيق ثم `flutter analyze` ثم `flutter test`. لا خطوة `build_runner`، ومهام بناء المنصّات مؤجَّلة — انظر ROADMAP.

## Related docs / روابط ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- Sibling features: [Auth](auth.md) · [My Garage](garage.md) · [Terms, Privacy & About](legal-terms-about.md) · [Business More hub](business-more.md)
