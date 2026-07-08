import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/features/auth/shared/domain/auth_repository.dart';
import 'package:osta/features/auth/shared/presentation/auth_failure.dart';

part 'login_event.dart';
part 'login_state.dart';

/// Drives the login screen. Sends `account_type = activeRole` and, on success,
/// hands the authoritative role back to [SessionController] (which self-heals a
/// wrong-shell choice); the router then leaves this screen.
///
/// Registered as a factory by hand in `configureDependencies()`.
class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc(this._repo, this._session) : super(const LoginState()) {
    on<LoginSubmitted>(_onSubmitted);
  }

  final AuthRepository _repo;
  final SessionController _session;

  /// Debug-only QA / App Review test account — used by the offline bypass and
  /// the login-page field prefill.
  static const debugEmail = 'test@osta.com';
  static const debugPassword = 'osta123123';

  AppRole get _accountType => _session.state.activeRole ?? AppRole.customer;

  Future<void> _onSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    final role = _accountType;
    emit(const LoginState(status: LoginStatus.submitting));

    // ponytail: debug-only offline login for the QA / App Review test account —
    // skips /auth/login so local QA works with the backend unreachable.
    // kDebugMode is compiled out of release builds, so this never ships.
    if (kDebugMode &&
        event.email == debugEmail &&
        event.password == debugPassword) {
      await _session.onAuthenticated(role, requested: role);
      return;
    }

    try {
      final resolved = await _repo.login(
        email: event.email,
        password: event.password,
        accountType: role,
      );
      await _session.onAuthenticated(resolved, requested: role);
    } on Exception catch (error) {
      final failure = mapAuthFailure(error);
      emit(
        LoginState(
          status: LoginStatus.failure,
          errorMessage: failure.message,
          fieldErrors: failure.fieldErrors,
          networkError: failure.networkError,
        ),
      );
    }
  }
}
