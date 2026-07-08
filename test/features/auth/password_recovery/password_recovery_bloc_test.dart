import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/features/auth/password_recovery/presentation/bloc/password_recovery_bloc.dart';
import 'package:osta/features/auth/shared/domain/auth_repository.dart';

/// Stub repository whose recovery calls succeed, or throw [error] when set.
class _StubRepo implements AuthRepository {
  _StubRepo({this.error});

  final Exception? error;

  @override
  Future<void> forgotPassword({required String email}) async {
    if (error != null) throw error!;
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    if (error != null) throw error!;
  }

  @override
  Future<bool> isUsernameAvailable(String username) async => true;

  @override
  Future<void> uploadAvatar({required String filePath}) async {}

  @override
  Future<void> logout() async {}

  @override
  Future<AppRole> login({
    required String email,
    required String password,
    required AppRole accountType,
  }) async => accountType;

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
}

void main() {
  test('ResetLinkRequested success emits emailSent', () async {
    final bloc = PasswordRecoveryBloc(_StubRepo())
      ..add(const ResetLinkRequested('a@b.com'));
    await pumpEventQueue();

    expect(bloc.state.status, RecoveryStatus.emailSent);
  });

  test('ResetLinkRequested maps a 422 to inline field errors', () async {
    final bloc = PasswordRecoveryBloc(
      _StubRepo(
        error: const ValidationException('bad', {
          'email': ['is required'],
        }),
      ),
    )..add(const ResetLinkRequested(''));
    await pumpEventQueue();

    expect(bloc.state.status, RecoveryStatus.failure);
    expect(bloc.state.fieldErrors['email'], ['is required']);
  });

  test('PasswordResetSubmitted success emits resetSuccess', () async {
    final bloc = PasswordRecoveryBloc(_StubRepo())
      ..add(
        const PasswordResetSubmitted(
          email: 'a@b.com',
          token: 'tok',
          password: 'Passw0rd',
        ),
      );
    await pumpEventQueue();

    expect(bloc.state.status, RecoveryStatus.resetSuccess);
  });

  test('PasswordResetSubmitted surfaces a server error message', () async {
    final bloc =
        PasswordRecoveryBloc(_StubRepo(error: const ServerException('nope')))
          ..add(
            const PasswordResetSubmitted(
              email: 'a@b.com',
              token: 't',
              password: 'x',
            ),
          );
    await pumpEventQueue();

    expect(bloc.state.status, RecoveryStatus.failure);
    expect(bloc.state.errorMessage, 'nope');
  });
}
