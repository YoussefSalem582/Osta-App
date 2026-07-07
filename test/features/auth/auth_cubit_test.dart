import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/auth_events.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/auth/domain/auth_repository.dart';
import 'package:osta/features/auth/presentation/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/fakes.dart';

/// Records whether the network login path was hit.
class _RecordingRepo implements AuthRepository {
  bool loginCalled = false;

  @override
  Future<AppRole> login({
    required String email,
    required String password,
    required AppRole accountType,
  }) async {
    loginCalled = true;
    return accountType;
  }

  @override
  Future<AppRole> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    required AppRole accountType,
    String? phone,
  }) async => accountType;

  @override
  Future<void> forgotPassword({required String email}) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {}

  @override
  Future<void> logout() async {}
}

Future<SessionController> _session() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  return SessionController(
    SessionStore(prefs, FakeTokenStorage()),
    AuthEvents(),
    FakeAuthRepository(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'debug test-account login skips the network and authenticates',
    () async {
      final repo = _RecordingRepo();
      final session = await _session();
      final cubit = AuthCubit(repo, session);

      await cubit.login(
        email: AuthCubit.debugEmail,
        password: AuthCubit.debugPassword,
      );

      // Bypassed /auth/login entirely...
      expect(repo.loginCalled, isFalse);
      // ...but the session is authenticated (routes to the shell).
      expect(session.state.hasToken, isTrue);
    },
  );

  test('non-test credentials go through the repository', () async {
    final repo = _RecordingRepo();
    final session = await _session();
    final cubit = AuthCubit(repo, session);

    await cubit.login(email: 'real@user.com', password: 'whatever');

    expect(repo.loginCalled, isTrue);
  });
}
