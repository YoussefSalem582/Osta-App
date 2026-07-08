part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

/// The username field changed (debounced by the page). Triggers a live
/// availability check.
class UsernameChanged extends RegisterEvent {
  const UsernameChanged(this.username);

  final String username;

  @override
  List<Object?> get props => [username];
}

/// Submit the register form with the entered details.
class RegisterSubmitted extends RegisterEvent {
  const RegisterSubmitted({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.password,
    this.phone,
  });

  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String password;
  final String? phone;

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    username,
    email,
    password,
    phone,
  ];
}
