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

/// Pure first-run/role-split routing: returns the redirect location, or `null`
/// to stay put. Order: language → role → onboarding → auth → (business:
/// wizard) → shell.
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
    // Pin to the active role's register screen — RegisterBloc reads
    // account_type from the session, so the other role's URL would show the
    // wrong heading.
    const registerRoutes = {AppRoutes.register, AppRoutes.registerBusiness};
    if (registerRoutes.contains(location)) {
      final ownRegister = role == AppRole.business
          ? AppRoutes.registerBusiness
          : AppRoutes.register;
      return location == ownRegister ? null : ownRegister;
    }

    const authSurface = {
      AppRoutes.authChoose,
      AppRoutes.login,
      AppRoutes.forgotPassword,
      AppRoutes.resetPassword,
    };
    return authSurface.contains(location) ? null : AppRoutes.authChoose;
  }

  // Authenticated: land in the role's shell, or an in-app screen pushed over
  // it. ponytail: flat allow-list, not scoped per role — no nav entry reaches
  // another role's screens.

  // Business runs the onboarding wizard first; gates on explicit `false` (not
  // `null`) so an unresolved check can't re-trigger a finished wizard.
  if (role == AppRole.business && session.businessOnboarded == false) {
    const wizard = {
      AppRoutes.businessIdentity,
      AppRoutes.businessCatalog,
    };
    return wizard.contains(location) ? null : AppRoutes.businessIdentity;
  }

  // The customer's counterpart to that wizard: no car, no Home (#39). Gates on
  // an explicit `false` only — `null` means the check never resolved, and a
  // failed network call must not strand the user outside the app.
  if (role == AppRole.customer && session.hasVehicle == false) {
    return location == AppRoutes.addCar ? null : AppRoutes.addCar;
  }

  const inAppScreens = {
    AppRoutes.profile,
    AppRoutes.editProfile,
    AppRoutes.garage,
    AppRoutes.addCar,
    AppRoutes.maintenance,
    AppRoutes.bookingStatus,
    AppRoutes.myBookings,
    AppRoutes.home,
    AppRoutes.technicians,
    // Shared account screens pushed off the More/profile tab.
    AppRoutes.notifications,
    AppRoutes.addresses,
    AppRoutes.businessProfile,
    AppRoutes.businessAddress,
    AppRoutes.businessCapacity,
    // Customer booking funnel: center profile → slot picker, pushed over the
    // map/shell so they keep a back button.
    AppRoutes.centerDetail,
    AppRoutes.bookingCreate,
    // Shop (#48) — pushed over either shell, so they keep a back button.
    AppRoutes.shopBrowse,
    AppRoutes.productDetail,
    AppRoutes.sellerCatalog,
    AppRoutes.myProducts,
    AppRoutes.productForm,
  };
  final shell = shellFor(role);
  if (location == shell || inAppScreens.contains(location)) return null;
  return shell;
}
