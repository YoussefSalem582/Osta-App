part of 'register_bloc.dart';

enum RegisterStatus { idle, submitting, failure }

/// Live username availability: not yet checked / errored ([unknown]), request
/// in flight ([checking]), free ([available]), or already taken ([taken]).
enum UsernameStatus { unknown, checking, available, taken }

class RegisterState extends Equatable {
  const RegisterState({
    this.status = RegisterStatus.idle,
    this.errorMessage,
    this.fieldErrors = const {},
    this.networkError = false,
    this.usernameStatus = UsernameStatus.unknown,
    this.checkedUsername = '',
  });

  final RegisterStatus status;
  final String? errorMessage;

  /// Server 422 field → messages, surfaced inline under the matching field.
  final Map<String, List<String>> fieldErrors;

  /// The failure was a transport error (no reply from the server).
  final bool networkError;

  /// Result of the live availability check for [checkedUsername].
  final UsernameStatus usernameStatus;

  /// The username [usernameStatus] refers to — the page shows the marker only
  /// when this still matches the field text (stale-guard).
  final String checkedUsername;

  bool get isSubmitting => status == RegisterStatus.submitting;

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
    bool? networkError,
    UsernameStatus? usernameStatus,
    String? checkedUsername,
  }) => RegisterState(
    status: status ?? this.status,
    errorMessage: errorMessage ?? this.errorMessage,
    fieldErrors: fieldErrors ?? this.fieldErrors,
    networkError: networkError ?? this.networkError,
    usernameStatus: usernameStatus ?? this.usernameStatus,
    checkedUsername: checkedUsername ?? this.checkedUsername,
  );

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    fieldErrors,
    networkError,
    usernameStatus,
    checkedUsername,
  ];
}
