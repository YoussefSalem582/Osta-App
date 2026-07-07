# 📦 Delivery Plan — Milestones, Owners & Cross-Repo Map / خطة التسليم — المراحل والمالكون وخريطة المستودعات

> [INDEX](../INDEX.md) > Delivery Plan
>
> The issue-tracker mirror. Sourced from [Osta-App issues](https://github.com/YoussefSalem582/Osta-App/issues) (app tracker [#61](https://github.com/YoussefSalem582/Osta-App/issues/61)) and [osta_backend issues](https://github.com/YoussefSalem582/osta_backend/issues) (backend tracker [#63](https://github.com/YoussefSalem582/osta_backend/issues/63)).

This document mirrors the two issue trackers into one plan: what ships in each milestone, who owns it, and how each app epic maps to its backend counterpart. The backend contract is unchanged; only the app's tooling was simplified — see [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md) for the deferred-tooling plan.

> ‏هذا المستند يجمع متتبِّعَي المهام في خطة واحدة: ما الذي يُسلَّم في كل مرحلة، ومَن يملكه، وكيف تنعكس كل ملحمة (epic) في التطبيق على نظيرتها في الـ backend. عقد الـ backend لم يتغيّر؛ ما جرى تبسيطه هو أدوات التطبيق فقط — راجع [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md) لخطة إعادة إدخال الأدوات المؤجَّلة.

---

## 1. Snapshot (2026-07-02) / لقطة الحالة

- **Backend**: MVP feature-complete **except M3.5 payments** — [#47](https://github.com/YoussefSalem582/osta_backend/issues/47) (Paymob intent), [#48](https://github.com/YoussefSalem582/osta_backend/issues/48) (webhook), [#49](https://github.com/YoussefSalem582/osta_backend/issues/49) (invoices) still open. Everything else shipped.
- **App**: **M0 foundation** done — [#28](https://github.com/YoussefSalem582/Osta-App/issues/28) scaffolding+CI, [#29](https://github.com/YoussefSalem582/Osta-App/issues/29) design system, [#31](https://github.com/YoussefSalem582/Osta-App/issues/31) networking (all closed); [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) localization/RTL open. **All feature epics open.** Only `/splash` + `/role` screens exist.
- **Bottleneck**: the app. Most app epics are `backend:ready` — build against a live API now.

> ‏**الـ Backend**: الميزات الأساسية (MVP) مكتملة **باستثناء مدفوعات M3.5** — [#47](https://github.com/YoussefSalem582/osta_backend/issues/47) و[#48](https://github.com/YoussefSalem582/osta_backend/issues/48) و[#49](https://github.com/YoussefSalem582/osta_backend/issues/49) ما زالت مفتوحة، وكل ما عداها تم تسليمه. **التطبيق**: أساس M0 مكتمل — السقالات والـ CI ونظام التصميم وطبقة الشبكة مُغلقة، والتوطين/RTL لا يزال مفتوحًا، وكل ملاحم الميزات مفتوحة، ولا توجد سوى شاشتَي `/splash` و`/role`. **عنق الزجاجة** هو التطبيق: معظم ملاحمه موسومة `backend:ready`، أي يمكن بناؤها الآن مقابل API حيّ.

M0 scaffolding & CI ([#28](https://github.com/YoussefSalem582/Osta-App/issues/28)) shipped in a deliberately lean form: plain-Dart models with `Equatable`, manual `get_it` registration, a single `BASE_URL` dart-define, and one CI job ("format · analyze · test"). Advanced tooling (`freezed`, `injectable`, `fpdart`, build flavors, platform-build CI jobs) was **deferred, not rejected** — the phased plan lives in [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

> ‏سُلِّمت سقالات M0 والـ CI ([#28](https://github.com/YoussefSalem582/Osta-App/issues/28)) في صورة رشيقة عن قصد: نماذج Dart عادية تعتمد `Equatable`، وتسجيل يدوي في `get_it`، ومتغيّر `BASE_URL` واحد عبر dart-define، ومهمة CI واحدة ("format · analyze · test"). الأدوات المتقدّمة (`freezed`، `injectable`، `fpdart`، نكهات البناء، ومهام بناء المنصّات في الـ CI) **مؤجَّلة لا مرفوضة** — والخطة المرحلية موجودة في [`../../docs/ROADMAP.md`](../../docs/ROADMAP.md).

---

## 2. App milestones / مراحل التطبيق

Below: each app epic with its milestone, owner, and backend-readiness. Only `/splash` and `/role` are implemented today; the rest are stubs specified by their linked epics.

> ‏أدناه: كل ملحمة في التطبيق مع مرحلتها ومالكها وجاهزية الـ backend لها. المنفَّذ فعليًا اليوم هو `/splash` و`/role` فقط، وبقيّة البنود سقالات تحدِّدها الملاحم المرتبطة بها.

| M | Epic | Owner | Backend |
|---|---|---|---|
| M0 | [#28](https://github.com/YoussefSalem582/Osta-App/issues/28) Scaffolding & CI ✅ | youssef | ready |
| M0 | [#29](https://github.com/YoussefSalem582/Osta-App/issues/29) Design system ✅ | haidy | ready |
| M0 | [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) Localization & RTL 🔄 | haidy | ready |
| M0 | [#31](https://github.com/YoussefSalem582/Osta-App/issues/31) API client ✅ | youssef | ready |
| M1 | [#32](https://github.com/YoussefSalem582/Osta-App/issues/32) First-run role split (canonical) | youssef | ready |
| M1 | [#33](https://github.com/YoussefSalem582/Osta-App/issues/33) Role chooser | haidy | ready |
| M1 | [#34](https://github.com/YoussefSalem582/Osta-App/issues/34) Role-aware routing & shells | youssef | ready |
| M1 | [#35](https://github.com/YoussefSalem582/Osta-App/issues/35) Auth email+password | youssef | ready |
| M1 | [#36](https://github.com/YoussefSalem582/Osta-App/issues/36) Social login | youssef | ready |
| M1 | [#37](https://github.com/YoussefSalem582/Osta-App/issues/37) Splash/language/onboarding | adel | ready |
| M1 | [#38](https://github.com/YoussefSalem582/Osta-App/issues/38) Terms/Privacy/About | roaa | ready |
| M1 | [#39](https://github.com/YoussefSalem582/Osta-App/issues/39) Required car onboarding | roaa | ready |
| M1 | [#40](https://github.com/YoussefSalem582/Osta-App/issues/40) Account & More hub | roaa | ready |
| M1 | [#53](https://github.com/YoussefSalem582/Osta-App/issues/53) Business onboarding | haidy | ready |
| M2 | [#41](https://github.com/YoussefSalem582/Osta-App/issues/41) Map screen | adel | ready |
| M2 | [#42](https://github.com/YoussefSalem582/Osta-App/issues/42) Center profile | adel | ready |
| M2 | [#43](https://github.com/YoussefSalem582/Osta-App/issues/43) Filters & search | adel | ready |
| M3 | [#44](https://github.com/YoussefSalem582/Osta-App/issues/44) Booking funnel (cash) | roaa | ready |
| M3 | [#45](https://github.com/YoussefSalem582/Osta-App/issues/45) My bookings & detail | roaa | ready |
| M3 | [#55](https://github.com/YoussefSalem582/Osta-App/issues/55) Business bookings mgmt | haneen | ready |
| M3 | [#62](https://github.com/YoussefSalem582/Osta-App/issues/62) Team & mechanics | haneen | ready |
| M3.5 | [#46](https://github.com/YoussefSalem582/Osta-App/issues/46) Payments (Paymob) | roaa | **blocked** |
| M4 | [#47](https://github.com/YoussefSalem582/Osta-App/issues/47) Realtime booking status | roaa | ready |
| M4 | [#54](https://github.com/YoussefSalem582/Osta-App/issues/54) Business dashboard | haneen | ready |
| M5 | [#50](https://github.com/YoussefSalem582/Osta-App/issues/50) My Garage | roaa | ready |
| M5 | [#56](https://github.com/YoussefSalem582/Osta-App/issues/56) Business catalog & pricing | haidy | ready |
| M6 | [#58](https://github.com/YoussefSalem582/Osta-App/issues/58) Business More extras | haneen | **blocked** (P2) |
| M7 | [#52](https://github.com/YoussefSalem582/Osta-App/issues/52) Notifications + FCM | youssef | ready |
| Home | [#51](https://github.com/YoussefSalem582/Osta-App/issues/51) Home dashboard | adel | ready |
| Shop | [#48](https://github.com/YoussefSalem582/Osta-App/issues/48) Shop browse/detail | adel | ready |
| Shop | [#49](https://github.com/YoussefSalem582/Osta-App/issues/49) Customer public profile (P2) | adel | ready |
| Shop | [#57](https://github.com/YoussefSalem582/Osta-App/issues/57) Business shop mgmt | haidy | ready |
| Backlog | [#59](https://github.com/YoussefSalem582/Osta-App/issues/59) Solo-mechanic (P2) | youssef | **blocked** |
| Backlog | [#60](https://github.com/YoussefSalem582/Osta-App/issues/60) Tow-truck (P2) | youssef | **blocked** |

---

## 3. Backend milestones / مراحل الـ Backend

The backend is feature-complete apart from M3.5 payments. This table is unchanged — the backend did not change.

> ‏الـ backend مكتمل الميزات باستثناء مدفوعات M3.5. هذا الجدول لم يتغيّر — الـ backend لم يطرأ عليه تعديل.

| M | Epics | State |
|---|---|---|
| Sprint 0 | [#35](https://github.com/YoussefSalem582/osta_backend/issues/35) ✅, [#36](https://github.com/YoussefSalem582/osta_backend/issues/36) ✅ | done |
| M1 Auth & Account | [#37](https://github.com/YoussefSalem582/osta_backend/issues/37) [#38](https://github.com/YoussefSalem582/osta_backend/issues/38) [#39](https://github.com/YoussefSalem582/osta_backend/issues/39) [#40](https://github.com/YoussefSalem582/osta_backend/issues/40) [#58](https://github.com/YoussefSalem582/osta_backend/issues/58) | ✅ |
| M2 Discovery | [#41](https://github.com/YoussefSalem582/osta_backend/issues/41) [#42](https://github.com/YoussefSalem582/osta_backend/issues/42) | ✅ |
| M3 Booking | [#43](https://github.com/YoussefSalem582/osta_backend/issues/43) [#44](https://github.com/YoussefSalem582/osta_backend/issues/44) [#45](https://github.com/YoussefSalem582/osta_backend/issues/45) [#46](https://github.com/YoussefSalem582/osta_backend/issues/46) [#64](https://github.com/YoussefSalem582/osta_backend/issues/64) | ✅ |
| M3.5 Payments | [#47](https://github.com/YoussefSalem582/osta_backend/issues/47) [#48](https://github.com/YoussefSalem582/osta_backend/issues/48) [#49](https://github.com/YoussefSalem582/osta_backend/issues/49) | 🔄 **open** |
| M4 Realtime | [#50](https://github.com/YoussefSalem582/osta_backend/issues/50) [#51](https://github.com/YoussefSalem582/osta_backend/issues/51) | ✅ |
| M5 Vehicles/B2B | [#54](https://github.com/YoussefSalem582/osta_backend/issues/54) [#55](https://github.com/YoussefSalem582/osta_backend/issues/55) [#56](https://github.com/YoussefSalem582/osta_backend/issues/56) [#57](https://github.com/YoussefSalem582/osta_backend/issues/57) | ✅ |
| Shop | [#52](https://github.com/YoussefSalem582/osta_backend/issues/52) [#53](https://github.com/YoussefSalem582/osta_backend/issues/53) | ✅ |
| M6 Admin | [#61](https://github.com/YoussefSalem582/osta_backend/issues/61) | ✅ |
| M7 Notif/Harden | [#59](https://github.com/YoussefSalem582/osta_backend/issues/59) [#60](https://github.com/YoussefSalem582/osta_backend/issues/60) | ✅ |
| Phase 2 | [#62](https://github.com/YoussefSalem582/osta_backend/issues/62) | open |

---

## 4. Cross-repo mirror / خريطة المستودعات المتقابلة

Each app epic below is paired with the backend epic it consumes. Full per-endpoint states live in the connectivity guide.

> ‏كل ملحمة تطبيق أدناه مقترنة بملحمة الـ backend التي تستهلكها. حالات كل نقطة نهاية تفصيليًا موجودة في دليل الربط.

Full table with per-endpoint states: [../guides/11_backend_feature_connectivity.md](../guides/11_backend_feature_connectivity.md). Summary: Auth app [#35](https://github.com/YoussefSalem582/Osta-App/issues/35)/[#36](https://github.com/YoussefSalem582/Osta-App/issues/36) ↔ BE [#37](https://github.com/YoussefSalem582/osta_backend/issues/37)/[#38](https://github.com/YoussefSalem582/osta_backend/issues/38) · Discovery app #41–#43 ↔ BE #41/#42 · Booking app #44/#45/#55 ↔ BE #43–#46 · Mechanics app [#62](https://github.com/YoussefSalem582/Osta-App/issues/62) ↔ BE [#64](https://github.com/YoussefSalem582/osta_backend/issues/64) · Payments app [#46](https://github.com/YoussefSalem582/Osta-App/issues/46) ↔ BE #47–#49 · Realtime app #47/#54 ↔ BE #50/#51 · Shop app #48/#49/#57 ↔ BE #52/#53 · Vehicles app [#50](https://github.com/YoussefSalem582/Osta-App/issues/50) ↔ BE #54/#55 · Business onboarding app [#53](https://github.com/YoussefSalem582/Osta-App/issues/53) ↔ BE [#56](https://github.com/YoussefSalem582/osta_backend/issues/56) · Notifications app [#52](https://github.com/YoussefSalem582/Osta-App/issues/52) ↔ BE [#59](https://github.com/YoussefSalem582/osta_backend/issues/59) · Legal app [#38](https://github.com/YoussefSalem582/Osta-App/issues/38) ↔ BE [#58](https://github.com/YoussefSalem582/osta_backend/issues/58).

---

## 5. Owner map / خريطة المالكين

Each row lists the app issues owned by one teammate.

> ‏كل صف يسرد مهام التطبيق التي يملكها أحد أعضاء الفريق.

| Owner | App issues |
|---|---|
| **youssef** | [#28](https://github.com/YoussefSalem582/Osta-App/issues/28) [#31](https://github.com/YoussefSalem582/Osta-App/issues/31) [#32](https://github.com/YoussefSalem582/Osta-App/issues/32) [#34](https://github.com/YoussefSalem582/Osta-App/issues/34) [#35](https://github.com/YoussefSalem582/Osta-App/issues/35) [#36](https://github.com/YoussefSalem582/Osta-App/issues/36) [#52](https://github.com/YoussefSalem582/Osta-App/issues/52) [#59](https://github.com/YoussefSalem582/Osta-App/issues/59) [#60](https://github.com/YoussefSalem582/Osta-App/issues/60) [#61](https://github.com/YoussefSalem582/Osta-App/issues/61) |
| **haidy** | [#29](https://github.com/YoussefSalem582/Osta-App/issues/29) [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) [#33](https://github.com/YoussefSalem582/Osta-App/issues/33) [#53](https://github.com/YoussefSalem582/Osta-App/issues/53) [#56](https://github.com/YoussefSalem582/Osta-App/issues/56) [#57](https://github.com/YoussefSalem582/Osta-App/issues/57) |
| **haneen** | [#54](https://github.com/YoussefSalem582/Osta-App/issues/54) [#55](https://github.com/YoussefSalem582/Osta-App/issues/55) [#58](https://github.com/YoussefSalem582/Osta-App/issues/58) [#62](https://github.com/YoussefSalem582/Osta-App/issues/62) |
| **adel** | [#37](https://github.com/YoussefSalem582/Osta-App/issues/37) [#41](https://github.com/YoussefSalem582/Osta-App/issues/41) [#42](https://github.com/YoussefSalem582/Osta-App/issues/42) [#43](https://github.com/YoussefSalem582/Osta-App/issues/43) [#48](https://github.com/YoussefSalem582/Osta-App/issues/48) [#49](https://github.com/YoussefSalem582/Osta-App/issues/49) [#51](https://github.com/YoussefSalem582/Osta-App/issues/51) |
| **roaa** | [#38](https://github.com/YoussefSalem582/Osta-App/issues/38) [#39](https://github.com/YoussefSalem582/Osta-App/issues/39) [#40](https://github.com/YoussefSalem582/Osta-App/issues/40) [#44](https://github.com/YoussefSalem582/Osta-App/issues/44) [#45](https://github.com/YoussefSalem582/Osta-App/issues/45) [#46](https://github.com/YoussefSalem582/Osta-App/issues/46) [#47](https://github.com/YoussefSalem582/Osta-App/issues/47) [#50](https://github.com/YoussefSalem582/Osta-App/issues/50) |

---

## 6. Label legend / دليل الوسوم

Label names stay in English (they are used verbatim on GitHub); the meanings are described below.

> ‏أسماء الوسوم تبقى بالإنجليزية (تُستخدم حرفيًا على GitHub)، والمعاني موضَّحة أدناه.

| Label | Meaning |
|---|---|
| `type:epic` | Every tracked issue is an epic |
| `app:b2c` / `b2b` / `shared` (`surface:` on backend) | Which shell / side |
| `backend:ready` / `backend:blocked` | Backend route merged vs not |
| `phase:mvp` / `phase:2` | Ship-now vs post-MVP |
| `priority:p0…p2` | Sequencing |
| `owner:*` | Assignee |
| `status:next/planned/shipped` | Workflow state |

---

## 7. Suggested build order (app) / ترتيب البناء المقترح للتطبيق

Auth and roles gate the shells, so they come first; cash booking makes the core loop demoable without waiting on Paymob; realtime and the dashboard layer onto shipped booking.

> ‏المصادقة والأدوار تتحكّم في القشرات (shells) فتأتي أولًا؛ والحجز النقدي يجعل الحلقة الأساسية قابلة للعرض دون انتظار Paymob؛ ثم يُبنى الوقت الحقيقي ولوحة التحكّم فوق الحجز المُسلَّم.

1. **Finish M0**: localization/RTL runtime switch ([#30](https://github.com/YoussefSalem582/Osta-App/issues/30)).
2. **M1 first-run + auth** (unblocks every user-facing flow): [#32](https://github.com/YoussefSalem582/Osta-App/issues/32) → [#33](https://github.com/YoussefSalem582/Osta-App/issues/33) → [#34](https://github.com/YoussefSalem582/Osta-App/issues/34) → [#35](https://github.com/YoussefSalem582/Osta-App/issues/35)/[#36](https://github.com/YoussefSalem582/Osta-App/issues/36) → [#37](https://github.com/YoussefSalem582/Osta-App/issues/37), [#38](https://github.com/YoussefSalem582/Osta-App/issues/38), [#39](https://github.com/YoussefSalem582/Osta-App/issues/39), [#40](https://github.com/YoussefSalem582/Osta-App/issues/40), [#53](https://github.com/YoussefSalem582/Osta-App/issues/53).
3. **M2 discovery** ([#41](https://github.com/YoussefSalem582/Osta-App/issues/41)–[#43](https://github.com/YoussefSalem582/Osta-App/issues/43)) → **M3 booking (cash)** ([#44](https://github.com/YoussefSalem582/Osta-App/issues/44), [#45](https://github.com/YoussefSalem582/Osta-App/issues/45), [#55](https://github.com/YoussefSalem582/Osta-App/issues/55), [#62](https://github.com/YoussefSalem582/Osta-App/issues/62)).
4. **M4 realtime + dashboard** ([#47](https://github.com/YoussefSalem582/Osta-App/issues/47), [#54](https://github.com/YoussefSalem582/Osta-App/issues/54)) → **M5 garage + catalog** ([#50](https://github.com/YoussefSalem582/Osta-App/issues/50), [#56](https://github.com/YoussefSalem582/Osta-App/issues/56)) → **Home/Shop/Notifications** ([#51](https://github.com/YoussefSalem582/Osta-App/issues/51), [#48](https://github.com/YoussefSalem582/Osta-App/issues/48), [#57](https://github.com/YoussefSalem582/Osta-App/issues/57), [#52](https://github.com/YoussefSalem582/Osta-App/issues/52)).
5. **Payments** ([#46](https://github.com/YoussefSalem582/Osta-App/issues/46)) when backend M3.5 ships; **Phase 2** ([#49](https://github.com/YoussefSalem582/Osta-App/issues/49), [#58](https://github.com/YoussefSalem582/Osta-App/issues/58), [#59](https://github.com/YoussefSalem582/Osta-App/issues/59), [#60](https://github.com/YoussefSalem582/Osta-App/issues/60)) last.

Rationale: auth/roles gate the shells; cash booking makes the core loop demoable without waiting on Paymob; realtime and dashboard layer onto shipped booking.

> ‏المبرِّر: المصادقة والأدوار تحكم القشرات؛ والحجز النقدي يجعل الحلقة الأساسية قابلة للعرض دون انتظار Paymob؛ والوقت الحقيقي ولوحة التحكّم يُبنيان فوق الحجز المُسلَّم.

---

## 8. Trackers / المتتبِّعات

- App master checklist: [#61](https://github.com/YoussefSalem582/Osta-App/issues/61)
- Backend master checklist: [#63](https://github.com/YoussefSalem582/osta_backend/issues/63)
