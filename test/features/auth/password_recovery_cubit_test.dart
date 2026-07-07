import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/features/auth/domain/auth_repository.dart';
import 'package:osta/features/auth/presentation/password_recovery_cubit.dart';

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
  test('sendResetLink success emits emailSent', () async {
    final cubit = PasswordRecoveryCubit(_StubRepo());

    await cubit.sendResetLink('a@b.com');

    expect(cubit.state.status, RecoveryStatus.emailSent);
  });

  test('sendResetLink maps a 422 to inline field errors', () async {
    final cubit = PasswordRecoveryCubit(
      _StubRepo(
        error: const ValidationException('bad', {
          'email': ['is required'],
        }),
      ),
    );

    await cubit.sendResetLink('');

    expect(cubit.state.status, RecoveryStatus.failure);
    expect(cubit.state.fieldErrors['email'], ['is required']);
  });

  test('resetPassword success emits resetSuccess', () async {
    final cubit = PasswordRecoveryCubit(_StubRepo());

    await cubit.resetPassword(
      email: 'a@b.com',
      token: 'tok',
      password: 'Passw0rd',
    );

    expect(cubit.state.status, RecoveryStatus.resetSuccess);
  });

  test('resetPassword surfaces a server error message', () async {
    final cubit = PasswordRecoveryCubit(
      _StubRepo(error: const ServerException('nope')),
    );

    await cubit.resetPassword(email: 'a@b.com', token: 't', password: 'x');

    expect(cubit.state.status, RecoveryStatus.failure);
    expect(cubit.state.errorMessage, 'nope');
  });
}
