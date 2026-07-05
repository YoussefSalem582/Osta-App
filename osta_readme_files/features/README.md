> [INDEX](../INDEX.md) > Features

# 🧩 Features / الميزات

One doc per feature area, matched **1:1 to the GitHub epics** of [Osta-App](https://github.com/YoussefSalem582/Osta-App/issues) and [osta_backend](https://github.com/YoussefSalem582/osta_backend/issues).

> ‏مستند واحد لكل نطاق ميزة، مطابق **واحد لواحد لِـ epics على GitHub** لمستودعَي [Osta-App](https://github.com/YoussefSalem582/Osta-App/issues) و[osta_backend](https://github.com/YoussefSalem582/osta_backend/issues).

The app is at the **M0 foundation stage** (scaffolding + CI, design system, and networking merged) — most feature folders under `lib/features/` are stubs. The codebase is deliberately **plain Dart with no codegen**: models are `Equatable` classes with hand-written `fromJson`/`toJson`, DI is manual `get_it` registration, and errors are a sealed `Failure` caught with plain `try`/`catch`. Advanced tooling (freezed, injectable, fpdart, build flavors) is **deferred, not rejected** — see the phased plan in [`docs/ROADMAP.md`](../../docs/ROADMAP.md). Each doc here is therefore a **spec-mirror of its epic(s)** plus the *current* code status: what already exists in the repo, what is planned, and what is blocked on the backend. Nothing in these docs describes unbuilt screens as existing.

> ‏التطبيق في **مرحلة الأساس M0** (السقالة الأساسية + CI، ونظام التصميم، وطبقة الشبكة تم دمجها) — ومعظم مجلدات الميزات تحت `lib/features/` مجرد هياكل مبدئية. الكود مكتوب عن قصد بـ **Dart بسيط بدون توليد كود**: النماذج فئات `Equatable` بدوال `fromJson`/`toJson` مكتوبة يدويًا، وحقن التبعيات تسجيل يدوي عبر `get_it`، والأخطاء فئة `Failure` مغلقة تُلتقط بـ `try`/`catch` عادي. الأدوات المتقدمة (freezed وinjectable وfpdart ونكهات البناء) **مؤجَّلة وليست مرفوضة** — راجع الخطة المرحلية في [`docs/ROADMAP.md`](../../docs/ROADMAP.md). لذلك كل مستند هنا هو **مرآة لمواصفات الـ epic الخاص به** بالإضافة إلى حالة الكود *الحالية*: ما هو موجود بالفعل في المستودع، وما هو مخطَّط، وما هو محجوب في انتظار الـ backend. لا شيء في هذه المستندات يصف شاشات غير مبنية على أنها موجودة.

**Bilingual convention**: every feature doc opens with an Overview in English first, followed by the Arabic translation as an RTL blockquote (`> ‏...`). Identifiers — code, file paths, endpoints, class names — always stay English. Full bilingual bodies live in the linked GitHub issues.

> ‏**اتفاقية ثنائية اللغة**: كل مستند ميزة يبدأ بنظرة عامة بالإنجليزية أولًا، تليها الترجمة العربية كاقتباس بمحاذاة لليمين (`> ‏...`). المعرِّفات — الكود ومسارات الملفات ونقاط النهاية وأسماء الفئات — تظل دائمًا بالإنجليزية. النصوص الكاملة ثنائية اللغة موجودة في مسائل GitHub المرتبطة.

## Feature index / فهرس الميزات

Status legend: **Planned** = epic open, not started · **In progress** = some code merged · **Blocked** = waiting on open backend epics · **Phase 2** = explicitly post-MVP.

> ‏مفتاح الحالة: **Planned** = الـ epic مفتوح ولم يبدأ · **In progress** = بعض الكود تم دمجه · **Blocked** = في انتظار epics غير منتهية في الـ backend · **Phase 2** = ما بعد الحد الأدنى للمنتج صراحةً.

| Feature | Doc | Epics | Status |
|---|---|---|---|
| **Shared / first-run** | | | |
| Splash, language select & onboarding | [splash-language-onboarding.md](splash-language-onboarding.md) | [app #37](https://github.com/YoussefSalem582/Osta-App/issues/37) + splash session-refresh routing from [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32) | In progress — `splash_page.dart` stub exists (2s intro) |
| First-run role split, role chooser & role-aware shells | [role-selection-and-routing.md](role-selection-and-routing.md) | [app #32](https://github.com/YoussefSalem582/Osta-App/issues/32), [app #33](https://github.com/YoussefSalem582/Osta-App/issues/33), [app #34](https://github.com/YoussefSalem582/Osta-App/issues/34) | In progress — `/role` + `/splash` are the **only** implemented feature pages today (`role_selection_page.dart`, `splash_page.dart`) |
| Auth — email+password + social login | [auth.md](auth.md) | [app #35](https://github.com/YoussefSalem582/Osta-App/issues/35), [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36) (backend [#37](https://github.com/YoussefSalem582/osta_backend/issues/37), [#38](https://github.com/YoussefSalem582/osta_backend/issues/38), [#40](https://github.com/YoussefSalem582/osta_backend/issues/40)) | In progress — core pieces merged: `AuthInterceptor`, `TokenStorage`, `SocialTokenExchange`, `auth_token_model.dart`; screens planned |
| Terms, Privacy & About | [legal-terms-about.md](legal-terms-about.md) | [app #38](https://github.com/YoussefSalem582/Osta-App/issues/38) (backend [#58](https://github.com/YoussefSalem582/osta_backend/issues/58)) | Planned |
| Required car onboarding (add first car) | [car-onboarding.md](car-onboarding.md) | [app #39](https://github.com/YoussefSalem582/Osta-App/issues/39) (backend [#54](https://github.com/YoussefSalem582/osta_backend/issues/54)) | Planned |
| Account & More hub | [account-more.md](account-more.md) | [app #40](https://github.com/YoussefSalem582/Osta-App/issues/40) (backend [#39](https://github.com/YoussefSalem582/osta_backend/issues/39)) | Planned |
| **Customer (B2C)** | | | |
| Home dashboard (hybrid feed) | [home-dashboard.md](home-dashboard.md) | [app #51](https://github.com/YoussefSalem582/Osta-App/issues/51) | Planned |
| Map, discovery, filters & search | [map-discovery.md](map-discovery.md) | [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41) + [app #43](https://github.com/YoussefSalem582/Osta-App/issues/43) (backend [#41](https://github.com/YoussefSalem582/osta_backend/issues/41)) | Planned |
| Service center profile / details | [center-profile.md](center-profile.md) | [app #42](https://github.com/YoussefSalem582/Osta-App/issues/42) (backend [#42](https://github.com/YoussefSalem582/osta_backend/issues/42), [#57](https://github.com/YoussefSalem582/osta_backend/issues/57)) | Planned |
| Booking funnel (cash MVP) | [booking-funnel.md](booking-funnel.md) | [app #44](https://github.com/YoussefSalem582/Osta-App/issues/44) (backend [#43](https://github.com/YoussefSalem582/osta_backend/issues/43), [#44](https://github.com/YoussefSalem582/osta_backend/issues/44)) | Planned |
| My bookings, booking detail & realtime status | [my-bookings.md](my-bookings.md) | [app #45](https://github.com/YoussefSalem582/Osta-App/issues/45) + [app #47](https://github.com/YoussefSalem582/Osta-App/issues/47) (backend [#45](https://github.com/YoussefSalem582/osta_backend/issues/45), [#50](https://github.com/YoussefSalem582/osta_backend/issues/50), [#51](https://github.com/YoussefSalem582/osta_backend/issues/51)) | Planned |
| Payments — Paymob wallets + InstaPay | [payments.md](payments.md) | [app #46](https://github.com/YoussefSalem582/Osta-App/issues/46) (backend [#47](https://github.com/YoussefSalem582/osta_backend/issues/47), [#48](https://github.com/YoussefSalem582/osta_backend/issues/48), [#49](https://github.com/YoussefSalem582/osta_backend/issues/49) — all still open) | **Blocked** |
| My Garage — vehicles + maintenance | [garage.md](garage.md) | [app #50](https://github.com/YoussefSalem582/Osta-App/issues/50) (backend [#54](https://github.com/YoussefSalem582/osta_backend/issues/54), [#55](https://github.com/YoussefSalem582/osta_backend/issues/55)) | Planned |
| **Business (B2B)** | | | |
| Business onboarding & registration | [business-onboarding.md](business-onboarding.md) | [app #53](https://github.com/YoussefSalem582/Osta-App/issues/53) (backend [#56](https://github.com/YoussefSalem582/osta_backend/issues/56), [#40](https://github.com/YoussefSalem582/osta_backend/issues/40)) | Planned |
| Business dashboard (provider shell home) | [business-dashboard.md](business-dashboard.md) | [app #54](https://github.com/YoussefSalem582/Osta-App/issues/54) (backend [#51](https://github.com/YoussefSalem582/osta_backend/issues/51), [#50](https://github.com/YoussefSalem582/osta_backend/issues/50)) | Planned |
| Business bookings management + team assignment | [business-bookings.md](business-bookings.md) | [app #55](https://github.com/YoussefSalem582/Osta-App/issues/55) + [app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) (backend [#46](https://github.com/YoussefSalem582/osta_backend/issues/46), [#64](https://github.com/YoussefSalem582/osta_backend/issues/64)) | Planned |
| Business catalog & pricing management | [business-catalog.md](business-catalog.md) | [app #56](https://github.com/YoussefSalem582/Osta-App/issues/56) (backend [#57](https://github.com/YoussefSalem582/osta_backend/issues/57)) | Planned |
| **Cross-role** | | | |
| Shop — two-sided marketplace | [shop.md](shop.md) | [app #48](https://github.com/YoussefSalem582/Osta-App/issues/48), [app #49](https://github.com/YoussefSalem582/Osta-App/issues/49) (phase 2), [app #57](https://github.com/YoussefSalem582/Osta-App/issues/57) (backend [#52](https://github.com/YoussefSalem582/osta_backend/issues/52), [#53](https://github.com/YoussefSalem582/osta_backend/issues/53)) | Planned |
| Notifications inbox + FCM push | [notifications.md](notifications.md) | [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52) (backend [#59](https://github.com/YoussefSalem582/osta_backend/issues/59)) | Planned |
| **Phase 2** | | | |
| Business More hub + management extras | [business-more.md](business-more.md) | [app #58](https://github.com/YoussefSalem582/Osta-App/issues/58) (backend: blocked) | **Blocked** — Phase 2 |
| Provider roles backlog — solo mechanic & tow truck | [provider-roles-backlog.md](provider-roles-backlog.md) | [app #59](https://github.com/YoussefSalem582/Osta-App/issues/59), [app #60](https://github.com/YoussefSalem582/Osta-App/issues/60) (backend [#62](https://github.com/YoussefSalem582/osta_backend/issues/62); both backend:blocked) | **Blocked** — Phase 2, ship as "coming soon" cards in the role chooser |

## Conventions / الاصطلاحات

Every feature doc follows the same section order:

> ‏كل مستند ميزة يتبع نفس ترتيب الأقسام:

1. **Overview** — bilingual: English paragraph first, then Arabic as an RTL blockquote.
2. **Status & Issues** — epic links (app + backend), milestone, owner, open/closed state.
3. **Screens / Mockups** — mockup images from the `design-assets` branch (`mockups/`).
4. **Planned architecture** — bloc/cubit design, data flow through data → domain ← presentation, with `Equatable` models, manual `get_it` registration, and sealed `Failure` + `try`/`catch` error handling (no codegen, no `Either` — deferred, see [`docs/ROADMAP.md`](../../docs/ROADMAP.md)).
5. **API endpoints** — table with columns Method | Path | Purpose | Source issue | App status. App-status legend: **Connected** (already called from `lib/core/network` — only auth login/refresh/social exchange today), **Planned** (epic open, not yet wired), **Blocked** (backend epic not merged).
6. **Packages & shared widgets** — planned packages (not yet in `pubspec.yaml`) and shared UI from `lib/shared/ui/`.
7. **Testing expectations** — widget/golden tests called out by the epic.
8. **Related docs & links**.

> ‏1. **Overview** — ثنائية اللغة: فقرة إنجليزية أولًا، ثم العربية كاقتباس بمحاذاة لليمين.
> ‏2. **Status & Issues** — روابط الـ epic (التطبيق + الـ backend)، والمرحلة (milestone)، والمالك، وحالة الفتح/الإغلاق.
> ‏3. **Screens / Mockups** — صور التصاميم من فرع `design-assets` (`mockups/`).
> ‏4. **Planned architecture** — تصميم bloc/cubit، وتدفق البيانات عبر data → domain ← presentation، بنماذج `Equatable`، وتسجيل يدوي عبر `get_it`، ومعالجة الأخطاء بفئة `Failure` مغلقة مع `try`/`catch` (بدون توليد كود، وبدون `Either` — مؤجَّل، راجع [`docs/ROADMAP.md`](../../docs/ROADMAP.md)).
> ‏5. **API endpoints** — جدول بأعمدة Method | Path | Purpose | Source issue | App status. مفتاح حالة التطبيق: **Connected** (يُستدعى بالفعل من `lib/core/network` — فقط تسجيل الدخول/التحديث/تبادل التوكن الاجتماعي حاليًا)، و**Planned** (الـ epic مفتوح ولم يُوصَّل بعد)، و**Blocked** (الـ epic الخاص بالـ backend لم يُدمج).
> ‏6. **Packages & shared widgets** — الحزم المخطَّطة (ليست في `pubspec.yaml` بعد) وعناصر الواجهة المشتركة من `lib/shared/ui/`.
> ‏7. **Testing expectations** — اختبارات widget/golden المحددة في الـ epic.
> ‏8. **Related docs & links**.
