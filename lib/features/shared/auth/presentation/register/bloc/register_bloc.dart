import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/features/shared/auth/domain/auth_repository.dart';
import 'package:osta/features/shared/auth/presentation/auth_failure.dart';

part 'register_event.dart';
part 'register_state.dart';

/// Drives the register screen; on success hands the resolved role
/// (`account_type = activeRole`) back to [SessionController].
class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(this._repo, this._session) : super(const RegisterState()) {
    on<UsernameChanged>(_onUsernameChanged);
    on<RegisterSubmitted>(_onSubmitted);
  }

  final AuthRepository _repo;
  final SessionController _session;

  AppRole get _accountType => _session.state.activeRole ?? AppRole.customer;

  Future<void> _onUsernameChanged(
    UsernameChanged event,
    Emitter<RegisterState> emit,
  ) async {
    final name = event.username.trim();
    emit(
      state.copyWith(
        usernameStatus: UsernameStatus.checking,
        checkedUsername: name,
      ),
    );
    // ponytail: debounced in the page, so overlapping checks are rare; the
    // page's checkedUsername==text stale-guard is the safety net. Swap to a
    // bloc_concurrency restartable transformer if that ever proves too loose.
    try {
      final available = await _repo.isUsernameAvailable(name);
      emit(
        state.copyWith(
          usernameStatus: available
              ? UsernameStatus.available
              : UsernameStatus.taken,
          checkedUsername: name,
        ),
      );
    } on Exception {
      // Endpoint unreachable / not yet live: fail silent — the register-submit
      // 422 stays the authoritative uniqueness guard.
      emit(
        state.copyWith(
          usernameStatus: UsernameStatus.unknown,
          checkedUsername: name,
        ),
      );
    }
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    final role = _accountType;
    emit(
      RegisterState(
        status: RegisterStatus.submitting,
        usernameStatus: state.usernameStatus,
        checkedUsername: state.checkedUsername,
      ),
    );
    try {
      final resolved = await _repo.register(
        firstName: event.firstName,
        lastName: event.lastName,
        username: event.username,
        email: event.email,
        password: event.password,
        phone: event.phone,
        accountType: role,
        languagePreference: _session.state.locale?.languageCode,
      );
      // Must run before onAuthenticated, which tears this page down.
      // Best-effort — a failed upload shouldn't block registration.
      if (event.photoPath != null) {
        try {
          await _repo.uploadAvatar(filePath: event.photoPath!);
        } on Exception {
          // Swallow — non-fatal to registration.
        }
      }
      await _session.onAuthenticated(resolved, requested: role);
    } on Exception catch (error) {
      final failure = mapAuthFailure(error);
      emit(
        RegisterState(
          status: RegisterStatus.failure,
          errorMessage: failure.message,
          fieldErrors: failure.fieldErrors,
          networkError: failure.networkError,
          usernameStatus: state.usernameStatus,
          checkedUsername: state.checkedUsername,
        ),
      );
    }
  }
}
