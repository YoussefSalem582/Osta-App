import 'dart:convert';

import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/shared/profile/data/model/profile_response/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local read-cache for the signed-in user's profile (`GET /me`).
///
/// Backs the cache-then-network read so the profile renders instantly and
/// still shows when offline. Plain [SharedPreferences] — the same lightweight
/// pattern as the business-onboarding draft; a profile is not a secret. The
/// keys live on [SessionStore] (the prefs registry) so a full sign-out wipes
/// them and the next user never sees the previous profile.
///
/// ponytail: deliberately the light cache — the §7 sqflite offline module
/// (queued writes, TTL, sync) is deferred. Swapping this for that later is a
/// repo-internal change; the cache-then-network shape stays the same.
class ProfileCache {
  ProfileCache(this._prefs);

  final SharedPreferences _prefs;

  /// The last cached profile, or `null` on a miss or a malformed entry.
  Data? read() {
    final raw = _prefs.getString(SessionStore.profileCacheKey);
    if (raw == null) return null;
    try {
      return Data.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null; // corrupt entry — treat it as a miss
    }
  }

  /// When [read]'s entry was written, for the "last updated" affordance.
  DateTime? get fetchedAt {
    final ms = _prefs.getInt(SessionStore.profileFetchedAtKey);
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> write(Data data, {required DateTime at}) async {
    await _prefs.setString(
      SessionStore.profileCacheKey,
      jsonEncode(data.toJson()),
    );
    await _prefs.setInt(
      SessionStore.profileFetchedAtKey,
      at.millisecondsSinceEpoch,
    );
  }

  Future<void> clear() async {
    await _prefs.remove(SessionStore.profileCacheKey);
    await _prefs.remove(SessionStore.profileFetchedAtKey);
  }
}
