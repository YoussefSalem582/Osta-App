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
/// splash → language → role chooser → onboarding → auth-choose → auth → shell.
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

  // Language pick: shown every launch while logged out until picked this
  // session. In-memory (the persisted locale is the default); a held token
  // skips it.
  if (!session.hasToken && !session.languageAcknowledged) {
    return location == AppRoutes.language ? null : AppRoutes.language;
  }

  final role = session.activeRole;

  // Role chooser: shown every launch while logged out until picked this session
  // (in-memory ack; the persisted role is the default), and always forced when
  // no role is set (fresh, or just after "switch role").
  if ((!session.hasToken && !session.roleAcknowledged) || role == null) {
    return location == AppRoutes.role ? null : AppRoutes.role;
  }

  // Logged-out intro: shown every launch until acknowledged this session. The
  // flag is in-memory, so a not-logged-in user re-enters onboarding each cold
  // start; once tapped through it stays set and the steps below are reachable.
  if (!session.hasToken && !session.onboardingAcknowledged) {
    return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
  }

  // Role chosen but no token: pick login/register on the auth-choose landing,
  // then the auth form (sends `account_type = activeRole`). The
  // password-recovery screens hang off the same unauthenticated surface.
  if (!session.hasToken) {
    const authSurface = {
      AppRoutes.authChoose,
      AppRoutes.auth,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
    };
    return authSurface.contains(location) ? null : AppRoutes.authChoose;
  }

  // Authenticated with a role: land in — and stay pinned to — its shell.
  final shell = shellFor(role);
  return location == shell ? null : shell;
}
