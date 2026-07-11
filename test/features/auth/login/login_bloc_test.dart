import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/network/dio_client.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/auth/login/presentation/bloc/login_bloc.dart';
import 'package:osta/features/auth/shared/domain/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/fakes.dart';

/// Records whether the network login path was hit; throws [error] when set.
class _RecordingRepo implements AuthRepository {
  _RecordingRepo({this.error});

  final Exception? error;
  bool loginCalled = false;

  @override
  Future<AppRole> login({
    required String email,
    required String password,
    required AppRole accountType,
  }) async {
    loginCalled = true;
    if (error != null) throw error!;
    return accountType;
  }

  @override
  Future<bool> isUsernameAvailable(String username) async => true;

  @override
  Future<void> uploadAvatar({required String filePath}) async {}

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
      LoginBloc(repo, session).add(
        const LoginSubmitted(
          email: LoginBloc.debugEmail,
          password: LoginBloc.debugPassword,
        ),
      );
      await pumpEventQueue();

      // Bypassed /auth/login entirely...
      expect(repo.loginCalled, isFalse);
      // ...but the session is authenticated (routes to the shell).
      expect(session.state.hasToken, isTrue);
    },
  );

  test('non-test credentials go through the repository', () async {
    final repo = _RecordingRepo();
    LoginBloc(repo, await _session()).add(
      const LoginSubmitted(email: 'real@user.com', password: 'whatever'),
    );
    await pumpEventQueue();

    expect(repo.loginCalled, isTrue);
  });

  test('a validation error surfaces inline field errors', () async {
    final repo = _RecordingRepo(
      error: const ValidationException('bad', {
        'email': ['taken'],
      }),
    );
    final bloc = LoginBloc(repo, await _session())
      ..add(const LoginSubmitted(email: 'a@b.com', password: 'x'));
    await pumpEventQueue();

    expect(bloc.state.status, LoginStatus.failure);
    expect(bloc.state.fieldErrors['email'], ['taken']);
  });

  test('a network error sets the networkError flag', () async {
    final repo = _RecordingRepo(error: const NetworkException());
    final bloc = LoginBloc(repo, await _session())
      ..add(const LoginSubmitted(email: 'a@b.com', password: 'x'));
    await pumpEventQueue();

    expect(bloc.state.status, LoginStatus.failure);
    expect(bloc.state.networkError, isTrue);
  });
}
