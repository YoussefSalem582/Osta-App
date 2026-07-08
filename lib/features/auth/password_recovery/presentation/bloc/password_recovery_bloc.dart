import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/features/auth/shared/domain/auth_repository.dart';
import 'package:osta/features/auth/shared/presentation/auth_failure.dart';

part 'password_recovery_event.dart';
part 'password_recovery_state.dart';

/// Drives both password-recovery steps: request a reset link, then set a new
/// password with the emailed code. One bloc, provided fresh per screen.
///
/// Registered as a factory by hand in `configureDependencies()`.
class PasswordRecoveryBloc
    extends Bloc<PasswordRecoveryEvent, PasswordRecoveryState> {
  PasswordRecoveryBloc(this._repo) : super(const PasswordRecoveryState()) {
    on<ResetLinkRequested>(
      (event, emit) => _run(
        emit,
        RecoveryStatus.emailSent,
        () => _repo.forgotPassword(email: event.email),
      ),
    );
    on<PasswordResetSubmitted>(
      (event, emit) => _run(
        emit,
        RecoveryStatus.resetSuccess,
        () => _repo.resetPassword(
          email: event.email,
          token: event.token,
          password: event.password,
        ),
      ),
    );
  }

  final AuthRepository _repo;

  Future<void> _run(
    Emitter<PasswordRecoveryState> emit,
    RecoveryStatus onSuccess,
    Future<void> Function() action,
  ) async {
    emit(const PasswordRecoveryState(status: RecoveryStatus.submitting));
    try {
      await action();
      emit(PasswordRecoveryState(status: onSuccess));
    } on Exception catch (error) {
      final failure = mapAuthFailure(error);
      emit(
        PasswordRecoveryState(
          status: RecoveryStatus.failure,
          errorMessage: failure.message,
          fieldErrors: failure.fieldErrors,
          networkError: failure.networkError,
        ),
      );
    }
  }
}
