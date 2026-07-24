import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/shared/profile/data/models/profile_response/data.dart';
import 'package:osta/features/shared/profile/data/models/profile_response/profile_response.dart';
import 'package:osta/features/shared/profile/domain/profile_repository.dart';
import 'package:osta/features/shared/profile/presentation/profile/cubit/profile_cubit.dart';
import 'package:osta/features/shared/profile/presentation/profile/cubit/profile_state.dart';

/// Stubs the read path only; the write methods are never touched here.
class _FakeRepo implements ProfileRepository {
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

  @override
  Future<ProfileResponse?> updateProfile({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
  }) => throw UnimplementedError();

  @override
  Future<ProfileResponse?> uploadAvatar(String filePath) =>
      throw UnimplementedError();

  @override
  Future<void> deleteAccount() => throw UnimplementedError();
}

void main() {
  test('cache-then-network: emits cached first, then fresh', () async {
    final repo = _FakeRepo()
      ..cachedValue = Data(fullName: 'Cached')
      ..cachedAtValue = DateTime.fromMillisecondsSinceEpoch(1)
      ..networkResult = ProfileResponse(
        success: true,
        data: Data(fullName: 'Fresh'),
      );
    final cubit = ProfileCubit(repo);
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
    final repo = _FakeRepo()
      ..cachedValue = Data(fullName: 'Cached')
      ..networkError = const NetworkException();
    final cubit = ProfileCubit(repo);
    final states = <ProfileState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.getProfile();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states, hasLength(1));
    expect((states.single as ProfileSuccess).fromCache, isTrue);
  });

  test('offline with no cache emits loading then error', () async {
    final repo = _FakeRepo()..networkError = const NetworkException('down');
    final cubit = ProfileCubit(repo);
    final states = <ProfileState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.getProfile();
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.first, isA<ProfileLoading>());
    expect(states.last, isA<ProfileError>());
  });
}
