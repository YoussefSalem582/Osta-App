import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/shared/profile/data/model/profile_response/data.dart';
import 'package:osta/features/shared/profile/data/profile_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late ProfileCache cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    cache = ProfileCache(prefs);
  });

  test('write then read round-trips the profile and timestamp', () async {
    final data = Data(
      id: '1',
      firstName: 'Amina',
      fullName: 'Amina Hassan',
      username: 'amina',
      supportId: 'OSTA-1',
    );
    final at = DateTime.fromMillisecondsSinceEpoch(1700000000000);

    await cache.write(data, at: at);
    final read = cache.read();

    expect(read, isNotNull);
    expect(read!.fullName, 'Amina Hassan');
    expect(read.username, 'amina');
    expect(cache.fetchedAt, at);
  });

  test('read returns null on a miss', () {
    expect(cache.read(), isNull);
    expect(cache.fetchedAt, isNull);
  });

  test('clear empties the cache', () async {
    await cache.write(
      Data(fullName: 'X'),
      at: DateTime.fromMillisecondsSinceEpoch(1),
    );
    await cache.clear();

    expect(cache.read(), isNull);
    expect(cache.fetchedAt, isNull);
  });

  test('a corrupt entry reads as a miss, not a crash', () async {
    await prefs.setString(SessionStore.profileCacheKey, 'not json');
    expect(cache.read(), isNull);
  });

  test('clearSession wipes the profile cache keys', () async {
    await cache.write(
      Data(fullName: 'Y'),
      at: DateTime.fromMillisecondsSinceEpoch(1),
    );
    // SessionStore owns the keys and clears them on full sign-out.
    await prefs.remove(SessionStore.profileCacheKey);
    await prefs.remove(SessionStore.profileFetchedAtKey);

    expect(cache.read(), isNull);
    expect(cache.fetchedAt, isNull);
  });
}
