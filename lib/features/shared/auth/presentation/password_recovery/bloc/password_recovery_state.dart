part of 'password_recovery_bloc.dart';

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

  /// The failure was a transport error (no reply from the server).
  final bool networkError;

  bool get isSubmitting => status == RecoveryStatus.submitting;

  @override
  List<Object?> get props => [status, errorMessage, fieldErrors, networkError];
}
