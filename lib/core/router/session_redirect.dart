import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_state.dart';

/// The shell a role lands in. Live roles get their own shell; the "coming soon"
/// roles fall back to a placeholder (only reachable defensively — they can't be
/// picked in the chooser).
String shellFor(AppRole role) => switch (role) {
  AppRole.customer => AppRoutes.customerShell,
  AppRole.business => AppRoutes.businessShell,
  AppRole.mechanic || AppRole.tow => AppRoutes.comingSoon,
};

/// Pure first-run/role-split routing. Returns the location to redirect to, or
/// `null` to stay put. Order encodes the flow:
///
/// splash → language → role chooser → auth (`account_type`) → shell.
/// A valid `{token, activeRole}` skips straight to the shell; no route is
/// reachable without auth (no guest path).
String? resolveRedirect({
  required SessionState session,
  required String location,
}) {
  // Hold on the splash until persisted state has been read.
  if (!session.bootstrapped) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  // First run: choose a language, once.
  if (!session.isLanguageSelected) {
    return location == AppRoutes.language ? null : AppRoutes.language;
  }

  final role = session.activeRole;

  // No role yet (fresh, or just after "switch role"): the chooser.
  if (role == null) {
    return location == AppRoutes.role ? null : AppRoutes.role;
  }

  // Role chosen but no token: authenticate (sends `account_type = activeRole`).
  if (!session.hasToken) {
    return location == AppRoutes.auth ? null : AppRoutes.auth;
  }

  // Authenticated with a role: land in — and stay pinned to — its shell.
  final shell = shellFor(role);
  return location == shell ? null : shell;
}
