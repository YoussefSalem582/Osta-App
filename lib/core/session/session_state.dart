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
    this.onboardingAcknowledged = false,
    this.languageAcknowledged = false,
    this.roleAcknowledged = false,
    this.businessOnboarded,
    this.hasVehicle,
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

  /// In-memory only; resets to `false` every cold start, so logged-out users
  /// re-enter onboarding.
  final bool onboardingAcknowledged;

  /// Whether the logged-out user has picked a language this session. In-memory
  /// only, like [onboardingAcknowledged] — the persisted locale is the default,
  /// but the screen re-shows every logged-out cold start.
  final bool languageAcknowledged;

  /// In-memory only; re-shows every logged-out cold start, and is also forced
  /// whenever [activeRole] is null.
  final bool roleAcknowledged;

  /// Derived from a non-empty catalog. `null` means unknown; only an
  /// explicit `false` opens the wizard.
  final bool? businessOnboarded;

  /// `null` means unknown (logged out, business user, or a failed vehicle
  /// check); only explicit `false` gates.
  final bool? hasVehicle;

  bool get isLanguageSelected => locale != null;

  SessionState copyWith({
    bool? bootstrapped,
    Locale? locale,
    AppRole? activeRole,
    bool? hasToken,
    AppRole? correctedRole,
    bool? onboardingAcknowledged,
    bool? languageAcknowledged,
    bool? roleAcknowledged,
    bool? businessOnboarded,
    bool? hasVehicle,
  }) => SessionState(
    bootstrapped: bootstrapped ?? this.bootstrapped,
    locale: locale ?? this.locale,
    activeRole: activeRole ?? this.activeRole,
    hasToken: hasToken ?? this.hasToken,
    correctedRole: correctedRole,
    onboardingAcknowledged:
        onboardingAcknowledged ?? this.onboardingAcknowledged,
    languageAcknowledged: languageAcknowledged ?? this.languageAcknowledged,
    roleAcknowledged: roleAcknowledged ?? this.roleAcknowledged,
    businessOnboarded: businessOnboarded ?? this.businessOnboarded,
    hasVehicle: hasVehicle ?? this.hasVehicle,
  );

  /// Copy that nulls [activeRole] (`copyWith` can't); used by "switch role"
  /// and sign-out. Preserves in-memory acks.
  SessionState clearingRole({required bool hasToken}) => SessionState(
    bootstrapped: bootstrapped,
    locale: locale,
    hasToken: hasToken,
    onboardingAcknowledged: onboardingAcknowledged,
    languageAcknowledged: languageAcknowledged,
    roleAcknowledged: roleAcknowledged,
  );

  @override
  List<Object?> get props => [
    bootstrapped,
    locale,
    activeRole,
    hasToken,
    correctedRole,
    onboardingAcknowledged,
    languageAcknowledged,
    roleAcknowledged,
    businessOnboarded,
    hasVehicle,
  ];
}
