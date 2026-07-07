import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/features/auth/domain/auth_repository.dart';

enum AuthMode { login, register }

enum AuthStatus { idle, submitting, failure }

class AuthState extends Equatable {
  const AuthState({
    this.mode = AuthMode.login,
    this.status = AuthStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
  });

  final AuthMode mode;
  final AuthStatus status;
  final String? errorMessage;

  /// Server 422 field → messages, surfaced inline under the matching field.
  final Map<String, List<String>> fieldErrors;

  bool get isSubmitting => status == AuthStatus.submitting;

  @override
  List<Object?> get props => [mode, status, errorMessage, fieldErrors];
}

/// Drives the auth screen. Sends `account_type = activeRole` on every request
/// and, on success, hands the authoritative role back to [SessionController]
/// (which self-heals a wrong-shell choice). The router then leaves this screen.
///
/// Registered as a factory by hand in `configureDependencies()`.
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo, this._session) : super(const AuthState());

  final AuthRepository _repo;
  final SessionController _session;

  /// The role the chooser selected — the `account_type` every request carries.
  AppRole get _accountType => _session.state.activeRole ?? AppRole.customer;

  void toggleMode() {
    emit(
      AuthState(
        mode: state.mode == AuthMode.login ? AuthMode.register : AuthMode.login,
      ),
    );
  }

  /// Sets the initial mode from the auth-choose landing (`?mode=`). No-op when
  /// already in that idle mode, so it's safe to call on every build.
  void setMode(AuthMode mode) {
    if (state.mode == mode && state.status == AuthStatus.idle) return;
    emit(AuthState(mode: mode));
  }

  Future<void> login({required String email, required String password}) {
    final role = _accountType;
    return _run(
      role,
      () => _repo.login(email: email, password: password, accountType: role),
    );
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
    String? phone,
  }) {
    final role = _accountType;
    return _run(
      role,
      () => _repo.register(
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        password: password,
        phone: phone,
        accountType: role,
      ),
    );
  }

  Future<void> _run(
    AppRole requested,
    Future<AppRole> Function() action,
  ) async {
    emit(AuthState(mode: state.mode, status: AuthStatus.submitting));
    try {
      final role = await action();
      await _session.onAuthenticated(role, requested: requested);
    } on ValidationException catch (error) {
      emit(
        AuthState(
          mode: state.mode,
          status: AuthStatus.failure,
          errorMessage: error.message,
          fieldErrors: error.fieldErrors,
        ),
      );
    } on ApiException catch (error) {
      emit(
        AuthState(
          mode: state.mode,
          status: AuthStatus.failure,
          errorMessage: error.message,
        ),
      );
    } on Exception {
      emit(AuthState(mode: state.mode, status: AuthStatus.failure));
    }
  }
}
