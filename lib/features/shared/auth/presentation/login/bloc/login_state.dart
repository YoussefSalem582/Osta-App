part of 'login_bloc.dart';

enum LoginStatus { idle, submitting, failure }

class LoginState extends Equatable {
  const LoginState({
    this.status = LoginStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
    this.networkError = false,
  });

  final LoginStatus status;
  final String? errorMessage;

  /// Server 422 field → messages, surfaced inline under the matching field.
  final Map<String, List<String>> fieldErrors;

  /// The failure was a transport error (no reply), so the UI can show a
  /// localized "can't reach server" message.
  final bool networkError;

  bool get isSubmitting => status == LoginStatus.submitting;

  @override
  List<Object?> get props => [status, errorMessage, fieldErrors, networkError];
}
