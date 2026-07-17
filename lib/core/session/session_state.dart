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

  /// Whether the logged-out user has tapped through onboarding this session.
  /// In-memory only (never persisted): a fresh [SessionState] on each launch —
  /// via `bootstrap`/`clearingRole` — resets it to `false`, so a not-logged-in
  /// user re-enters onboarding every cold start (see the redirect guard).
  final bool onboardingAcknowledged;

  /// Whether the logged-out user has picked a language this session. In-memory
  /// only, like [onboardingAcknowledged] — the persisted locale is the default,
  /// but the screen re-shows every logged-out cold start.
  final bool languageAcknowledged;

  /// Whether the logged-out user has picked a role this session. In-memory
  /// only — the persisted [activeRole] is the default, but the chooser re-shows
  /// every logged-out cold start (the guard also forces it whenever
  /// [activeRole] is null, e.g. after "switch role").
  final bool roleAcknowledged;

  /// Whether an authenticated `business` user has finished the onboarding
  /// wizard (#53) — derived from their catalog being non-empty, since the
  /// wizard cannot finish without attaching a service.
  ///
  /// Tri-state on the same terms as [hasVehicle]: `null` means "not known /
  /// not applicable", and only an explicit `false` opens the wizard, so a
  /// failed check can never trap an onboarded owner in it again.
  final bool? businessOnboarded;

  /// Whether an authenticated `customer` has at least one vehicle — the gate
  /// behind the required add-car step (#39).
  ///
  /// Tri-state on purpose. `null` means "not known / not applicable": a
  /// logged-out user, a business user, or a customer whose `GET /vehicles`
  /// check could not be completed. Only an explicit `false` gates, so a network
  /// failure can never strand someone outside the app.
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

  /// Copy that can null out [activeRole] — `copyWith` can't express "set to
  /// null" (used by "switch role" and sign-out). Preserves the in-memory
  /// language/onboarding/role acks so clearing the role mid-session doesn't
  /// re-trigger those screens (a fresh cold `bootstrap` resets them anyway).
  /// Both role gates drop to `null` with the role that scoped them —
  /// `chooseRole` re-derives whichever one the new role needs.
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
