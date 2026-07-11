import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/network/dio_client.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/auth/register/presentation/bloc/register_bloc.dart';
import 'package:osta/features/auth/shared/domain/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/fakes.dart';

/// Controls the username check ([available] / [usernameError]) and register
/// ([registerError]) outcomes.
class _StubRepo implements AuthRepository {
  _StubRepo({
    this.available = true,
    this.usernameError,
    this.registerError,
    this.avatarError,
  });

  final bool available;
  final Exception? usernameError;
  final Exception? registerError;
  final Exception? avatarError;
  bool registerCalled = false;
  String? uploadedAvatarPath;

  @override
  Future<bool> isUsernameAvailable(String username) async {
    if (usernameError != null) throw usernameError!;
    return available;
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
  }) async {
    registerCalled = true;
    if (registerError != null) throw registerError!;
    return accountType;
  }

  @override
  Future<AppRole> login({
    required String email,
    required String password,
    required AppRole accountType,
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
  Future<void> uploadAvatar({required String filePath}) async {
    if (avatarError != null) throw avatarError!;
    uploadedAvatarPath = filePath;
  }

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

  test('UsernameChanged marks a free name available', () async {
    final bloc = RegisterBloc(_StubRepo(), await _session())
      ..add(const UsernameChanged('free_name'));
    await pumpEventQueue();

    expect(bloc.state.usernameStatus, UsernameStatus.available);
    expect(bloc.state.checkedUsername, 'free_name');
  });

  test('UsernameChanged marks a taken name taken', () async {
    final bloc = RegisterBloc(_StubRepo(available: false), await _session())
      ..add(const UsernameChanged('taken'));
    await pumpEventQueue();

    expect(bloc.state.usernameStatus, UsernameStatus.taken);
  });

  test('UsernameChanged fails silent to unknown on error', () async {
    final bloc = RegisterBloc(
      _StubRepo(usernameError: const NetworkException()),
      await _session(),
    )..add(const UsernameChanged('whatever'));
    await pumpEventQueue();

    expect(bloc.state.usernameStatus, UsernameStatus.unknown);
  });

  test('RegisterSubmitted success goes through the repository', () async {
    final repo = _StubRepo();
    final session = await _session();
    RegisterBloc(repo, session).add(
      const RegisterSubmitted(
        firstName: 'A',
        lastName: 'B',
        username: 'ab',
        email: 'a@b.com',
        password: 'Passw0rd',
      ),
    );
    await pumpEventQueue();

    expect(repo.registerCalled, isTrue);
    expect(session.state.hasToken, isTrue);
  });

  test('RegisterSubmitted uploads the picked avatar after register', () async {
    final repo = _StubRepo();
    final session = await _session();
    RegisterBloc(repo, session).add(
      const RegisterSubmitted(
        firstName: 'A',
        lastName: 'B',
        username: 'ab',
        email: 'a@b.com',
        password: 'Passw0rd',
        photoPath: '/tmp/avatar.jpg',
      ),
    );
    await pumpEventQueue();

    expect(repo.uploadedAvatarPath, '/tmp/avatar.jpg');
    expect(session.state.hasToken, isTrue);
  });

  test('a failed avatar upload still completes registration', () async {
    final repo = _StubRepo(avatarError: const NetworkException());
    final session = await _session();
    RegisterBloc(repo, session).add(
      const RegisterSubmitted(
        firstName: 'A',
        lastName: 'B',
        username: 'ab',
        email: 'a@b.com',
        password: 'Passw0rd',
        photoPath: '/tmp/avatar.jpg',
      ),
    );
    await pumpEventQueue();

    expect(session.state.hasToken, isTrue);
  });

  test('RegisterSubmitted maps a 422 to inline field errors', () async {
    final bloc =
        RegisterBloc(
          _StubRepo(
            registerError: const ValidationException('bad', {
              'username': ['already taken'],
            }),
          ),
          await _session(),
        )..add(
          const RegisterSubmitted(
            firstName: 'A',
            lastName: 'B',
            username: 'ab',
            email: 'a@b.com',
            password: 'Passw0rd',
          ),
        );
    await pumpEventQueue();

    expect(bloc.state.status, RegisterStatus.failure);
    expect(bloc.state.fieldErrors['username'], ['already taken']);
  });
}
