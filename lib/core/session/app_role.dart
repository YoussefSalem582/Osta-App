/// The role a user is currently acting as — OSTA's "one download, then split"
/// model. `customer` + `business` are live; `mechanic` + `tow` are shown as
/// "coming soon" and cannot be selected yet.
///
/// The [wireName] doubles as the `account_type` sent to the auth endpoints and
/// is matched against the `type` returned by `GET /me`, so the persisted
/// `activeRole` and the server's source of truth stay in lock-step.
enum AppRole {
  customer,
  business,
  mechanic,
  tow;

  /// Value sent as `account_type` on register/login and compared to `me.type`.
  String get wireName => name;

  /// Whether the role is live. Only [customer] and [business] can be chosen;
  /// [mechanic] and [tow] render disabled ("coming soon").
  bool get isAvailable => this == AppRole.customer || this == AppRole.business;

  /// Parses a persisted/wire value back into a role, or `null` when it maps to
  /// no in-app shell (e.g. the backend `admin` type).
  static AppRole? fromWire(String? value) {
    for (final role in AppRole.values) {
      if (role.wireName == value) return role;
    }
    return null;
  }
}
