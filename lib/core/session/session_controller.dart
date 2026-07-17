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

  /// How long a gate check may hold up a launch before it gives up.
  ///
  /// [bootstrap] awaits this on the splash, on top of the branding hold, so an
  /// unbounded call would leave a user on a slow connection staring at the logo
  /// for Dio's full 15s timeout. Capped well under that and failed open.
  static const _gateTimeout = Duration(seconds: 4);

  /// Both role gates ask the same question — "does this list have anything in
  /// it?" — so they share one call shape. `null` means "couldn't tell": a
  /// failure or a timeout never gates, because a flaky connection must not lock
  /// a user out of the whole app.
  ///
  /// ponytail: calls the endpoints directly rather than reusing `GarageRepo` /
  /// `BusinessOnboardingRepository`, which live in `features/` — `core/` must
  /// not depend on a feature. One `isNotEmpty` is not duplication worth
  /// inverting layers for.
  Future<bool?> _gate(String path) => _api
      .get<bool>(path, parse: (data) => (data! as List<dynamic>).isNotEmpty)
      .then<bool?>((r) => r.data)
      .timeout(_gateTimeout, onTimeout: () => null)
      .catchError((_) => null);

  /// Whether an authenticated customer already has a car, for the #39 gate.
  ///
  /// The cost of failing open is that a carless customer whose check times out
  /// skips the gate until their next launch.
  Future<bool?> _resolveVehicleGate(AppRole? role, {required bool hasToken}) =>
      role == AppRole.customer && hasToken
      ? _gate(ApiEndpoints.vehicles)
      : Future.value();

  /// Whether an authenticated business owner has finished onboarding (#53).
  ///
  /// The catalog *is* the completion record: the wizard cannot finish without
  /// attaching at least one service, so a non-empty catalog means it ran.
  /// Asking the server rather than a local flag is what lets a returning owner
  /// — new device, reinstall, or just a sign-out — skip a wizard they already
  /// did instead of re-running it and duplicating their catalog.
  Future<bool?> _resolveCatalogGate(AppRole? role, {required bool hasToken}) =>
      role == AppRole.business && hasToken
      ? _gate(ApiEndpoints.businessServices)
      : Future.value();

  /// Reads persisted `{token, activeRole, locale}` and flips `bootstrapped` so
  /// the router can leave the splash. A valid `{token, activeRole}` lands the
  /// user straight in their shell — the chooser never reappears. Both role
  /// gates are re-derived from the server here; they are mutually exclusive by
  /// role, so only one ever hits the network.
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
        businessOnboarded: await _resolveCatalogGate(role, hasToken: hasToken),
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
        // "Switch role" keeps the token and clears both gates, so re-derive
        // them here — otherwise a carless customer could switch away and back
        // to land in the shell with the gate still null, walking straight past
        // it.
        businessOnboarded: await _resolveCatalogGate(
          role,
          hasToken: state.hasToken,
        ),
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
        // A fresh business owner has an empty catalog, so this resolves false
        // and the wizard runs; a returning one resolves true and skips it.
        businessOnboarded: await _resolveCatalogGate(
          authoritativeRole,
          hasToken: true,
        ),
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

  /// Marks the wizard finished, releasing the #53 gate — the business twin of
  /// [markVehicleAdded]. In-memory only: Activate has just written the catalog
  /// server-side, so the next cold start re-derives this from it.
  Future<void> completeBusinessOnboarding() async {
    if (state.businessOnboarded ?? false) return;
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
