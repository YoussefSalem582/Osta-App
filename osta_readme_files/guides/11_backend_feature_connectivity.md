# 🔗 Backend ↔ App Feature Connectivity / ربط ميزات الـ Backend بالتطبيق

> [INDEX](../INDEX.md) > Backend ↔ App Connectivity

The cross-repo audit: which [osta_backend](https://github.com/YoussefSalem582/osta_backend/issues) epics are shipped, which [Osta-App](https://github.com/YoussefSalem582/Osta-App/issues) epics consume them, and what's blocked. Endpoint-level status lives in [09_api_endpoints.md](09_api_endpoints.md); milestone/owner detail in [../reference/DELIVERY_PLAN.md](../reference/DELIVERY_PLAN.md).

> ‏مراجعة عبر المستودعين: أي epics في الـ backend اتسلّمت، أي epics في التطبيق بتستهلكها، وإيه اللي متوقّف. حالة كل endpoint موجودة في [09_api_endpoints.md](09_api_endpoints.md)، وتفاصيل الـ milestone والمسؤولين في [../reference/DELIVERY_PLAN.md](../reference/DELIVERY_PLAN.md).

> **Note / ملاحظة:** This audit covers the app↔backend product surface only. The app's internal architecture was simplified (plain Equatable models, manual `get_it`, sealed `Failure` + try/catch, single `BASE_URL`) — advanced tooling is deferred, see [../../docs/ROADMAP.md](../../docs/ROADMAP.md). The backend contract below is unchanged.
>
> ‏المراجعة دي بتغطّي سطح المنتج بين التطبيق والـ backend بس. البنية الداخلية للتطبيق اتبسّطت (موديلات `Equatable` عادية، تسجيل يدوي في `get_it`، `Failure` من نوع sealed مع try/catch، و`BASE_URL` واحد) — الأدوات المتقدّمة مؤجّلة، شوف [../../docs/ROADMAP.md](../../docs/ROADMAP.md). عقد الـ backend الموضّح تحت لم يتغيّر.

---

## Big picture / الصورة الكبيرة

- **Backend**: MVP **feature-complete except M3.5 payments** — [#47](https://github.com/YoussefSalem582/osta_backend/issues/47), [#48](https://github.com/YoussefSalem582/osta_backend/issues/48), [#49](https://github.com/YoussefSalem582/osta_backend/issues/49) are the only open MVP feature epics. Everything else (auth, account, discovery, booking, realtime, vehicles, shop, notifications, admin) is shipped.
- **App**: at **M0**. Foundation done ([#28](https://github.com/YoussefSalem582/Osta-App/issues/28), [#29](https://github.com/YoussefSalem582/Osta-App/issues/29), [#31](https://github.com/YoussefSalem582/Osta-App/issues/31) closed; [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) open). All feature epics open. Only auth login/refresh/social-exchange are actually wired.
- **Consequence**: the app is the critical path. Almost every app epic is `backend:ready` — you can build against a live API today.

> ‏**الـ Backend**: الـ MVP **مكتمل الميزات ما عدا مدفوعات M3.5** — [#47](https://github.com/YoussefSalem582/osta_backend/issues/47) و[#48](https://github.com/YoussefSalem582/osta_backend/issues/48) و[#49](https://github.com/YoussefSalem582/osta_backend/issues/49) هي الـ epics الوحيدة المفتوحة في الـ MVP. كل حاجة تانية (auth، الحساب، الاكتشاف، الحجز، الـ realtime، العربيات، المتجر، الإشعارات، الإدارة) اتسلّمت.
>
> ‏**التطبيق**: عند **M0**. الأساس خلص ([#28](https://github.com/YoussefSalem582/Osta-App/issues/28) و[#29](https://github.com/YoussefSalem582/Osta-App/issues/29) و[#31](https://github.com/YoussefSalem582/Osta-App/issues/31) اتقفلوا؛ [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) مفتوح). كل epics الميزات مفتوحة. المتوصّل فعليًا هو auth (تسجيل الدخول والتجديد وتبادل توكن السوشيال) بس.
>
> ‏**النتيجة**: التطبيق هو المسار الحرج. تقريبًا كل epic في التطبيق عليه `backend:ready` — تقدر تبني على API حيّة النهارده.

---

## Mirror table (app epic ↔ backend epic) / جدول المرآة

The table below pairs each app epic with the backend epic it depends on and both sides' current state.

> ‏الجدول التالي بيقرن كل epic في التطبيق بالـ epic المقابل له في الـ backend، وحالة كل جانب.

| Area | App epic | Backend epic | Backend state | App status |
|---|---|---|---|---|
| Roles & routing | [#32](https://github.com/YoussefSalem582/Osta-App/issues/32) [#33](https://github.com/YoussefSalem582/Osta-App/issues/33) [#34](https://github.com/YoussefSalem582/Osta-App/issues/34) | [#40](https://github.com/YoussefSalem582/osta_backend/issues/40) | ✅ | 📋 open |
| Auth (email+password) | [#35](https://github.com/YoussefSalem582/Osta-App/issues/35) | [#37](https://github.com/YoussefSalem582/osta_backend/issues/37) | ✅ | 🔌 partial (core wired) |
| Social login | [#36](https://github.com/YoussefSalem582/Osta-App/issues/36) | [#38](https://github.com/YoussefSalem582/osta_backend/issues/38) | ✅ | 🔌 exchange wired |
| Splash/onboarding | [#37](https://github.com/YoussefSalem582/Osta-App/issues/37) | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) (`/me`) | ✅ | 📋 open |
| Legal/About | [#38](https://github.com/YoussefSalem582/Osta-App/issues/38) | [#58](https://github.com/YoussefSalem582/osta_backend/issues/58) | ✅ | 📋 open |
| Car onboarding | [#39](https://github.com/YoussefSalem582/Osta-App/issues/39) | [#54](https://github.com/YoussefSalem582/osta_backend/issues/54) | ✅ | 📋 open |
| Account & More | [#40](https://github.com/YoussefSalem582/Osta-App/issues/40) | [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) | ✅ | 📋 open |
| Map/discovery/filters | [#41](https://github.com/YoussefSalem582/Osta-App/issues/41) [#43](https://github.com/YoussefSalem582/Osta-App/issues/43) | [#41](https://github.com/YoussefSalem582/osta_backend/issues/41) | ✅ | 📋 open |
| Center profile | [#42](https://github.com/YoussefSalem582/Osta-App/issues/42) | [#42](https://github.com/YoussefSalem582/osta_backend/issues/42) | ✅ | 📋 open |
| Booking funnel | [#44](https://github.com/YoussefSalem582/Osta-App/issues/44) | [#43](https://github.com/YoussefSalem582/osta_backend/issues/43) [#44](https://github.com/YoussefSalem582/osta_backend/issues/44) | ✅ | 📋 open |
| My bookings + realtime | [#45](https://github.com/YoussefSalem582/Osta-App/issues/45) [#47](https://github.com/YoussefSalem582/Osta-App/issues/47) | [#45](https://github.com/YoussefSalem582/osta_backend/issues/45) [#50](https://github.com/YoussefSalem582/osta_backend/issues/50) [#51](https://github.com/YoussefSalem582/osta_backend/issues/51) | ✅ | 📋 open |
| **Payments** | [#46](https://github.com/YoussefSalem582/Osta-App/issues/46) | [#47](https://github.com/YoussefSalem582/osta_backend/issues/47) [#48](https://github.com/YoussefSalem582/osta_backend/issues/48) [#49](https://github.com/YoussefSalem582/osta_backend/issues/49) | ⛔ **open** | ⛔ blocked |
| Garage + maintenance | [#50](https://github.com/YoussefSalem582/Osta-App/issues/50) | [#54](https://github.com/YoussefSalem582/osta_backend/issues/54) [#55](https://github.com/YoussefSalem582/osta_backend/issues/55) | ✅ | 📋 open |
| Home dashboard | [#51](https://github.com/YoussefSalem582/Osta-App/issues/51) | [#41](https://github.com/YoussefSalem582/osta_backend/issues/41) [#45](https://github.com/YoussefSalem582/osta_backend/issues/45) [#52](https://github.com/YoussefSalem582/osta_backend/issues/52) | ✅ | 📋 open |
| Notifications | [#52](https://github.com/YoussefSalem582/Osta-App/issues/52) | [#59](https://github.com/YoussefSalem582/osta_backend/issues/59) | ✅ | 📋 open |
| Business onboarding | [#53](https://github.com/YoussefSalem582/Osta-App/issues/53) | [#56](https://github.com/YoussefSalem582/osta_backend/issues/56) [#40](https://github.com/YoussefSalem582/osta_backend/issues/40) | ✅ | 📋 open |
| Business dashboard | [#54](https://github.com/YoussefSalem582/Osta-App/issues/54) | [#51](https://github.com/YoussefSalem582/osta_backend/issues/51) [#50](https://github.com/YoussefSalem582/osta_backend/issues/50) | ✅ | 📋 open |
| Business bookings + team | [#55](https://github.com/YoussefSalem582/Osta-App/issues/55) [#62](https://github.com/YoussefSalem582/Osta-App/issues/62) | [#46](https://github.com/YoussefSalem582/osta_backend/issues/46) [#64](https://github.com/YoussefSalem582/osta_backend/issues/64) | ✅ | 📋 open |
| Business catalog | [#56](https://github.com/YoussefSalem582/Osta-App/issues/56) | [#57](https://github.com/YoussefSalem582/osta_backend/issues/57) | ✅ | 📋 open |
| Shop (two-sided) | [#48](https://github.com/YoussefSalem582/Osta-App/issues/48) [#49](https://github.com/YoussefSalem582/Osta-App/issues/49) [#57](https://github.com/YoussefSalem582/Osta-App/issues/57) | [#52](https://github.com/YoussefSalem582/osta_backend/issues/52) [#53](https://github.com/YoussefSalem582/osta_backend/issues/53) | ✅ | 📋 open |
| **Business More extras** | [#58](https://github.com/YoussefSalem582/Osta-App/issues/58) | (backend M6 analytics/capacity/review-reply) | ⛔ | ⛔ blocked (Phase 2) |
| **Provider backlog** | [#59](https://github.com/YoussefSalem582/Osta-App/issues/59) [#60](https://github.com/YoussefSalem582/Osta-App/issues/60) | [#62](https://github.com/YoussefSalem582/osta_backend/issues/62) | ⛔ | ⛔ blocked (Phase 2) |

Legend: ✅ shipped · ⛔ open/blocked · 📋 app epic open, backend ready · 🔌 partially wired.

> ‏المفتاح: ✅ اتسلّم · ⛔ مفتوح/متوقّف · 📋 epic التطبيق مفتوح والـ backend جاهز · 🔌 متوصّل جزئيًا.

---

## What's blocked and why / إيه المتوقّف وليه

- **Payments ([app #46](https://github.com/YoussefSalem582/Osta-App/issues/46))** — needs backend [#47](https://github.com/YoussefSalem582/osta_backend/issues/47)/[#48](https://github.com/YoussefSalem582/osta_backend/issues/48)/[#49](https://github.com/YoussefSalem582/osta_backend/issues/49) (intent, webhook, invoices). The rest of booking works with **cash (pay-at-center)** in the meantime.
- **Business More extras ([app #58](https://github.com/YoussefSalem582/Osta-App/issues/58))** — analytics/capacity/review-reply are Phase-2 backend work.
- **Solo-mechanic / tow-truck ([app #59](https://github.com/YoussefSalem582/Osta-App/issues/59), [#60](https://github.com/YoussefSalem582/Osta-App/issues/60))** — Phase-2 provider roles ([backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62)); ship as "coming soon".

> ‏**المدفوعات ([app #46](https://github.com/YoussefSalem582/Osta-App/issues/46))** — محتاجة الـ backend [#47](https://github.com/YoussefSalem582/osta_backend/issues/47)/[#48](https://github.com/YoussefSalem582/osta_backend/issues/48)/[#49](https://github.com/YoussefSalem582/osta_backend/issues/49) (نيّة الدفع، الـ webhook، الفواتير). باقي مسار الحجز شغّال بالـ **كاش (الدفع في المركز)** لحد ما تخلص.
>
> ‏**إضافات Business More ([app #58](https://github.com/YoussefSalem582/Osta-App/issues/58))** — التحليلات والسعة والرد على المراجعات دي شغل backend في المرحلة الثانية.
>
> ‏**الميكانيكي الفردي / ونش السحب ([app #59](https://github.com/YoussefSalem582/Osta-App/issues/59) و[#60](https://github.com/YoussefSalem582/Osta-App/issues/60))** — أدوار مزوّدين في المرحلة الثانية ([backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62))؛ تتسلّم كـ "قريبًا".

---

## Label semantics / دلالة الـ Labels

An Arabic gloss of each label follows the table caption; the label names themselves stay in English.

> ‏شرح مختصر لكل label؛ أسامي الـ labels نفسها بتفضل بالإنجليزي.

| Label | Meaning |
|---|---|
| `backend:ready` | Backend route exists on `main` — safe to integrate |
| `backend:blocked` | Backend epic not merged — app work is scaffold/UI-only |
| `phase:mvp` / `phase:2` | Ship-now vs post-MVP |
| `app:b2c` / `app:b2b` / `app:shared` (aka `surface:`) | Which shell(s) |
| `priority:p0…p2` · `owner:*` | Sequencing + assignment |

---

## Suggested integration order / ترتيب الدمج المقترح

M1 first (auth + roles unblock everything user-facing): [#32](https://github.com/YoussefSalem582/Osta-App/issues/32)–[#36](https://github.com/YoussefSalem582/Osta-App/issues/36), [#39](https://github.com/YoussefSalem582/Osta-App/issues/39), [#53](https://github.com/YoussefSalem582/Osta-App/issues/53) → M2 discovery → M3 booking (cash) → M4 realtime/dashboard → M5 garage/catalog → Home/Shop/Notifications → payments when backend M3.5 lands. Rationale + owner sequencing: [../reference/DELIVERY_PLAN.md](../reference/DELIVERY_PLAN.md).

> ‏ابدأ بـ M1 (auth + الأدوار بيفكّوا كل حاجة بتواجه المستخدم): [#32](https://github.com/YoussefSalem582/Osta-App/issues/32)–[#36](https://github.com/YoussefSalem582/Osta-App/issues/36) و[#39](https://github.com/YoussefSalem582/Osta-App/issues/39) و[#53](https://github.com/YoussefSalem582/Osta-App/issues/53) → M2 الاكتشاف → M3 الحجز (كاش) → M4 الـ realtime/لوحة التحكم → M5 الجراج/الكتالوج → الرئيسية/المتجر/الإشعارات → المدفوعات لمّا يوصل M3.5 في الـ backend. السبب وترتيب المسؤولين: [../reference/DELIVERY_PLAN.md](../reference/DELIVERY_PLAN.md).

---

## Related / روابط ذات صلة

- [09_api_endpoints.md](09_api_endpoints.md) · [../reference/DELIVERY_PLAN.md](../reference/DELIVERY_PLAN.md) · trackers: app [#61](https://github.com/YoussefSalem582/Osta-App/issues/61) · backend [#63](https://github.com/YoussefSalem582/osta_backend/issues/63)
