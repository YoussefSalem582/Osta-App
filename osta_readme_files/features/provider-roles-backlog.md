> [INDEX](../INDEX.md) > [Features](README.md) > Provider Roles Backlog (Phase 2)

# 🛺 Provider Roles Backlog — Solo Mechanic & Tow Truck / أدوار مزوّدي الخدمة (المرحلة 2)

Two future PROVIDER roles that reuse the same provider shell as the business flow: an independent **solo mechanic** (no fixed premises) and a **tow-truck driver** (roadside jobs with live GPS tracking). Both are **Phase 2** — architecture-ready but not built for MVP. In the MVP they appear only as disabled "coming soon" cards in the role chooser.

> ‏دوران مستقبليان لمزوّدي الخدمة يعيدان استخدام شِل المزوّد نفسه المستخدَم في تدفّق النشاط: **ميكانيكي مستقل** (بلا مقرّ ثابت) و**سائق ونش** (مهام على الطريق مع تتبّع GPS حيّ). كلاهما ضمن **المرحلة الثانية** — جاهزان معماريًّا لكن غير مبنيّين في نسخة MVP. في MVP يظهران فقط كبطاقتَي "قريبًا" معطّلتَين في شاشة اختيار الدور.

---

## Status & Issues / الحالة والقضايا

| Issue | Title | State | Milestone | Priority | Owner | Backend |
|---|---|---|---|---|---|---|
| [app #59](https://github.com/YoussefSalem582/Osta-App/issues/59) | Solo-mechanic flow (provider shell) | OPEN | Backlog / Phase 2 | p2 | youssef | **blocked** — role + APIs in [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) |
| [app #60](https://github.com/YoussefSalem582/Osta-App/issues/60) | Tow-truck driver flow (provider shell + live tracking) | OPEN | Backlog / Phase 2 | p2 | youssef | **blocked** — role + tracking in [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) |

Both are gated on the Phase-2 backend umbrella ([backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62)): activating the `solo_mechanic` / `tow_driver` spatie roles, provider onboarding fields, and (for tow) the `tracking.{jobId}` Reverb channel + tow-job endpoints. **Distinct from the center mechanic roster** ([app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) / [backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64)) — those roster entries have no login; these roles authenticate.

> ‏كلا الدورَين موقوفان على مظلّة الباك-إند للمرحلة الثانية ([backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62)): تفعيل دورَي `solo_mechanic` / `tow_driver` في spatie، وحقول تسجيل المزوّد، و(للونش) قناة `tracking.{jobId}` على Reverb مع نقاط نهاية مهام الونش. **وهذا مختلف عن قائمة ميكانيكيّي المركز** ([app #62](https://github.com/YoussefSalem582/Osta-App/issues/62) / [backend #64](https://github.com/YoussefSalem582/osta_backend/issues/64)) — فتلك القائمة بلا تسجيل دخول، أمّا هذه الأدوار فتُصادِق على الهوية.

---

## Screens / Mockups / الشاشات والتصاميم

Design mockups for the two Phase-2 roles.

> ‏تصاميم الشاشات للدورَين في المرحلة الثانية.

**Independent mechanic**

![Independent mechanic](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/33-independent-mechanic.png)

**Field arrival & on-site tracking (tow)**

![Field arrival and on-site tracking](https://raw.githubusercontent.com/YoussefSalem582/Osta-App/design-assets/mockups/34-field-arrival-and-on-site-tracking.png)

---

## Planned architecture / المعمارية المخطّطة

The key design bet ([ADR 002](../decisions/002-single-app-multi-role-shells.md)): the **provider shell absorbs these roles**. The business dashboard/bookings shell ([business-dashboard.md](business-dashboard.md)) is built generically so a solo mechanic gets `Dashboard / Jobs / Profile` tabs and a tow driver gets a job flow with live location — no new shell.

> ‏الرهان التصميمي الأساسي ([ADR 002](../decisions/002-single-app-multi-role-shells.md)): **شِل المزوّد يستوعب هذه الأدوار**. شِل لوحة تحكّم/حجوزات النشاط ([business-dashboard.md](business-dashboard.md)) مبنيّ بشكل عام، فيحصل الميكانيكي المستقل على تبويبات `Dashboard / Jobs / Profile` ويحصل سائق الونش على تدفّق مهمّة بموقع حيّ — بلا شِل جديد.

**MVP scope (now):** the role chooser ([role-selection-and-routing.md](role-selection-and-routing.md)) renders both as **disabled cards** ("coming soon"); selecting them is a no-op. Nothing else ships.

> ‏**نطاق MVP (الآن):** شاشة اختيار الدور ([role-selection-and-routing.md](role-selection-and-routing.md)) تعرض كليهما كـ**بطاقات معطّلة** ("قريبًا")، واختيارهما لا يفعل شيئًا. لا شيء آخر يُشحَن.

**Phase 2 (later):**

> ‏**المرحلة الثانية (لاحقًا):**

- **Solo mechanic**: mechanic-specific onboarding — identity, skills/experience, and a mobile service area drawn on the map (PostGIS geometry). Reuses polymorphic `Product.owner = User` and `Review.reviewable` so a solo mechanic can also have a shop and reviews.
- **Tow truck**: driver accepts a roadside job, streams location over Reverb (`DriverLocationUpdated` on `tracking.{jobId}`), and the customer watches the truck approach with a live ETA; pay-at-scene + review.

> ‏- **الميكانيكي المستقل**: تسجيل خاص بالميكانيكي — الهوية والمهارات/الخبرة ونطاق خدمة متنقّل يُرسَم على الخريطة (هندسة PostGIS). يعيد استخدام `Product.owner = User` و`Review.reviewable` متعدّدَي الأشكال، فيمكن للميكانيكي المستقل أن يمتلك متجرًا ومراجعات أيضًا.
> ‏- **الونش**: يقبل السائق مهمّة على الطريق، ويبثّ موقعه عبر Reverb (`DriverLocationUpdated` على `tracking.{jobId}`)، ويتابع العميل اقتراب الونش مع وقت وصول حيّ؛ الدفع في الموقع مع مراجعة.

---

## API endpoints / نقاط النهاية (Phase 2, flagged — not final)

The endpoints below are illustrative for the Phase-2 roles; all are currently blocked on the backend.

> ‏نقاط النهاية التالية توضيحية لأدوار المرحلة الثانية، وجميعها موقوفة حاليًا على الباك-إند.

| Method | Path / Channel | Purpose | Source | App status |
|---|---|---|---|---|
| POST | `/api/v1/provider/capabilities` | Declare provider role/skills | [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) | Blocked |
| POST | `/api/v1/tow-jobs/{job}/accept` | Driver accepts a job | [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) | Blocked |
| PATCH | `/api/v1/tow-jobs/{job}/status` | en-route / arrived / towing / completed | [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) | Blocked |
| POST | `/api/v1/tow-jobs/{job}/location` | Push a PostGIS point | [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) | Blocked |
| GET | `/api/v1/tow-jobs/{job}` | Poll fallback | [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) | Blocked |
| WS | `private-tracking.{jobId}` | `DriverLocationUpdated` stream | [backend #62](https://github.com/YoussefSalem582/osta_backend/issues/62) | Blocked |

Paths are illustrative from the Phase-2 umbrella and may change when the epics are split. See [../guides/09_api_endpoints.md](../guides/09_api_endpoints.md) § Phase 2.

> ‏المسارات توضيحية من مظلّة المرحلة الثانية وقد تتغيّر عند تقسيم الملاحم. راجع [../guides/09_api_endpoints.md](../guides/09_api_endpoints.md) § Phase 2.

---

## Packages & shared widgets / الحزم والودجات

- **Phase 2**: `google_maps_flutter`, `geolocator` (location stream), `pusher_channels_flutter` (Reverb) — same realtime stack as [my-bookings.md](my-bookings.md) and [business-dashboard.md](business-dashboard.md).
- **MVP**: only the role-chooser card + `EmptyState`/"coming soon" treatment — no new packages.

> ‏- **المرحلة الثانية**: `google_maps_flutter` و`geolocator` (تدفّق الموقع) و`pusher_channels_flutter` (Reverb) — نفس حزمة الزمن الحقيقي المستخدَمة في [my-bookings.md](my-bookings.md) و[business-dashboard.md](business-dashboard.md).
> ‏- **MVP**: فقط بطاقة اختيار الدور مع معالجة `EmptyState`/"قريبًا" — بلا حزم جديدة.

---

## Testing expectations / توقّعات الاختبار

- **MVP**: widget test — the two role cards render disabled and are not tappable.
- **Phase 2**: location-stream + reconnect tests; golden for the tracking screen (light/dark + RTL).

> ‏- **MVP**: اختبار ودجت — بطاقتا الدورَين تُعرَضان معطّلتَين وغير قابلتَين للنقر.
> ‏- **المرحلة الثانية**: اختبارات تدفّق الموقع وإعادة الاتصال، مع اختبار golden لشاشة التتبّع (فاتح/داكن مع RTL).

---

## Related docs / روابط ذات صلة

- Where the "coming soon" cards live: [role-selection-and-routing.md](role-selection-and-routing.md)
- Shell they will reuse: [business-dashboard.md](business-dashboard.md) · [business-bookings.md](business-bookings.md)
- Why one shell absorbs all roles: [../decisions/002-single-app-multi-role-shells.md](../decisions/002-single-app-multi-role-shells.md)
- Team plan for deferred tooling & phases: [../../docs/ROADMAP.md](../../docs/ROADMAP.md)
- [../reference/DELIVERY_PLAN.md](../reference/DELIVERY_PLAN.md)
