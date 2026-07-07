> [INDEX](../INDEX.md) > [Features](README.md) > Payments

# 💳 Payments — Paymob wallets + InstaPay / المدفوعات — محافظ Paymob وإنستاباي

## Overview / نظرة عامة

Online payment for bookings through Paymob **hosted checkout** — no native Paymob SDK. The app supports Egyptian mobile wallets (Vodafone / WE / Etisalat / Orange Cash) and **InstaPay**: it creates a payment intention, opens the returned checkout URL in `webview_flutter`, then polls the payment status until it settles as paid or failed. A successful payment produces an AR/RTL EGP PDF invoice served via a short-lived signed URL. Retries are idempotent (client-supplied idempotency key). Cash pay-at-center stays the MVP default from the booking funnel (app #44); this epic adds the online path at milestone **M3.5**. Nothing is built yet — `lib/features/customer/wallet/` is an empty stub and all three mirrored backend epics are still open, so the whole feature is **Blocked**.

> ‏الدفع الإلكتروني للحجوزات عبر صفحة الدفع المستضافة من Paymob — بدون SDK أصلي. يدعم التطبيق المحافظ الإلكترونية المصرية (فودافون كاش، WE، اتصالات كاش، أورنج كاش) بالإضافة إلى إنستاباي: ينشئ التطبيق نية دفع، ثم يفتح رابط الدفع داخل `webview_flutter`، ويستعلم دوريًا عن حالة الدفع حتى تنتهي بالنجاح أو الفشل. عند نجاح الدفع تُنشأ فاتورة PDF بالجنيه المصري وبتنسيق عربي عبر رابط موقّع قصير الأجل، مع إعادة محاولة آمنة (idempotent). يظل الدفع نقدًا في المركز هو الخيار الافتراضي للنسخة الأولى؛ هذه الميزة مخططة في المرحلة M3.5 ولم يُبنَ منها شيء بعد — المجلد `lib/features/customer/wallet/` فارغ وجميع مهام الخلفية الثلاث المقابلة ما زالت مفتوحة، لذا فالميزة **محجوبة (Blocked)**.

## Status & Issues / الحالة والمهام

The tracking issue and its blocking backend epics are listed below.

> ‏المهمة المتتبِّعة ومهام الخلفية المُعطِّلة لها موضّحة في الجدول التالي.

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46) | Payments — Paymob wallets + InstaPay | Open | M3.5 | p1 | roaa | [backend #47](https://github.com/YoussefSalem582/osta_backend/issues/47) intent · [backend #48](https://github.com/YoussefSalem582/osta_backend/issues/48) webhook · [backend #49](https://github.com/YoussefSalem582/osta_backend/issues/49) invoices — all open → **blocked** |

M3.5 payments is the only remaining MVP feature work on the backend (per backend tracker [#63](https://github.com/YoussefSalem582/osta_backend/issues/63)). The app epic carries the `backend:blocked` label; as of 2026-07-02 that label is accurate — none of #47/#48/#49 has merged.

> ‏مدفوعات المرحلة M3.5 هي آخر أعمال ميزات النسخة الأولى المتبقّية على الخلفية (حسب متتبّع الخلفية [#63](https://github.com/YoussefSalem582/osta_backend/issues/63)). تحمل المهمة الوسم `backend:blocked`، وحتى تاريخ 2026-07-02 هذا الوسم دقيق — لم يُدمَج أيٌّ من #47/#48/#49 بعد.

## Screens / Mockups / الشاشات والتصاميم

**Payment & wallet**

![Payment and wallet](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/12-payment-and-wallet.png)

## Planned architecture / البنية المخططة

Everything below is **planned / specified by epic [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46)** — the feature folder `lib/features/customer/wallet/` currently contains no Dart files.

> ‏كل ما يلي **مخطَّط ومحدَّد في المهمة [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46)** — مجلد الميزة `lib/features/customer/wallet/` لا يحتوي حاليًا على أي ملفات Dart.

- **Layers**: Clean Architecture `data → domain ← presentation` inside `lib/features/customer/wallet/`, matching the repo convention.
- **State**: a payment Cubit (`flutter_bloc`; exact class names TBD — see epic) driving the lifecycle: create intent → open hosted checkout → poll status → show paid / failed result → link invoice.
- **Data flow**: a wallet repository calls the envelope-aware `ApiClient` (`lib/core/network/api_client.dart`) → `ApiResult<T>` or a typed `ApiException` (e.g. a gateway failure surfaces as 502 → `ServerException`). The repository catches those and **throws** a sealed `Failure` (`lib/core/error/failure.dart`); the Cubit wraps its calls in plain `try`/`catch` — no `Either`, no `.fold()`, no `Result<T>`. Failures render `ErrorState` with retry.
- **Checkout**: `POST /payments/intent` returns `metadata.checkout_url` (Paymob Unified Intention API); the app opens it in `webview_flutter` — **no Paymob SDK**. Settlement happens server-side via the HMAC webhook ([backend #48](https://github.com/YoussefSalem582/osta_backend/issues/48)); the app only **polls** `GET /payments/{id}` (`pending | paid | failed`).
- **Idempotency**: the client sends an `idempotency_key` with the intent so retries after network drops never double-charge.
- **Invoices**: on success, fetch `GET /invoices/{id}` → invoice + short-lived signed `pdf_url` (never cache the URL).
- **DI**: register the repository and Cubit with a hand-written `getIt.registerLazySingleton` / `registerFactory` line in `configureDependencies()` (`lib/core/di/injection.dart`) — manual `get_it`, no annotations, no codegen.
- **Routing**: a `go_router` route under the customer shell — the shells themselves are still planned ([app #34](https://github.com/YoussefSalem582/Osta-App/issues/34)); today the router only has `/splash` and `/role`. Entry points: booking funnel ([app #44](https://github.com/YoussefSalem582/Osta-App/issues/44)) and booking detail ([app #45](https://github.com/YoussefSalem582/Osta-App/issues/45)).

The error, DI, and model layers use plain Dart — sealed `Failure` + `try`/`catch`, manual `get_it` registration, and `Equatable` models with hand-written `fromJson`/`toJson`. Functional errors (`fpdart`) and model/DI codegen (`freezed`, `json_serializable`, `injectable`) are **deferred**, not rejected; see the team's phased plan in [`docs/ROADMAP.md`](../../docs/ROADMAP.md).

> ‏تستخدم طبقات الأخطاء والـ DI والنماذج لغة Dart بسيطة — `Failure` من نوع sealed مع `try`/`catch`، وتسجيل يدوي في `get_it`، ونماذج `Equatable` بدوال `fromJson`/`toJson` مكتوبة يدويًا. أما الأخطاء الوظيفية (`fpdart`) وتوليد الكود للنماذج والـ DI (`freezed` و`json_serializable` و`injectable`) فهي **مؤجَّلة** وليست مرفوضة؛ راجع خطة الفريق المرحلية في [`docs/ROADMAP.md`](../../docs/ROADMAP.md).

## API endpoints / نقاط نهاية الـ API

Base `/api/v1`, Sanctum bearer, `{success, data, meta?}` envelope.

> ‏المسار الأساسي `/api/v1`، مصادقة Sanctum bearer، وغلاف استجابة `{success, data, meta?}`.

| Method | Path | Purpose | Source issue | App status |
|---|---|---|---|---|
| POST | `/payments/intent` | Create payment intention `{booking_id, method: wallet or instapay, idempotency_key}` → 201 with `metadata.checkout_url` | [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46) / [backend #47](https://github.com/YoussefSalem582/osta_backend/issues/47) | **Blocked** |
| GET | `/payments/{id}` | Poll payment status: `pending`, `paid`, `failed` | [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46) / [backend #47](https://github.com/YoussefSalem582/osta_backend/issues/47) | **Blocked** |
| GET | `/invoices/{id}` | Invoice + short-lived signed `pdf_url` (never cache) | [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46) / [backend #49](https://github.com/YoussefSalem582/osta_backend/issues/49) | **Blocked** |
| POST | `/webhooks/paymob` | Paymob → server HMAC-SHA512 callback; settles payment, confirms held booking | [backend #48](https://github.com/YoussefSalem582/osta_backend/issues/48) | — (server-to-server, never called by the app) |

## Packages & shared widgets / الحزم والمكوّنات المشتركة

**Planned packages** (from the epic, not yet in `pubspec.yaml`):

> ‏حزم مخططة (من المهمة، لم تُضَف بعد إلى `pubspec.yaml`):

| Package | Why |
|---|---|
| `webview_flutter` | Render the Paymob hosted-checkout URL in-app |

**Existing shared components to reuse** (`lib/shared/`):

> ‏مكوّنات مشتركة قائمة يُعاد استخدامها (`lib/shared/`):

- `AppTopBar`, `AppButton`, `AppCard`, `AppBottomSheet` — checkout entry, method picker, result sheet
- `EmptyState` / `ErrorState` / `LoadingState` (`shared/ui/status_states.dart`) — pending-poll and failure UI
- `EgpFormatter` (`shared/formatters/app_formatters.dart`) — EGP amounts, Arabic-Indic digits
- `context.l10n` (`shared/extensions/context_ext.dart`) — all strings via ARB, Arabic default

## Testing expectations / توقعات الاختبار

The epic does not enumerate a test matrix (TBD — see [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46)); repo conventions imply:

> ‏لا تحدّد المهمة مصفوفة اختبارات (قيد التحديد — راجع [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46))؛ لكن أعراف المستودع تقتضي ما يلي:

- **Unit**: payment Cubit lifecycle (intent → poll → paid/failed), idempotent-retry behaviour, error mapping — using `http_mock_adapter` / the fakes pattern in `test/core/network/fakes.dart`.
- **Widget**: pending / paid / failed states render the right status components; duplicate-submit guarded.
- **Golden**: key payment screens light/dark × RTL/LTR, per the design-system pattern (app #29).

## Related docs / وثائق ذات صلة

- [API endpoints guide](../guides/09_api_endpoints.md)
- [Delivery plan](../reference/DELIVERY_PLAN.md)
- [Roadmap — deferred tooling plan](../../docs/ROADMAP.md)
- Sibling features: [Home dashboard](home-dashboard.md) · [Auth](auth.md) · [Account & More](account-more.md)
