# OSTA_TODO.md — Zero → Production Checklist

> The trackable to-do list for shipping OSTA from an empty repo to production on both stores.
> **How** to build each item (architecture, conventions, offline/talker/skeletonizer specs, git flow) lives in
> [`OSTA_plan.md`](OSTA_plan.md) — read it first. This file is the **what and when**: tick boxes as work merges.
>
> Legend: `[x]` done & merged · `[ ]` to do · ⛔ blocked on backend · 🏷️ release cut (see
> [`OSTA_plan.md` §13](OSTA_plan.md)) · owners come from the epic labels.

---

## The per-epic ritual (repeat for EVERY epic below — not restated each time)

- [ ] Read the epic + its feature doc + [`OSTA_plan.md`](OSTA_plan.md) §2–§13; verify backend readiness
      ([guide 09](osta_readme_files/guides/09_api_endpoints.md))
- [ ] Branch `feat/<issue>-<slug>` off up-to-date `main` — hand-written kebab-case name, never a
      tool-generated one like `claude/...` (rename with `git branch -m` first)
- [ ] Build layer by layer with small conventional commits: `domain → data → presentation → tests → docs`
- [ ] Meet the Definition of Done ([`OSTA_plan.md` §16](OSTA_plan.md)): light+dark · RTL+LTR · responsive ·
      state quartet (skeleton/empty/error/offline) · offline policy · animations · talker · tokens only ·
      goldens · dartdoc
- [ ] Update the mandatory four docs (CHANGELOG, DOCUMENTATION_UPDATE_SUMMARY, CURRENT_STATUS, feature doc)
- [ ] Bilingual PR to `main` linking the epic (`Closes #NN`) → CI green → review → merge

---

## Phase 0 — Repo & foundation (M0 core) ✅ DONE

- [x] Flutter app scaffolding, feature-first layout, strict lints, CI format·analyze·test —
      [#28](https://github.com/YoussefSalem582/Osta-App/issues/28) (PR #63)
- [x] Design system & theming: Material 3 light+dark, `AppColors` ThemeExtension, tokens, Cairo typography,
      persisted `ThemeModeController`, 8 shared `App*` components, formatters —
      [#29](https://github.com/YoussefSalem582/Osta-App/issues/29) (PR #65, #66)
- [x] API client & networking: envelope-aware `ApiClient`, 7 typed `ApiException`s, Sanctum `AuthInterceptor`
      (queued 401 refresh-retry-once), `SocialTokenExchange`, `TokenStorage` —
      [#31](https://github.com/YoussefSalem582/Osta-App/issues/31) (PR #64)
- [x] First-run & role-split canonical model (`activeRole`, shared-download-then-split) —
      [#32](https://github.com/YoussefSalem582/Osta-App/issues/32)
- [x] Plain-Dart refactor: codegen/fpdart/flavors deferred ([`docs/ROADMAP.md`](docs/ROADMAP.md), PR #69)
- [x] Documentation set: `AGENTS.md`, shims, guides, 22 feature docs, 8 ADRs, delivery plan
- [x] Splash + role-selection screens; ~32 foundation tests green
- [x] [`OSTA_plan.md`](OSTA_plan.md) — master AI-agent build instructions (this list's companion)

## Phase 1 — Finish the foundation (M0 wrap) → 🏷️ `v0.1.0`

- [ ] **Localization & RTL** [#30](https://github.com/YoussefSalem582/Osta-App/issues/30) —
      `feat/30-localization-rtl` · owner: haidy
  - [ ] Runtime ar/en switch: instant, persisted, no restart (`LocaleController` Cubit)
  - [ ] `Accept-Language: ar|en` Dio interceptor on every request
  - [ ] Directional-layout sweep (`EdgeInsetsDirectional`, `start`/`end`, mirrored icons)
  - [ ] ARB-coverage test (every key in both files); zero hardcoded strings
- [ ] **Talker logging migration** (`chore/talker-logging`, [`OSTA_plan.md` §9](OSTA_plan.md))
  - [ ] Add `talker_flutter` + `talker_dio_logger` + `talker_bloc_logger`; remove `pretty_dio_logger`
  - [ ] DI singleton, `TalkerBlocObserver`, `TalkerRouteObserver`; Authorization redaction preserved
- [ ] **Offline-first core** (`chore/offline-core`, [`OSTA_plan.md` §7](OSTA_plan.md))
  - [ ] `lib/core/offline/`: sqflite `AppDatabase` + `CacheStore` + `PendingOperations` + `SyncEngine` +
        `ConnectivityService` (`connectivity_plus`)
  - [ ] Shared offline banner widget in `lib/shared/ui/`; DB tests on `sqflite_common_ffi`
- [ ] **Motion + breakpoint tokens** (`chore/motion-breakpoint-tokens`, [`OSTA_plan.md` §8](OSTA_plan.md))
  - [ ] `AppDurations`/`AppCurves`/`AppBreakpoints` in `app_tokens.dart`
  - [ ] `lib/core/router/app_transitions.dart` (shared-axis / fade-through / bottom-sheet) wired into go_router;
        reduced-motion respected
- [ ] **`AppIcons` constants file** (`lib/core/constants/app_icons.dart`) — created here or in the first
      consuming epic
- [ ] 🏷️ Cut release `v0.1.0` (release ritual: [`OSTA_plan.md` §13.2](OSTA_plan.md))

## Phase 2 — M1: First-run, auth & account → 🏷️ `v0.2.0`

- [ ] **Role chooser** [#33](https://github.com/YoussefSalem582/Osta-App/issues/33) — `feat/33-role-chooser` ·
      haidy — 4 cards (customer+business active; mechanic+tow "coming soon"); `activeRole` persisted;
      `account_type` in auth payloads
- [ ] **Role-aware routing & shells** [#34](https://github.com/YoussefSalem582/Osta-App/issues/34) —
      `feat/34-role-shells` · youssef — two `StatefulShellRoute` shells (Consumer: Home·Booking·Map·Shop·More /
      Provider: Dashboard·Catalog·Booking·Shop·More); `me.type` = source of truth; wrong-shell self-heal +
      toast; auth-required redirects
- [ ] **Auth email+password** [#35](https://github.com/YoussefSalem582/Osta-App/issues/35) —
      `feat/35-auth-email-password` · youssef — register (username/+20 phone/avatar/terms gate), login, inline
      422 field errors, forgot/reset E2E, tokens survive relaunch → **becomes the canonical feature reference**
- [ ] **Social login Google & Apple** [#36](https://github.com/YoussefSalem582/Osta-App/issues/36) —
      `feat/36-social-login` · youssef — native OAuth → `SocialTokenExchange`; Apple mandatory on iOS; no
      firebase_auth
- [ ] **Splash, language & onboarding** [#37](https://github.com/YoussefSalem582/Osta-App/issues/37) —
      `feat/37-splash-onboarding` · adel — silent refresh + `/me` routing ≤2s no flicker; language screen first
      run only; 3-slide carousel gated on `onboarding_seen`
- [ ] **Terms, Privacy & About** [#38](https://github.com/YoussefSalem582/Osta-App/issues/38) —
      `feat/38-legal-screens` · roaa — versioned bilingual legal content; register blocked until accepted;
      versions sent with register; **cached for offline (first §7 consumer)**; About w/ support_id explainer
- [ ] **Required car onboarding** [#39](https://github.com/YoussefSalem582/Osta-App/issues/39) —
      `feat/39-car-onboarding` · roaa — zero cars ⇒ Home unreachable; validated brand/model/year/plate/km;
      first car auto-primary; form reusable by #50
- [ ] **Account & More hub** [#40](https://github.com/YoussefSalem582/Osta-App/issues/40) —
      `feat/40-account-more-hub` · roaa — hub in both shells; profile edit + avatar (optimistic); support_id
      chip; language/theme settings; addresses CRUD; soft delete → revoke all → role chooser
- [ ] **Business onboarding** [#53](https://github.com/YoussefSalem582/Osta-App/issues/53) —
      `feat/53-business-onboarding` · haidy — multi-step wizard + progress header; identity/location step (map
      pin, trade name user-facing); catalog step (presets, "Add 12 common", custom) **≥1 service mandatory**;
      live immediately → Dashboard
- [ ] 🏷️ Cut release `v0.2.0`

## Phase 3 — M2: Discovery → 🏷️ `v0.3.0`

- [ ] **Map screen** [#41](https://github.com/YoussefSalem582/Osta-App/issues/41) — `feat/41-map-screen` ·
      adel — full-screen map from FAB; nearest-first markers + clustering; debounced search + category chips;
      place dialog (Book / Details); permission-denied/empty/error states; light+dark map styles
- [ ] **Center profile** [#42](https://github.com/YoussefSalem582/Osta-App/issues/42) —
      `feat/42-center-profile` · adel — header + Services/Reviews/About tabs + Shop strip; per-tab quartet;
      paginated reviews; pinned "Book a service" CTA; Hero from card
- [ ] **Filters & search** [#43](https://github.com/YoussefSalem582/Osta-App/issues/43) —
      `feat/43-filters-search` · adel — sheet: type/price_max/min_rating/open_now (no "verified"); always
      rating-desc; ~300ms debounce; session-scoped filters cleared on logout
- [ ] 🏷️ Cut release `v0.3.0`

## Phase 4 — M3: Booking (cash MVP) → 🏷️ `v0.4.0`

- [ ] **Booking funnel** [#44](https://github.com/YoussefSalem582/Osta-App/issues/44) —
      `feat/44-booking-funnel` · roaa — catalog → slot picker (full slots disabled) → **10-min hold with
      countdown, auto-release** → review + vehicle picker → confirm pay-at-center; **exactly one POST**;
      409 recovers to slot picker; online-only
- [ ] **My bookings & detail** [#45](https://github.com/YoussefSalem582/Osta-App/issues/45) —
      `feat/45-my-bookings` · roaa — Upcoming/Past tabs; status timeline; payment block + center contact;
      cancel/reschedule **optimistic with rollback**
- [ ] **Business bookings management** [#55](https://github.com/YoussefSalem582/Osta-App/issues/55) —
      `feat/55-business-bookings` · haneen — list + calendar; accept / reject **with required reason** /
      status stepper (`confirmed→in_progress→completed` only); assign-mechanic picker; live board
- [ ] **Team & mechanics** [#62](https://github.com/YoussefSalem582/Osta-App/issues/62) —
      `feat/62-team-mechanics` · haneen — roster CRUD (+20 phone, specialty, photo, active, soft delete);
      assign/reassign/unassign on bookings; **roster ≠ login** (distinct from Phase-2 #59)
- [ ] 🏷️ Cut release `v0.4.0`

## Phase 5 — M3.5: Payments ⛔ (backend osta_backend #47–#49 open)

- [ ] ⛔ **Paymob wallets + InstaPay** [#46](https://github.com/YoussefSalem582/Osta-App/issues/46) —
      `feat/46-paymob-payments` · roaa — hosted checkout in WebView (no card data in app); state machine
      `idle→creatingIntent→awaitingGateway→polling→paid/failed`; **idempotency ⇒ never double-charges**;
      invoice PDF; build behind the contract, merge when backend ships

## Phase 6 — M4: Realtime → 🏷️ `v0.5.0`

- [ ] **Realtime booking status** [#47](https://github.com/YoussefSalem582/Osta-App/issues/47) —
      `feat/47-realtime-status` · roaa — **new shared `RealtimeService`** (`lib/core/realtime/`); private
      `bookings.{id}` → animated 5-step timeline ≤~2s; backoff+jitter reconnect; 15s poll fallback; unsubscribe
      on dispose
- [ ] **Business dashboard** [#54](https://github.com/YoussefSalem582/Osta-App/issues/54) —
      `feat/54-business-dashboard` · haneen — KPI counters, revenue snapshot, new-bookings accept/reject
      (optimistic), today timeline; live `centers.{id}`; shell reusable by mechanic/tow
- [ ] 🏷️ Cut release `v0.5.0`

## Phase 7 — M5: Garage & business catalog → 🏷️ `v0.6.0`

- [ ] **My Garage** [#50](https://github.com/YoussefSalem582/Osta-App/issues/50) — `feat/50-my-garage` · roaa —
      vehicles CRUD (single primary, soft delete + undo); rich specs; maintenance log + totals + oil-due
      banner; **PDF export via share sheet**; flagship queued-mutations feature
- [ ] **Business catalog & pricing** [#56](https://github.com/YoussefSalem582/Osta-App/issues/56) —
      `feat/56-business-catalog` · haidy — services CRUD (`price_type` fixed/starting_from/hourly, duration,
      active toggle); promotions CRUD; customer profile shows active+live only
- [ ] 🏷️ Cut release `v0.6.0`

## Phase 8 — Shop, Home & Notifications → 🏷️ `v0.7.0`

- [ ] **Shop browse + product detail** [#48](https://github.com/YoussefSalem582/Osta-App/issues/48) —
      `feat/48-shop-browse` · adel — two-sided grid (search/chips/infinite scroll) → detail → **Enquire**
      (no cart); polymorphic seller catalogs; own-listings CRUD
- [ ] **Business shop management** [#57](https://github.com/YoussefSalem582/Osta-App/issues/57) —
      `feat/57-business-shop` · haidy — products tab; multi-image upload/reorder; deactivate vs delete;
      instant public reflection
- [ ] **Home dashboard (hybrid feed)** [#51](https://github.com/YoussefSalem582/Osta-App/issues/51) —
      `feat/51-home-dashboard` · adel — default post-login landing; **map demoted to FAB**; active-booking
      card + Book CTA + nearby strip + shop highlights + my-cars; per-section quartet; skeletonizer showcase;
      full-feed goldens
- [ ] **Notifications + FCM** [#52](https://github.com/YoussefSalem582/Osta-App/issues/52) —
      `feat/52-notifications-fcm` · youssef — inbox (unread badge, optimistic mark-read); deep links on both
      shells; token register/deregister on login/logout; push in foreground/background/**terminated**;
      permission prompt + off-state
- [ ] **Customer public profile (P2)** [#49](https://github.com/YoussefSalem582/Osta-App/issues/49) —
      `feat/49-customer-profile` · adel — My Shop + Reviews tabs; owner vs visitor mode; deactivate (no hard
      delete)
- [ ] 🏷️ Cut release `v0.7.0` — **feature-complete MVP candidate**

## Phase 9 — Production readiness & launch → 🏷️ `v1.0.0`

### 9.1 App identity & platform config

- [ ] Confirm final Android `applicationId` + iOS bundle identifier (rename from defaults if needed)
- [ ] App display name (ar + en), launcher icons (adaptive Android + iOS set), branded native splash
      (`flutter_native_splash` — added in #37)
- [ ] Android: `targetSdk`/`compileSdk` current per Play policy; R8/ProGuard keep-rules verified for maps,
      Firebase, sqflite; `android:allowBackup`/network-security config reviewed
- [ ] iOS: minimum iOS version set; `Info.plist` usage strings (ar+en) for location, camera, photo library,
      notifications
- [ ] Permissions audit — request-in-context only (location on map open, notifications on first relevant entry,
      camera/gallery on avatar/product upload)

### 9.2 Third-party services (production credentials)

- [ ] **Google Maps**: Cloud project + billing; separate restricted API keys for Android (SHA-1/SHA-256 +
      package) and iOS (bundle id); keys injected via build config — **never committed**
- [ ] **Firebase (push only)**: production project; Android + iOS apps registered; `google-services.json` /
      `GoogleService-Info.plist` in place; APNs auth key uploaded; FCM server credentials handed to backend
      (backend M7)
- [ ] **Google Sign-In**: OAuth clients for Android (both SHA fingerprints) + iOS; consent screen approved
- [ ] **Sign in with Apple**: capability enabled; Services ID + key configured with the backend (Socialite)
- [ ] **Paymob** ⛔: production merchant + HMAC on the backend; app E2E against sandbox (wallets + InstaPay),
      then one live smoke payment + refund path verified
- [ ] **Reverb websockets**: production host/port/TLS reachable from devices; `POST /broadcasting/auth` verified
      against production Sanctum
- [ ] Production `BASE_URL` (`https://api.osta.dev/api/v1`) supplied via `--dart-define` in release CI — no
      hardcoded hosts anywhere (audit)

### 9.3 Signing & store accounts

- [ ] Android: release keystore generated + stored in secrets manager; `key.properties` git-ignored; **Play App
      Signing** enrolled
- [ ] iOS: Apple Developer Program; distribution certificate + provisioning profiles (push + Sign in with Apple
      capabilities)
- [ ] Google Play Console app created — store listing **ar + en**, screenshots (both themes, RTL), feature
      graphic, content rating, **Data safety form**, privacy policy URL (public, matches #38 content)
- [ ] App Store Connect app created — listing ar + en, screenshots, **privacy nutrition labels**, export
      compliance, sign-in test account + review notes for App Review

### 9.4 Release engineering

- [ ] CI release workflow: tag `v*` → build signed AAB + iOS archive (release mode, prod `BASE_URL`) → upload
      artifacts (extends the single-job CI; see [`docs/ROADMAP.md`](docs/ROADMAP.md) Phase 4)
- [ ] Crash/error reporting decision + wiring (talker is device-local only): Sentry (no extra Firebase surface)
      vs Crashlytics — record as an ADR in [`osta_readme_files/decisions/`](osta_readme_files/decisions/README.md)
- [ ] Store-listing assets pipeline: screenshot set regenerated per release (light/dark × ar/en)
- [ ] Versioning check: `pubspec.yaml` `X.Y.Z+B` matches tag; build number monotonic across both stores

### 9.5 Hardening & QA gate (MVP regression)

- [ ] Full manual regression matrix: **2 shells × ar/en × light/dark** on min-spec Android + iPhone hardware
- [ ] Offline drill: airplane-mode pass over every §7-cached screen; queued mutations sync on reconnect; no
      data loss
- [ ] Realtime drill: kill/restore network mid-booking; poll fallback + reconcile verified on customer +
      business sides
- [ ] Push drill (#52): all three app states (foreground/background/terminated) on both platforms; deep links
      land correctly on both shells
- [ ] Payments drill ⛔ (#46, when live): success / decline / timeout / cancel / double-tap-retry — no double
      charge
- [ ] Performance pass: cold start, map scrolling, list jank (DevTools); app size check
      (`--analyze-size`); `cached_network_image` everywhere images load
- [ ] Accessibility pass: TalkBack/VoiceOver on core flows; contrast suite green; text scale 2.0 without
      overflow; touch targets ≥48dp
- [ ] Security review: no secrets in repo/history; tokens only in `TokenStorage`; talker redaction verified in
      release build; HTTPS everywhere; WebView (Paymob) restricted to gateway origin
- [ ] L10n audit: ARB parity test green; no untranslated strings in either locale; EGP/date/digit formatting
      spot-check in ar_EG
- [ ] `flutter analyze` zero infos on release branch; all tests + goldens green in CI

### 9.6 Beta → launch

- [ ] Internal testing track (Play) + TestFlight build distributed to the team (youssef · haidy · adel · roaa ·
      haneen) — one full bug-bash cycle, issues filed and triaged
- [ ] Closed beta with real users (staged Play track + TestFlight external) — crash-free sessions ≥ 99.5%
      before promoting
- [ ] Store submissions passed review on both platforms
- [ ] 🏷️ Tag **`v1.0.0`** on `main`; CHANGELOG cut; GitHub Release with bilingual notes + artifacts
- [ ] **Staged rollout**: Play 10% → 50% → 100%; iOS phased release ON — monitor crash reporting + backend
      error rates at each step
- [ ] Post-launch watch (first 72h): crash triage SLO, store reviews replied to (ar/en), hotfix path exercised
      if needed (`v1.0.x`)

## Phase 10 — Post-launch & Phase 2 (post-`v1.0.0`)

- [ ] ⛔ Merge **Paymob #46** if it missed the v1.0.0 train (ship as `v1.1.0`)
- [ ] ⛔ **Business More hub + extras** [#58](https://github.com/YoussefSalem582/Osta-App/issues/58) —
      role-agnostic `ProviderMoreShell`, analytics, capacity, reviews inbox (backend M6)
- [ ] ⛔ **Solo-mechanic flow** [#59](https://github.com/YoussefSalem582/Osta-App/issues/59) — enable chooser
      tile; skills + map-drawn service area; provider shell behind capability flags
- [ ] ⛔ **Tow-truck flow** [#60](https://github.com/YoussefSalem582/Osta-App/issues/60) — roadside jobs queue;
      live GPS over `tracking.{jobId}`; customer live-tracking map
- [ ] Revisit deferred tooling per [`docs/ROADMAP.md`](docs/ROADMAP.md) (json_serializable → freezed →
      injectable → flavors/CI matrix → fpdart) — one phase at a time, only when the team agrees
- [ ] Sync `AGENTS.md` with the four `OSTA_plan.md` amendments (talker, skeletonizer, offline-first,
      releases/tags) — small `docs/` branch

---

## Standing rules while working this list

- Milestones are sequential; epics **within** a phase can proceed in parallel across owners when their
  dependencies are merged (e.g. #34 needs #33; #39 needs #35; #55's assign picker needs #62).
- ⛔ items never block the train — skip and revisit; releases cut whatever is merged and green.
- `main` stays releasable after every merge; every phase ends with its 🏷️ tag.
- When anything here conflicts with [`OSTA_plan.md`](OSTA_plan.md) or [`AGENTS.md`](AGENTS.md), those win
  (precedence: [`OSTA_plan.md` §3](OSTA_plan.md)).
