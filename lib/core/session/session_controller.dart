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

/// Single source of truth for first-run routing: [bootstrap] runs on splash,
/// language/role/auth flows mutate it, and the router redirects off
/// [SessionState].
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

  /// How long a gate check may hold up launch before failing open — capped
  /// well under Dio's 15s timeout.
  static const _gateTimeout = Duration(seconds: 4);

  /// Shared shape for both role gates: `null` means "couldn't tell" (timeout
  /// or failure), which never gates — a flaky connection must not lock a
  /// user out.
  ///
  /// ponytail: hits the endpoint directly instead of `GarageRepo`/
  /// `BusinessOnboardingRepository` (`core/` can't depend on `features/`).
  Future<bool?> _gate(String path) => _api
      .get<bool>(path, parse: (data) => (data! as List<dynamic>).isNotEmpty)
      .then<bool?>((r) => r.data)
      .timeout(_gateTimeout, onTimeout: () => null)
      .catchError((_) => null);

  /// Whether an authenticated customer already has a car (vehicle gate);
  /// failing open just delays the gate to the next launch.
  Future<bool?> _resolveVehicleGate(AppRole? role, {required bool hasToken}) =>
      role == AppRole.customer && hasToken
      ? _gate(ApiEndpoints.vehicles)
      : Future.value();

  /// Whether an authenticated business owner has finished onboarding — the
  /// catalog itself is the completion record, so a non-empty catalog means
  /// the wizard ran.
  Future<bool?> _resolveCatalogGate(AppRole? role, {required bool hasToken}) =>
      role == AppRole.business && hasToken
      ? _gate(ApiEndpoints.businessServices)
      : Future.value();

  /// Reads persisted `{token, activeRole, locale}` and flips `bootstrapped`
  /// so the router leaves the splash; role gates are re-derived from the
  /// server here.
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

  /// Records the chooser pick and persists the role; with a live token the
  /// router lands the shell, otherwise auth sends `account_type`.
  Future<void> chooseRole(AppRole role) async {
    await _store.writeActiveRole(role);
    emit(
      state.copyWith(
        activeRole: role,
        roleAcknowledged: true,
        // Re-derive gates here — "switch role" clears them, and a stale null
        // would bypass the gate.
        businessOnboarded: await _resolveCatalogGate(
          role,
          hasToken: state.hasToken,
        ),
        hasVehicle: await _resolveVehicleGate(role, hasToken: state.hasToken),
      ),
    );
  }

  /// Called after register/login. [authoritativeRole] (`me.type`) overwrites
  /// [requested] if they differ, self-healing a wrong-shell choice and
  /// setting [SessionState.correctedRole] to drive the toast.
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
