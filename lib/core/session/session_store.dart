import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the first-run flags that drive routing: the chosen UI language and
/// the [AppRole] the user last acted as. Tokens live in [TokenStorage] (secure
/// storage); the role/locale flags live in [SharedPreferences] — together they
/// form the `{token, activeRole}` the splash reads on boot.
///
/// Registered by hand in `configureDependencies()` — no injectable codegen.
class SessionStore {
  SessionStore(this._prefs, this._tokens);

  final SharedPreferences _prefs;
  final TokenStorage _tokens;

  static const _localeKey = 'session_locale';
  static const _activeRoleKey = 'session_active_role';

  /// The chosen language code (`ar`/`en`), or `null` on a true first run —
  /// the signal that gates the one-time language screen.
  String? get localeCode => _prefs.getString(_localeKey);

  /// Whether the language screen has already been completed.
  bool get isLanguageSelected => _prefs.containsKey(_localeKey);

  Future<void> writeLocale(String code) => _prefs.setString(_localeKey, code);

  /// The persisted active role, or `null` when the chooser still owes a pick.
  AppRole? get activeRole => AppRole.fromWire(_prefs.getString(_activeRoleKey));

  /// Reads the active role from secure storage, falling back to SharedPreferences.
  Future<AppRole?> readActiveRole() async {
    final secureWire = await _tokens.readActiveRole();
    return AppRole.fromWire(secureWire) ?? activeRole;
  }

  Future<void> writeActiveRole(AppRole role) async {
    await _prefs.setString(_activeRoleKey, role.wireName);
    await _tokens.writeActiveRole(role.wireName);
  }

  /// Clears the active role only — keeps the token — so "switch role" returns
  /// the user to the chooser without logging them out.
  Future<void> clearActiveRole() async {
    await _prefs.remove(_activeRoleKey);
    await _tokens.deleteActiveRole();
  }

  /// Whether a Sanctum access token is held in secure storage.
  Future<bool> hasToken() async => await _tokens.readAccessToken() != null;

  /// Full sign-out: drops both the tokens and the active role.
  Future<void> clearSession() async {
    await _tokens.clear();
    await clearActiveRole();
  }
}
