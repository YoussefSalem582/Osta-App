import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:osta/core/session/app_role.dart';

/// Immutable snapshot the router redirects on. Everything routing needs —
/// whether boot finished, the chosen locale, the active role, and whether a
/// token is held — lives here so the redirect stays a pure function of state.
class SessionState extends Equatable {
  const SessionState({
    this.bootstrapped = false,
    this.locale,
    this.activeRole,
    this.hasToken = false,
    this.correctedRole,
  });

  /// `false` until the splash finishes reading persisted `{token, activeRole}`.
  final bool bootstrapped;

  /// Chosen UI language, or `null` on a true first run (gates the language
  /// screen).
  final Locale? locale;

  /// Role the user is acting as, or `null` when the chooser owes a pick.
  final AppRole? activeRole;

  /// Whether a Sanctum token is held.
  final bool hasToken;

  /// Set for one frame when login healed a wrong-shell choice: the role from
  /// `me.type`. Drives the "switched you to …" toast, then cleared.
  final AppRole? correctedRole;

  bool get isLanguageSelected => locale != null;

  SessionState copyWith({
    bool? bootstrapped,
    Locale? locale,
    AppRole? activeRole,
    bool? hasToken,
    AppRole? correctedRole,
  }) => SessionState(
    bootstrapped: bootstrapped ?? this.bootstrapped,
    locale: locale ?? this.locale,
    activeRole: activeRole ?? this.activeRole,
    hasToken: hasToken ?? this.hasToken,
    correctedRole: correctedRole,
  );

  /// Copy that can null out [activeRole] — `copyWith` can't express "set to
  /// null" (used by "switch role" and sign-out).
  SessionState clearingRole({required bool hasToken}) => SessionState(
    bootstrapped: bootstrapped,
    locale: locale,
    hasToken: hasToken,
  );

  @override
  List<Object?> get props => [
    bootstrapped,
    locale,
    activeRole,
    hasToken,
    correctedRole,
  ];
}
