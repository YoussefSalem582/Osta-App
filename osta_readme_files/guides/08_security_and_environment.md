# 🔐 Security & Environment / الأمان والبيئة

> [INDEX](../INDEX.md) > Security & Environment

How OSTA handles secrets, runtime config, tokens, and logging. See [ADR 006](../decisions/006-dio-envelope-client-sanctum.md) for the auth transport.

> ‏كيف يتعامل OSTA مع الأسرار وإعدادات وقت التشغيل والتوكنات والتسجيل. راجع [ADR 006](../decisions/006-dio-envelope-client-sanctum.md) لطبقة نقل المصادقة.

---

## No `.env` — `--dart-define` only / لا يوجد `.env` — فقط `--dart-define`

Runtime config is passed at build time and surfaced through `AppConfig` (`lib/core/config/app_config.dart`). There is **no `.env` file**. A single `BASE_URL` dart-define is read; there is no `FLAVOR` and no `AppFlavor` enum — multi-flavor builds are deferred (see [ROADMAP](../../docs/ROADMAP.md), Phase 4).

> ‏تُمرَّر إعدادات وقت التشغيل أثناء البناء وتُتاح عبر `AppConfig` (`lib/core/config/app_config.dart`). لا يوجد ملف `.env`. تتم قراءة قيمة `BASE_URL` واحدة فقط عبر dart-define؛ لا يوجد `FLAVOR` ولا تعداد `AppFlavor` — بناء النكهات المتعددة مؤجَّل (راجع [ROADMAP](../../docs/ROADMAP.md)، المرحلة 4).

| Value | Source | Accessor |
|---|---|---|
| Base URL | `--dart-define=BASE_URL=...` (default `https://api.osta.dev/api/v1`) | `AppConfig.baseUrl` |

Run:

```bash
flutter run --dart-define=BASE_URL=https://api.osta.dev/api/v1
```

CI passes the same dart-define (`.github/workflows/ci.yml`). Never read `Platform.environment` directly; never hardcode a URL.

> ‏يُمرِّر الـ CI نفس الـ dart-define (`.github/workflows/ci.yml`). لا تقرأ `Platform.environment` مباشرةً، ولا تُضمِّن أي رابط ثابت في الكود.

---

## Tokens / التوكنات

- Auth tokens go **only** in `TokenStorage` (`lib/core/auth/token_storage.dart`), backed by `flutter_secure_storage`. Keys: `access_token`, `refresh_token`.
- **Never** put tokens in `SharedPreferences` (that's for non-secret prefs: theme, locale, flags, `activeRole`… — though [app #33](https://github.com/YoussefSalem582/Osta-App/issues/33) stores `activeRole` in secure storage too).
- Sanctum dual-token: access (~60 min) + refresh (30 d). `AuthInterceptor` does a single 401 refresh-retry; a failed refresh emits on `AuthEvents.onSessionExpired` → clear tokens → route to login.

> ‏توكنات المصادقة تُخزَّن **فقط** في `TokenStorage` المدعوم بـ `flutter_secure_storage`، ولا تُوضع أبدًا في `SharedPreferences` (المخصص للتفضيلات غير السرية). نظام Sanctum يستخدم توكنين: توكن وصول (~60 دقيقة) وتوكن تجديد (30 يومًا)، ويقوم `AuthInterceptor` بمحاولة تجديد واحدة عند خطأ 401؛ وفشل التجديد يُطلق حدث `AuthEvents.onSessionExpired` فيُمسح التوكن ويُعاد التوجيه لتسجيل الدخول.

---

## Logging redaction / تنقية سجلات التسجيل

`pretty_dio_logger` is configured to **omit auth headers/bodies** — the bearer token never hits logs. Keep it that way when adjusting logging.

> ‏تم ضبط `pretty_dio_logger` على **حذف ترويسات وأجساد المصادقة**، بحيث لا يظهر توكن الـ bearer في السجلات أبدًا. حافظ على ذلك عند تعديل التسجيل.

---

## Payments / المدفوعات

Paymob uses **hosted checkout in a WebView** ([app #46](https://github.com/YoussefSalem582/Osta-App/issues/46)) — no card data ever touches the app; no payment SDK. The webhook (server-to-server, HMAC) is the source of truth ([backend #48](https://github.com/YoussefSalem582/osta_backend/issues/48)); the app polls payment status. See [payments.md](../features/payments.md).

> ‏يستخدم Paymob صفحة دفع مُستضافة داخل WebView ([app #46](https://github.com/YoussefSalem582/Osta-App/issues/46))، فلا تمر بيانات البطاقة عبر التطبيق ولا يُستخدم أي SDK للدفع. الـ webhook (خادم لخادم، بتوقيع HMAC) هو المصدر الموثوق ([backend #48](https://github.com/YoussefSalem582/osta_backend/issues/48))، والتطبيق يستعلم عن حالة الدفع دوريًا. راجع [payments.md](../features/payments.md).

---

## Generated files & git / الملفات المولَّدة و git

Only `lib/core/l10n/` is generated and **git-ignored** — regenerate with `flutter gen-l10n`, don't commit. There are no `*.g.dart`, `*.freezed.dart`, or `injection.config.dart` files: models are plain `Equatable` classes with hand-written `fromJson`/`toJson`, and dependencies are registered **manually** in `lib/core/di/injection.dart`. Code-generation tooling (`freezed`, `json_serializable`, `injectable`, `build_runner`) is deferred (see [ROADMAP](../../docs/ROADMAP.md), Phases 1–3).

> ‏الملفات المولَّدة الوحيدة هي داخل `lib/core/l10n/` وهي مُستثناة من git — أعِد توليدها بـ `flutter gen-l10n` ولا تُودعها. لا توجد ملفات `*.g.dart` أو `*.freezed.dart` أو `injection.config.dart`: النماذج عبارة عن أصناف `Equatable` عادية مع `fromJson`/`toJson` مكتوبة يدويًا، والتبعيات تُسجَّل **يدويًا** في `lib/core/di/injection.dart`. أدوات توليد الكود (`freezed` و`json_serializable` و`injectable` و`build_runner`) مؤجَّلة (راجع [ROADMAP](../../docs/ROADMAP.md)، المراحل 1–3).

---

## Upcoming secrets (per feature epics) / الأسرار القادمة (حسب ملاحم الميزات)

- **Google Maps API key** (map/discovery [app #41](https://github.com/YoussefSalem582/Osta-App/issues/41)) — platform config, not Dart source; keep out of git.
- **Firebase config** (FCM push [app #52](https://github.com/YoussefSalem582/Osta-App/issues/52)) — `google-services.json` / `GoogleService-Info.plist`, platform-native; **no `firebase_auth`** (social login is a server-side Socialite exchange, [app #36](https://github.com/YoussefSalem582/Osta-App/issues/36)).
- **Release signing / store deploy** — future work; the current CI runs a single "format · analyze · test" job on ubuntu and does not build platform artifacts (build/matrix jobs deferred, see [ADR 008](../decisions/008-github-actions-ci.md) and [ROADMAP](../../docs/ROADMAP.md) Phase 4).

> ‏أسرار مستقبلية: مفتاح Google Maps API (الخريطة/الاكتشاف) إعداد خاص بالمنصة وليس كود Dart ويُبقى خارج git؛ وإعداد Firebase لإشعارات FCM هو ملفات أصلية للمنصة (`google-services.json` / `GoogleService-Info.plist`) بدون `firebase_auth` لأن تسجيل الدخول الاجتماعي يتم عبر تبادل Socialite على الخادم؛ وتوقيع الإصدار والنشر للمتاجر عمل مستقبلي، فالـ CI الحالي يشغّل مهمة واحدة فقط ("format · analyze · test") على ubuntu ولا يبني مخرجات المنصات (مهام البناء/المصفوفة مؤجَّلة).

---

## Related / روابط ذات صلة

- [04_how_to_add_new_api.md](04_how_to_add_new_api.md) · [../features/auth.md](../features/auth.md) · [../features/payments.md](../features/payments.md) · [ADR 006](../decisions/006-dio-envelope-client-sanctum.md)
