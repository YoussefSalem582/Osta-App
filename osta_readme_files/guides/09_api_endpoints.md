# 🔌 API Endpoints / نقاط نهاية الـ API

> [INDEX](../INDEX.md) > API Endpoints
>
> Complete reference of the [osta_backend](https://github.com/YoussefSalem582/osta_backend/issues) API surface and the app's integration status per endpoint. Once the first API PR lands, app paths live in `lib/core/network/api_endpoints.dart` — never hardcode URLs.

> ‏مرجع كامل لواجهة الـ API الخاصة بـ [osta_backend](https://github.com/YoussefSalem582/osta_backend/issues) وحالة ربط التطبيق لكل نقطة نهاية. بمجرد نزول أول PR للـ API، تعيش مسارات التطبيق في `lib/core/network/api_endpoints.dart` — لا تكتب الروابط يدويًا أبدًا.

---

## Base configuration / الإعدادات الأساسية

The base URL comes from a single `BASE_URL` dart-define read into `AppConfig` — there are no build flavors. Every request rides the shared envelope and the typed error codes below.

> ‏يأتي الـ base URL من تعريف `BASE_URL` واحد عبر dart-define يُقرأ داخل `AppConfig` — لا توجد نكهات بناء (flavors). كل طلب يسير على نفس الـ envelope المشترك وأكواد الأخطاء المُصنّفة الموضّحة أدناه.

| Setting | Source |
|---|---|
| Base URL | `--dart-define=BASE_URL` → `AppConfig.baseUrl` (default `https://osta.technology92.com/api/v1`) |
| Prefix | all paths under `/api/v1` |
| Envelope | `{ success, data, meta }` / `{ success:false, error:{ code, message, details } }` |
| Error codes | `VALIDATION_ERROR` 422 · `UNAUTHENTICATED` 401 · `FORBIDDEN` 403 · `NOT_FOUND` 404 · `TOO_MANY_REQUESTS` 429 · `SERVER_ERROR` 5xx |
| Pagination meta | `{ current_page, last_page, per_page, total }` (`PaginationMeta`) |
| Auth | Sanctum bearer; dual token; single 401 refresh-retry via `AuthInterceptor` |
| Locale | `Accept-Language: ar\|en` (ar default) localizes `message`/validation |

---

## App status legend / دليل حالة التطبيق

Each endpoint is tagged with how far the app has wired it up today.

> ‏كل نقطة نهاية موسومة بمدى ربط التطبيق لها حتى اليوم.

| Status | Meaning |
|---|---|
| **Connected** | Already called from app code (only auth login/refresh/social exchange today) |
| **Planned** | Backend route shipped; app epic open, not yet wired |
| **Blocked** | Backend epic still open (payments M3.5, Phase 2) |

---

## Authentication / المصادقة

Login, refresh, and social exchange are the only endpoints the app calls today; the rest are backend-ready and awaiting their app epics.

> ‏تسجيل الدخول والتحديث وتبادل التوكن الاجتماعي هي نقاط النهاية الوحيدة التي يستدعيها التطبيق اليوم؛ والباقي جاهز في الـ backend وينتظر epics التطبيق الخاصة به.

| Method | Path | Purpose | Backend | App status |
|---|---|---|---|---|
| POST | `/auth/register` | Register (`account_type`, optional multipart `avatar`) | [#37](https://github.com/YoussefSalem582/osta_backend/issues/37)/[#40](https://github.com/YoussefSalem582/osta_backend/issues/40) | **Connected** (`AuthRepositoryImpl.register`) |
| GET | `/auth/check-username?username=` | Live username availability → `{available: bool}` (public) | [#37](https://github.com/YoussefSalem582/osta_backend/issues/37)/[#40](https://github.com/YoussefSalem582/osta_backend/issues/40) | **Connected** (`isUsernameAvailable`) |
| POST | `/auth/login` | Email+password login (`account_type`; bad creds → **422**) | [#37](https://github.com/YoussefSalem582/osta_backend/issues/37)/[#40](https://github.com/YoussefSalem582/osta_backend/issues/40) | **Connected** |
| POST | `/auth/refresh` | Exchange refresh → new token pair | [#37](https://github.com/YoussefSalem582/osta_backend/issues/37) | **Connected** (interceptor) |
| POST | `/auth/logout` | Revoke current token | [#37](https://github.com/YoussefSalem582/osta_backend/issues/37) | Planned |
| POST | `/auth/social/{google\|apple}` | Server-side Socialite token exchange | [#38](https://github.com/YoussefSalem582/osta_backend/issues/38) | **Connected** (`SocialTokenExchange`) |
| POST | `/auth/password/forgot` | Send reset email (public) | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) | **Shipped** (backend) — ⚠️ app calls the wrong path |
| POST | `/auth/password/reset` | Reset with token (public) | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) | **Shipped** (backend) — ⚠️ app calls the wrong path |

> ⚠️ **Mismatch.** `ApiEndpoints.authPasswordForgot` / `authPasswordReset` (`lib/core/network/api_endpoints.dart:16-17`) send `/forgot-password` and `/reset-password`. The backend registers `password/forgot` and `password/reset` inside `Route::prefix('auth')` (`routes/api/v1/auth.php:26-30`), under `Route::prefix('v1')` — so the real paths are `/api/v1/auth/password/{forgot,reset}`, and the app's calls 404. `git log -S"forgot-password" -- routes/` in the backend returns nothing, so the flat paths never existed there. Not changed here — it is a live auth path that wants verifying against the deployed server, not a drive-by edit inside a refactor.

---

## Account / الحساب

Profile, addresses, and account lifecycle. `GET /me` returns the roles and `type` that drive which shell the app shows.

> ‏الملف الشخصي والعناوين ودورة حياة الحساب. يُرجع `GET /me` الأدوار و`type` التي تحدد أي واجهة (shell) يعرضها التطبيق.

| Method | Path | Purpose | Backend | App status |
|---|---|---|---|---|
| GET | `/me` | Profile + roles + `type` + `support_id` (drives shell) | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| PUT | `/me` | Update profile (incl. `language_preference`) | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| POST | `/me/avatar` | Upload avatar (multipart) | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| GET / POST | `/me/addresses` | List / create saved address (PostGIS) | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| PUT / DELETE | `/me/addresses/{id}` | Update / delete address | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |
| DELETE | `/me` | Soft-delete account + revoke all tokens | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) | Planned |

---

## Discovery / الاكتشاف

Nearby PostGIS radius search, free-text search, and center detail — the customer-facing browse surface.

> ‏بحث نصف قطري بـ PostGIS للأماكن القريبة، وبحث نصي حر، وتفاصيل المركز — واجهة التصفح الموجّهة للعميل.

| Method | Path | Purpose | Backend | App status |
|---|---|---|---|---|
| GET | `/centers/nearby` | PostGIS radius search (`latitude`,`longitude` req; `radius`,`service`,`price_max`,`min_rating`,`open_now`) | [#41](https://github.com/YoussefSalem582/osta_backend/issues/41) | Planned |
| GET | `/centers/search` | Free-text + filters (`query`,`type`,…; rating-ordered) | [#41](https://github.com/YoussefSalem582/osta_backend/issues/41) | Planned |
| GET | `/centers/{center}` | Center profile (+counts) | [#42](https://github.com/YoussefSalem582/osta_backend/issues/42) | Planned |
| GET | `/centers/{center}/services` | Active services | [#42](https://github.com/YoussefSalem582/osta_backend/issues/42)/[#57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Planned |
| GET | `/centers/{center}/reviews` | Paginated reviews (+`meta.summary`) | [#42](https://github.com/YoussefSalem582/osta_backend/issues/42) | Planned |
| POST | `/centers/{center}/reviews` | Leave a centre review (auth) | [#42](https://github.com/YoussefSalem582/osta_backend/issues/42) | Planned — was undocumented (`routes/api/v1/reviews.php:20-21`) |
| GET | `/centers/{center}/availability?date=` | Slots `{start,end,available}` in center TZ | [#42](https://github.com/YoussefSalem582/osta_backend/issues/42) | Planned |
| GET | `/centers/{center}/products` | Center storefront | [#52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |

`type` ∈ `workshop | dealership | mobile | tire_shop | car_wash`. No verified filter — every center is live.

> ‏قيم `type` هي `workshop | dealership | mobile | tire_shop | car_wash`. لا يوجد فلتر "موثّق" — كل مركز يظهر مباشرةً.

---

## Booking (customer) / الحجز (العميل)

Create, confirm, reschedule, and cancel bookings. A create holds the slot for 10 minutes and returns **409 `slot_taken`** if it was grabbed first.

> ‏إنشاء الحجوزات وتأكيدها وإعادة جدولتها وإلغاؤها. الإنشاء يحجز الموعد لمدة 10 دقائق ويُرجع **409 `slot_taken`** لو تم أخذه أولًا.

| Method | Path | Purpose | Backend | App status |
|---|---|---|---|---|
| POST | `/bookings` | Create (`service_center_id`,`vehicle_id`,`service_ids[]`,`slot_start`) → 201; **409 `slot_taken`**; 10-min hold | [#43](https://github.com/YoussefSalem582/osta_backend/issues/43) | Planned |
| POST | `/bookings/{id}/confirm` | Confirm (clears hold) | [#44](https://github.com/YoussefSalem582/osta_backend/issues/44) | Planned |
| PATCH | `/bookings/{id}/reschedule` | Re-runs availability | [#44](https://github.com/YoussefSalem582/osta_backend/issues/44) | Planned |
| POST | `/bookings/{id}/cancel` | Cancel (`reason`) + refund eligibility | [#44](https://github.com/YoussefSalem582/osta_backend/issues/44) | Planned |
| GET | `/bookings?status=upcoming\|past` | Owner list | [#45](https://github.com/YoussefSalem582/osta_backend/issues/45) | Planned |
| GET | `/bookings/{id}` | Rich detail (items snapshot, status, center+vehicle) | [#45](https://github.com/YoussefSalem582/osta_backend/issues/45) | Planned |

---

## Booking & business (provider) / الحجز والأعمال (مقدّم الخدمة)

The provider side: booking feed, accept/reject/advance, dashboard, catalog, capacity, and team roster.

> ‏جانب مقدّم الخدمة: خلاصة الحجوزات، القبول/الرفض/التقدّم في الحالة، لوحة التحكم، الكتالوج، السعة، وقائمة الفريق.

| Method | Path | Purpose | Backend | App status |
|---|---|---|---|---|
| GET | `/business/bookings?date=&status=` | Provider feed | [#46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/accept` | Accept | [#46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/reject` | Reject (`reason`) | [#46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/status` | Advance state | [#46](https://github.com/YoussefSalem582/osta_backend/issues/46) | Planned |
| PATCH | `/business/bookings/{id}/assign-mechanic` | `{mechanic_id\|null}` (active same-center or 422) | [#46](https://github.com/YoussefSalem582/osta_backend/issues/46)/[#64](https://github.com/YoussefSalem582/osta_backend/issues/64) | Planned |
| PATCH | `/business/bookings/{id}/assign-roster-mechanic` | Assign from the no-login mechanic roster | [#64](https://github.com/YoussefSalem582/osta_backend/issues/64) | Planned — was undocumented (`routes/api/v1/business.php:71`) |
| GET | `/business/dashboard` | Counts + revenue | [#51](https://github.com/YoussefSalem582/osta_backend/issues/51) | Planned |
| PUT | `/business/profile` | Business info (multipart logo) | [#56](https://github.com/YoussefSalem582/osta_backend/issues/56) | **Connected** (`BusinessOnboardingRepository`) |
| GET | `/business/catalog/presets` | 12 seeded catalog presets | [#56](https://github.com/YoussefSalem582/osta_backend/issues/56) | **Connected** |
| POST | `/business/catalog` | Bulk-attach (≥1) | [#56](https://github.com/YoussefSalem582/osta_backend/issues/56) | **Connected** |
| PUT | `/business/capacity` | Weekly slots/breaks/holidays | [#56](https://github.com/YoussefSalem582/osta_backend/issues/56) | Planned |
| GET/POST | `/business/services` (+ PUT/DELETE `/{id}`) | Services CRUD | [#57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Planned |
| GET/POST | `/business/promotions` (+ PUT/DELETE `/{id}`) | Promotions CRUD | [#57](https://github.com/YoussefSalem582/osta_backend/issues/57) | Planned |
| GET/POST/PATCH/DELETE | `/business/mechanics` (`/{id}`) | Team roster (no login) | [#64](https://github.com/YoussefSalem582/osta_backend/issues/64) | Planned |

Statuses: `pending, confirmed, in_progress, completed, cancelled, invoiced`.

> ‏الحالات: `pending, confirmed, in_progress, completed, cancelled, invoiced`.

---

## Vehicles & maintenance / المركبات والصيانة

The customer's garage: vehicles CRUD, primary selection, maintenance records, and a PDF export of the history.

> ‏جراج العميل: عمليات CRUD للمركبات، اختيار المركبة الأساسية، سجلات الصيانة، وتصدير السجل كملف PDF.

| Method | Path | Purpose | Backend | App status |
|---|---|---|---|---|
| GET/POST | `/vehicles` | List / create (first = primary) | [#54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| GET/PUT/DELETE | `/vehicles/{id}` | Detail / update / soft-delete | [#54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| POST | `/vehicles/{id}/primary` | Set primary | [#54](https://github.com/YoussefSalem582/osta_backend/issues/54) | Planned |
| GET/POST | `/vehicles/{id}/maintenance` | Records (multipart receipt) | [#55](https://github.com/YoussefSalem582/osta_backend/issues/55) | Planned |
| GET | `/vehicles/{id}/maintenance/export` | PDF stream | [#55](https://github.com/YoussefSalem582/osta_backend/issues/55) | Planned |

---

## Payments & invoices ⛔ / المدفوعات والفواتير ⛔

Payments are blocked until the backend epic ships (M3.5, Phase 2). The Paymob webhook is server-to-server — the app never calls it.

> ‏المدفوعات محجوبة حتى ينزل epic الـ backend (M3.5، المرحلة 2). ويب هوك Paymob بين الخوادم فقط — التطبيق لا يستدعيه أبدًا.

| Method | Path | Purpose | Backend | App status |
|---|---|---|---|---|
| POST | `/payments/intent` | `{booking_id, method: wallet\|instapay}` → `checkout_url` | [#47](https://github.com/YoussefSalem582/osta_backend/issues/47) | **Blocked** (BE open) |
| POST | `/payments/{booking}/confirm` | Client reconcile | be #12 | **Blocked** |
| POST | `/webhooks/paymob` | Server-to-server HMAC (app never calls) | [#48](https://github.com/YoussefSalem582/osta_backend/issues/48) | n/a |
| GET | `/invoices/{id}` | Invoice + signed `pdf_url` | [#49](https://github.com/YoussefSalem582/osta_backend/issues/49) | **Blocked** |

---

## Shop / المتجر

Browse products and storefronts and send an enquiry — there is no cart and no checkout.

> ‏تصفّح المنتجات والمتاجر وإرسال استفسار — لا توجد عربة تسوّق ولا إتمام شراء.

| Method | Path | Purpose | Backend | App status |
|---|---|---|---|---|
| GET | `/products?q=&category=` | Browse | [#52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| GET | `/products/{id}` | Detail | [#52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| GET | `/centers/{id}/products` · `/users/{id}/products` | Storefronts | [#52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| POST | `/products/{id}/enquiries` | Contact lead (`message`) | [#52](https://github.com/YoussefSalem582/osta_backend/issues/52) | Planned |
| GET/POST/PUT/DELETE | `/me/products` (`/{id}`) | Manage own listings (owner server-resolved) | [#53](https://github.com/YoussefSalem582/osta_backend/issues/53) | Planned |
| GET | `/users/{id}/reviews` | Shop reviews | [#53](https://github.com/YoussefSalem582/osta_backend/issues/53) | Planned |
| POST | `/users/{user}/reviews` | Leave a shop review (auth) | [#53](https://github.com/YoussefSalem582/osta_backend/issues/53) | Planned — was undocumented (`routes/api/v1/reviews.php:18-19`) |

No cart, no checkout — browse + enquire only.

> ‏لا عربة ولا إتمام شراء — تصفّح واستفسار فقط.

---

## Notifications & realtime / الإشعارات واللحظية

FCM device registration, the notification inbox, and Reverb websocket channels. Note `/broadcasting/auth` sits **outside** `/api/v1`.

> ‏تسجيل أجهزة FCM، صندوق الإشعارات، وقنوات websocket الخاصة بـ Reverb. لاحظ أن `/broadcasting/auth` يقع **خارج** `/api/v1`.

| Method | Path / Channel | Purpose | Backend | App status |
|---|---|---|---|---|
| POST | `/devices` | Register FCM token (`token`,`platform`) | [#59](https://github.com/YoussefSalem582/osta_backend/issues/59) | Planned |
| DELETE | `/devices/{token}` | Revoke on logout | [#59](https://github.com/YoussefSalem582/osta_backend/issues/59) | Planned |
| GET | `/notifications` | Paginated inbox | [#59](https://github.com/YoussefSalem582/osta_backend/issues/59) | Planned |
| POST | `/notifications/{id}/read` | Mark read | [#59](https://github.com/YoussefSalem582/osta_backend/issues/59) | Planned |
| POST | `/broadcasting/auth` | Reverb channel auth (Sanctum; **not** under `/api/v1`) | [#50](https://github.com/YoussefSalem582/osta_backend/issues/50) | Planned |
| WS | `private-users.{id}` · `private-bookings.{id}` · `private-centers.{id}` | Reverb events | [#50](https://github.com/YoussefSalem582/osta_backend/issues/50)/[#51](https://github.com/YoussefSalem582/osta_backend/issues/51) | Planned |

---

## Legal / القانونية

Versioned bilingual terms and privacy docs, served publicly and localized via `Accept-Language`.

> ‏وثائق الشروط والخصوصية ثنائية اللغة ومُصدَّرة بإصدارات، تُقدَّم للعامة وتُترجم عبر `Accept-Language`.

| Method | Path | Purpose | Backend | App status |
|---|---|---|---|---|
| GET | `/legal/terms` · `/legal/privacy` | Versioned bilingual docs (public, `Accept-Language`) | [#58](https://github.com/YoussefSalem582/osta_backend/issues/58) | **Blocked** — no route, no controller in the backend (was "Planned", which per the legend claims the route ships) |

---

## Admin / الإدارة

There is no mobile API for admin — it is a Filament 3 web UI at `/admin`, restricted to the `admin` role.

> ‏لا يوجد API للموبايل للإدارة — إنها واجهة ويب بـ Filament 3 على `/admin`، مقصورة على دور `admin`.

No mobile API — Filament 3 web UI at `/admin` (`admin` role only), [backend #61](https://github.com/YoussefSalem582/osta_backend/issues/61).

---

## Phase 2 (flagged, not final) ⛔ / المرحلة 2 (مبدئية، غير نهائية) ⛔

These routes are flagged for a later phase and are not final — payouts, subscriptions, provider capabilities, live tracking, customer notes, and expense/fuel/reminder logs.

> ‏هذه المسارات مُعلَّمة لمرحلة لاحقة وليست نهائية — المدفوعات للمقدّمين، الاشتراكات، قدرات المقدّم، التتبّع اللحظي، ملاحظات العملاء، وسجلات المصروفات/الوقود/التذكيرات.

`GET /provider/payouts` · `GET /subscription-plans` · `POST /subscriptions` · `POST /provider/capabilities` · `POST /jobs/{job}/location` (+ WS `tracking.{jobId}`) · `GET/POST /provider/customers/{customer}/notes` · `/expenses` · `/fuel-logs` · `/maintenance-reminders` — all [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62).

---

## Telemetry / القياس

Shipped in the backend, undocumented here until now (`routes/api/v1/telemetry.php:17`). `ApiEndpoints.telemetryBroadcastLatency` already exists in the app but nothing calls it.

| Method | Path | Purpose | Backend | App |
|---|---|---|---|---|
| POST | `/telemetry/broadcast-latency` | Report realtime broadcast latency | — | Planned |

---

## Related / ذات صلة

- [04_how_to_add_new_api.md](04_how_to_add_new_api.md) · [11_backend_feature_connectivity.md](11_backend_feature_connectivity.md) · [../reference/DELIVERY_PLAN.md](../reference/DELIVERY_PLAN.md)
