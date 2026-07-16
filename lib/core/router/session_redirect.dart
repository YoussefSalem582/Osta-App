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
/// `null` to stay put. Order encodes the two role flows:
///
/// - Customer: language → role → customer onboarding → auth → shell
/// - Business: language → role → merchant onboarding → auth → wizard → shell
///
/// A valid `{token, activeRole}` skips straight to the shell (business
/// still hits the post-auth wizard until onboarded). No guest path.
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

  // Role-specific marketing carousel (logged-out). Customer → #37 slides;
  // business → merchant slides. Post-auth center setup stays in the wizard.
  if (!session.hasToken && !session.onboardingAcknowledged) {
    final intro = role == AppRole.business
        ? AppRoutes.merchantOnboarding
        : AppRoutes.onboarding;
    return location == intro ? null : intro;
  }

  // Role chosen but no token: pick login/register on the auth-choose landing,
  // then the auth form (sends `account_type = activeRole`). The
  // password-recovery screens hang off the same unauthenticated surface.
  if (!session.hasToken) {
    const authSurface = {
      AppRoutes.authChoose,
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
    };
    return authSurface.contains(location) ? null : AppRoutes.authChoose;
  }

  // Authenticated with a role: land in its shell, and allow the in-app screens
  // that hang off it (pushed over the shell, so they keep a back button).
  // Everything else — notably the other role's shell — bounces back to the
  // active shell.
  // ponytail: flat allow-list, not per-role. A business user could reach a
  // customer screen by typed URL, but no nav entry leads there; scope per role
  // if that ever matters.
  // A freshly-authenticated business user runs the onboarding wizard
  // (identity → catalog) before reaching its shell. Merchants already saw the
  // logged-out carousel before register, so there is no intro step here.
  // Gated by `businessOnboarded` (persisted after Activate so cold starts
  // skip a finished wizard).
  if (role == AppRole.business && !session.businessOnboarded) {
    const wizard = {
      AppRoutes.businessIdentity,
      AppRoutes.businessCatalog,
    };
    return wizard.contains(location) ? null : AppRoutes.businessIdentity;
  }

  const inAppScreens = {
    AppRoutes.profile,
    AppRoutes.garage,
    AppRoutes.addCar,
    AppRoutes.bookingStatus,
    AppRoutes.home,
    AppRoutes.technicians,
  };
  final shell = shellFor(role);
  if (location == shell || inAppScreens.contains(location)) return null;
  return shell;
}
