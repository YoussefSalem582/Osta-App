import 'dart:convert';

import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/shared/profile/data/models/profile_response/data.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCache {
  ProfileCache(this._prefs);

  final SharedPreferences _prefs;

  Data? read() {
    final raw = _prefs.getString(SessionStore.profileCacheKey);
    if (raw == null) return null;
    try {
      return Data.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      return null;
    }
  }

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
