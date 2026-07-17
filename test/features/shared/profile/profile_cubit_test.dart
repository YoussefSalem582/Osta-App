import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/profile/data/model/profile_response/data.dart';
import 'package:osta/features/shared/profile/data/model/profile_response/profile_response.dart';
import 'package:osta/features/shared/profile/data/profile_cache.dart';
import 'package:osta/features/shared/profile/data/repo/profile_repo.dart';
import 'package:osta/features/shared/profile/presentation/cubit/profile_cubit.dart';
import 'package:osta/features/shared/profile/presentation/cubit/profile_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Overrides the read path only; the ApiClient/ProfileCache handed to `super`
/// are never touched because every method below is stubbed.
class _FakeRepo extends ProfileRepo {
  // super params can't name the private `_api`/`_cache` fields across libraries.
  // ignore: use_super_parameters
  _FakeRepo(ApiClient api, ProfileCache cache) : super(api, cache);

  Data? cachedValue;
  DateTime? cachedAtValue;
  ProfileResponse? networkResult;
  Exception? networkError;

  @override
  Data? get cachedProfile => cachedValue;

  @override
  DateTime? get cachedAt => cachedAtValue;

  @override
  Future<ProfileResponse> getProfile() async {
    final error = networkError;
    if (error != null) throw error;
    return networkResult!;
  }
}

Future<_FakeRepo> _makeRepo() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return _FakeRepo(ApiClient(Dio()), ProfileCache(prefs));
}

void main() {
  test('cache-then-network: emits cached first, then fresh', () async {
    final repo = await _makeRepo()
      ..cachedValue = Data(fullName: 'Cached')
      ..cachedAtValue = DateTime.fromMillisecondsSinceEpoch(1)
      ..networkResult = ProfileResponse(
        success: true,
        data: Data(fullName: 'Fresh'),
      );
    final cubit = ProfileCubit(repo: repo);
    final states = <ProfileState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.getProfile();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states, hasLength(2));
    final first = states[0] as ProfileSuccess;
    final second = states[1] as ProfileSuccess;
    expect(first.fromCache, isTrue);
    expect(first.profile.data!.fullName, 'Cached');
    expect(second.fromCache, isFalse);
    expect(second.profile.data!.fullName, 'Fresh');
  });

  test('offline with a cache keeps the cached copy and no error', () async {
    final repo = await _makeRepo()
      ..cachedValue = Data(fullName: 'Cached')
      ..networkError = const NetworkException();
    final cubit = ProfileCubit(repo: repo);
    final states = <ProfileState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.getProfile();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states, hasLength(1));
    expect((states.single as ProfileSuccess).fromCache, isTrue);
  });

  test('offline with no cache emits loading then error', () async {
    final repo = await _makeRepo()
      ..networkError = const NetworkException('down');
    final cubit = ProfileCubit(repo: repo);
    final states = <ProfileState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.getProfile();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.first, isA<ProfileLoading>());
    expect(states.last, isA<ProfileError>());
  });
}
