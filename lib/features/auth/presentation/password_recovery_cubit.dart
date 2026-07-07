import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/features/auth/domain/auth_repository.dart';

/// Where the recovery flow is: idle, in-flight, the request-link step succeeded
/// ([emailSent]), the reset step succeeded ([resetSuccess]), or it failed.
enum RecoveryStatus { idle, submitting, emailSent, resetSuccess, failure }

class PasswordRecoveryState extends Equatable {
  const PasswordRecoveryState({
    this.status = RecoveryStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
    this.networkError = false,
  });

  final RecoveryStatus status;
  final String? errorMessage;

  /// Server 422 field → messages, surfaced inline under the matching field.
  final Map<String, List<String>> fieldErrors;

  /// The failure was a transport/connection error (no reply from the server).
  final bool networkError;

  bool get isSubmitting => status == RecoveryStatus.submitting;

  @override
  List<Object?> get props => [status, errorMessage, fieldErrors, networkError];
}

/// Drives both password-recovery steps: request a reset link, then set a new
/// password with the emailed code. One class, provided fresh per screen.
///
/// Registered as a factory by hand in `configureDependencies()`.
class PasswordRecoveryCubit extends Cubit<PasswordRecoveryState> {
  PasswordRecoveryCubit(this._repo) : super(const PasswordRecoveryState());

  final AuthRepository _repo;

  /// `POST /forgot-password` — emails a reset link.
  Future<void> sendResetLink(String email) => _run(
    RecoveryStatus.emailSent,
    () => _repo.forgotPassword(email: email),
  );

  /// `POST /reset-password` — completes the reset with the emailed [token].
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) => _run(
    RecoveryStatus.resetSuccess,
    () => _repo.resetPassword(email: email, token: token, password: password),
  );

  Future<void> _run(
    RecoveryStatus onSuccess,
    Future<void> Function() action,
  ) async {
    emit(const PasswordRecoveryState(status: RecoveryStatus.submitting));
    try {
      await action();
      emit(PasswordRecoveryState(status: onSuccess));
    } on ValidationException catch (error) {
      emit(
        PasswordRecoveryState(
          status: RecoveryStatus.failure,
          errorMessage: error.message,
          fieldErrors: error.fieldErrors,
        ),
      );
    } on NetworkException {
      emit(
        const PasswordRecoveryState(
          status: RecoveryStatus.failure,
          networkError: true,
        ),
      );
    } on ApiException catch (error) {
      emit(
        PasswordRecoveryState(
          status: RecoveryStatus.failure,
          errorMessage: error.message,
        ),
      );
    }
  }
}
