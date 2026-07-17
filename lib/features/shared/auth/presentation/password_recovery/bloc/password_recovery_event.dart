part of 'password_recovery_bloc.dart';

sealed class PasswordRecoveryEvent extends Equatable {
  const PasswordRecoveryEvent();

  @override
  List<Object?> get props => [];
}

/// Step 1: email a reset link.
class ResetLinkRequested extends PasswordRecoveryEvent {
  const ResetLinkRequested(this.email);

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Step 2: complete the reset with the emailed [token] and a new [password].
class PasswordResetSubmitted extends PasswordRecoveryEvent {
  const PasswordResetSubmitted({
    required this.email,
    required this.token,
    required this.password,
  });

  final String email;
  final String token;
  final String password;

  @override
  List<Object?> get props => [email, token, password];
}
