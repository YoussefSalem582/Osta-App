import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the first-run routing flags: UI language and last-acted
/// [AppRole]. Tokens live in [TokenStorage]; these live in
/// [SharedPreferences].
class SessionStore {
  SessionStore(this._prefs, this._tokens);

  final SharedPreferences _prefs;
  final TokenStorage _tokens;

  static const _localeKey = 'session_locale';
  static const _activeRoleKey = 'session_active_role';
  static const _businessDraftKey = 'business_onboarding_draft';

  /// Keys for the profile read-cache (`GET /me`). Declared here — the prefs
  /// registry — so [clearSession] can wipe them on sign-out; the profile
  /// feature's `ProfileCache` reads the same constants (core ← feature).
  static const profileCacheKey = 'profile_me';
  static const profileFetchedAtKey = 'profile_me_fetched_at';

  /// The chosen language code (`ar`/`en`), or `null` on a true first run —
  /// the signal that gates the one-time language screen.
  String? get localeCode => _prefs.getString(_localeKey);

  /// Whether the language screen has already been completed.
  bool get isLanguageSelected => _prefs.containsKey(_localeKey);

  Future<void> writeLocale(String code) => _prefs.setString(_localeKey, code);

  /// The persisted active role, or `null` when the chooser still owes a pick.
  AppRole? get activeRole => AppRole.fromWire(_prefs.getString(_activeRoleKey));

  Future<void> writeActiveRole(AppRole role) =>
      _prefs.setString(_activeRoleKey, role.wireName);

  /// Clears the active role only — keeps the token — so "switch role" returns
  /// the user to the chooser without logging them out.
  Future<void> clearActiveRole() => _prefs.remove(_activeRoleKey);

  /// The in-progress business onboarding wizard, as a JSON string — plain
  /// preferences (not [TokenStorage]) since a trade name/map pin aren't secrets.
  String? get businessDraft => _prefs.getString(_businessDraftKey);

  Future<void> writeBusinessDraft(String json) =>
      _prefs.setString(_businessDraftKey, json);

  Future<void> clearBusinessDraft() => _prefs.remove(_businessDraftKey);

  /// Whether a Sanctum access token is held in secure storage.
  Future<bool> hasToken() async => await _tokens.readAccessToken() != null;

  /// Full sign-out: drops the tokens, the active role, and the profile cache
  /// so the next user never sees the previous one.
  Future<void> clearSession() async {
    await _tokens.clear();
    await clearActiveRole();
    await _prefs.remove(profileCacheKey);
    await _prefs.remove(profileFetchedAtKey);
  }
}
