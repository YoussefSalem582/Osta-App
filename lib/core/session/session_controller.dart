import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/api_client.dart';
import 'package:osta/core/network/api_endpoints.dart';
import 'package:osta/core/network/dio_client.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_state.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:osta/features/shared/auth/domain/auth_repository.dart';

/// Single source of truth for first-run routing. The splash calls [bootstrap];
/// the language screen, role chooser and auth flow mutate it; the router
/// redirects on every emitted [SessionState]. Also listens for the networking
/// layer's session-expired signal and drops the token so the user is routed
/// back to auth.
///
/// Registered by hand in `configureDependencies()` — no injectable codegen.
class SessionController extends Cubit<SessionState> {
  SessionController(
    this._store,
    this._authEvents,
    this._authRepository,
    this._api,
  ) : super(const SessionState()) {
    _expiredSub = _authEvents.onSessionExpired.listen((_) => _onExpired());
  }

  final SessionStore _store;
  final AuthEvents _authEvents;
  final AuthRepository _authRepository;
  final ApiClient _api;
  late final StreamSubscription<void> _expiredSub;

  /// How long the gate check may hold up a launch before it gives up.
  ///
  /// [bootstrap] awaits this on the splash, on top of the branding hold, so an
  /// unbounded call would leave a user on a slow connection staring at the logo
  /// for Dio's full 15s timeout. Capped well under that and failed open.
  static const _vehicleGateTimeout = Duration(seconds: 4);

  /// Whether an authenticated customer already has a car, for the #39 gate.
  ///
  /// Returns `null` — "don't gate" — for anyone the gate doesn't apply to, and
  /// on any failure or timeout. Failing open is deliberate: a flaky connection
  /// must never lock a user out of the whole app. The cost is that a carless
  /// customer whose check times out skips the gate until their next launch.
  ///
  /// ponytail: calls the endpoint directly rather than reusing `GarageRepo`,
  /// which lives in `features/customer/` — `core/` must not depend on a
  /// feature. One `isNotEmpty` is not duplication worth inverting layers for.
  Future<bool?> _resolveVehicleGate(AppRole? role, {required bool hasToken}) {
    if (role != AppRole.customer || !hasToken) return Future.value();
    return _api
        .get<bool>(
          ApiEndpoints.vehicles,
          parse: (data) => (data! as List<dynamic>).isNotEmpty,
        )
        .then<bool?>((r) => r.data)
        .timeout(_vehicleGateTimeout, onTimeout: () => null)
        .catchError((_) => null);
  }

  /// Reads persisted `{token, activeRole, locale, businessOnboarded}` and flips
  /// `bootstrapped` so the router can leave the splash. A valid
  /// `{token, activeRole}` lands the user straight in their shell — the
  /// chooser never reappears. A completed business wizard is skipped on
  /// cold start via the persisted onboarded flag.
  Future<void> bootstrap() async {
    final code = _store.localeCode;
    final role = _store.activeRole;
    final hasToken = await _store.hasToken();
    emit(
      SessionState(
        bootstrapped: true,
        locale: code == null ? null : Locale(code),
        activeRole: role,
        hasToken: hasToken,
        businessOnboarded: _store.businessOnboarded,
        hasVehicle: await _resolveVehicleGate(role, hasToken: hasToken),
      ),
    );
  }

  /// Language pick. Persists the locale (so the app opens in it) and marks the
  /// in-memory `languageAcknowledged` flag so the guard advances — the screen
  /// still re-shows on the next logged-out cold start.
  Future<void> chooseLanguage(Locale locale) async {
    await _store.writeLocale(locale.languageCode);
    emit(state.copyWith(locale: locale, languageAcknowledged: true));
  }

  /// Records that the logged-out user finished onboarding this session, so the
  /// redirect guard lets them proceed to auth-choose. In-memory only — the next
  /// cold launch resets it and onboarding reappears.
  void acknowledgeOnboarding() {
    if (state.onboardingAcknowledged) return;
    emit(state.copyWith(onboardingAcknowledged: true));
  }

  /// Auth-choose back: clears the in-memory onboarding ack so the guard
  /// re-routes to the role-specific carousel (customer `/onboarding` or
  /// merchant `/onboarding/business`). Role + language stay.
  void resetOnboarding() {
    if (!state.onboardingAcknowledged) return;
    emit(state.copyWith(onboardingAcknowledged: false));
  }

  /// Records the chooser pick. Persists the role (the default next time) and
  /// marks the in-memory `roleAcknowledged` flag so the guard advances — the
  /// chooser still re-shows on the next logged-out cold start. With a live
  /// token the router lands the shell; otherwise auth sends `account_type`.
  Future<void> chooseRole(AppRole role) async {
    await _store.writeActiveRole(role);
    emit(
      state.copyWith(
        activeRole: role,
        roleAcknowledged: true,
        // "Switch role" keeps the token and clears hasVehicle, so re-derive it
        // here — otherwise a carless customer could switch away and back to
        // land in the shell with the gate still null, walking straight past it.
        hasVehicle: await _resolveVehicleGate(role, hasToken: state.hasToken),
      ),
    );
  }

  /// Called after a successful register/login. [authoritativeRole] is
  /// `me.type` — the server's source of truth — which overwrites the requested
  /// role, self-healing a wrong-shell choice. When it differs from [requested]
  /// a one-shot [SessionState.correctedRole] is set to drive the toast.
  Future<void> onAuthenticated(
    AppRole authoritativeRole, {
    required AppRole requested,
  }) async {
    await _store.writeActiveRole(authoritativeRole);
    emit(
      state.copyWith(
        activeRole: authoritativeRole,
        hasToken: true,
        correctedRole: authoritativeRole == requested
            ? null
            : authoritativeRole,
        // A fresh customer has no cars, so this resolves false and the gate
        // fires immediately after register — which is exactly #39's ask.
        hasVehicle: await _resolveVehicleGate(
          authoritativeRole,
          hasToken: true,
        ),
      ),
    );
  }

  /// Marks the customer's first car saved, releasing the #39 gate.
  Future<void> markVehicleAdded() async {
    if (state.hasVehicle ?? false) return;
    emit(state.copyWith(hasVehicle: true));
  }

  /// Marks the business onboarding wizard finished and persists the flag so
  /// the guard skips it on cold start. The guard then lets the user into the
  /// business shell.
  Future<void> completeBusinessOnboarding() async {
    if (state.businessOnboarded) return;
    await _store.writeBusinessOnboarded(value: true);
    emit(state.copyWith(businessOnboarded: true));
  }

  /// Clears the one-shot correction flag once the toast has been shown.
  void acknowledgeCorrection() {
    if (state.correctedRole == null) return;
    emit(state.copyWith());
  }

  /// "Switch role": clears the active role only (keeps the token) and returns
  /// the user to the chooser.
  Future<void> switchRole() async {
    await _store.clearActiveRole();
    emit(state.clearingRole(hasToken: state.hasToken));
  }

  /// Full sign-out: revokes the token server-side (best-effort) then drops the
  /// token and the active role locally.
  Future<void> signOut() async {
    await _authRepository.logout();
    await _store.clearSession();
    emit(state.clearingRole(hasToken: false));
  }

  void _onExpired() {
    if (!state.hasToken) return;
    emit(state.copyWith(hasToken: false));
  }

  @override
  Future<void> close() async {
    await _expiredSub.cancel();
    return super.close();
  }
}
