import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/network/auth_events.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_state.dart';
import 'package:osta/core/session/session_store.dart';

/// Single source of truth for first-run routing. The splash calls [bootstrap];
/// the language screen, role chooser and auth flow mutate it; the router
/// redirects on every emitted [SessionState]. Also listens for the networking
/// layer's session-expired signal and drops the token so the user is routed
/// back to auth.
///
/// Registered by hand in `configureDependencies()` — no injectable codegen.
class SessionController extends Cubit<SessionState> {
  SessionController(this._store, this._authEvents)
    : super(const SessionState()) {
    _expiredSub = _authEvents.onSessionExpired.listen((_) => _onExpired());
  }

  final SessionStore _store;
  final AuthEvents _authEvents;
  late final StreamSubscription<void> _expiredSub;

  /// Reads persisted `{token, activeRole, locale}` and flips `bootstrapped` so
  /// the router can leave the splash. A valid `{token, activeRole}` lands the
  /// user straight in their shell — the chooser never reappears.
  Future<void> bootstrap() async {
    final code = _store.localeCode;
    emit(
      SessionState(
        bootstrapped: true,
        locale: code == null ? null : Locale(code),
        activeRole: _store.activeRole,
        hasToken: await _store.hasToken(),
      ),
    );
  }

  /// First-run language pick (persisted, one time only).
  Future<void> chooseLanguage(Locale locale) async {
    await _store.writeLocale(locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  /// Records the chooser pick. With a live token the router lands the shell
  /// directly; otherwise it routes to auth, which sends this as `account_type`.
  Future<void> chooseRole(AppRole role) async {
    await _store.writeActiveRole(role);
    emit(state.copyWith(activeRole: role));
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
      ),
    );
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

  /// Full sign-out: drops the token and the active role.
  Future<void> signOut() async {
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
