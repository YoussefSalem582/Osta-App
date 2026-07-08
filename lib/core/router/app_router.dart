import 'package:go_router/go_router.dart';

/// Declarative app router.

import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/router/go_router_refresh_stream.dart';
import 'package:osta/core/router/session_redirect.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/features/auth/choose/presentation/auth_choose_page.dart';
import 'package:osta/features/auth/login/presentation/login_page.dart';
import 'package:osta/features/auth/password_recovery/presentation/forgot_password_page.dart';
import 'package:osta/features/auth/password_recovery/presentation/reset_password_page.dart';
import 'package:osta/features/auth/register/presentation/register_page.dart';
import 'package:osta/features/business/onboarding/presentation/pages/business_catalog_page.dart';
import 'package:osta/features/business/onboarding/presentation/pages/business_identity_page.dart';
import 'package:osta/features/business/onboarding/presentation/pages/provider_onboarding_page.dart';
import 'package:osta/features/business/services/presentation/pages/business_services_page.dart';
import 'package:osta/features/business/shell/presentation/business_shell_page.dart';
import 'package:osta/features/customer/booking/presentation/real_time_booking_screen.dart';
import 'package:osta/features/customer/garage/presentation/add_car_screen.dart';
import 'package:osta/features/customer/garage/presentation/my_garage_screen.dart';
import 'package:osta/features/customer/profile/presentation/profile_screen.dart';
import 'package:osta/features/customer/shell/presentation/customer_shell_page.dart';
import 'package:osta/features/onboarding/page/onboarding_page.dart';
import 'package:osta/features/onboarding/presentation/language_page.dart';
import 'package:osta/features/role/presentation/coming_soon_page.dart';
import 'package:osta/features/role/presentation/role_chooser_page.dart';
import 'package:osta/features/shop/presentation/pages/business_shop_page.dart';
import 'package:osta/features/splash/presentation/splash_page.dart';

/// Declarative app router. Boots at the splash and defers all navigation to a
/// single [resolveRedirect] guard keyed on the [SessionController] state, so
/// the first-run/role-split flow lives in one pure, tested place.
///
/// Registered by hand in `configureDependencies()` — no injectable codegen.
class AppRouter {
  AppRouter(SessionController session) : router = _build(session);

  final GoRouter router;

  static GoRouter _build(SessionController session) => GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: GoRouterRefreshStream(session.stream),
    redirect: (context, state) => resolveRedirect(
      session: session.state,
      location: state.matchedLocation,
    ),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // Business (provider) onboarding + catalog/services/shop flow.
      GoRoute(
        path: ProviderOnboardingPage.path,
        builder: (context, state) => ProviderOnboardingPage(
          onNext: () => context.push(BusinessIdentityPage.path),
          onSkip: () => context.push(BusinessCatalogPage.path),
        ),
      ),
      GoRoute(
        path: BusinessIdentityPage.path,
        builder: (context, state) => BusinessIdentityPage(
          onContinue: () => context.push(BusinessCatalogPage.path),
        ),
      ),
      GoRoute(
        path: BusinessCatalogPage.path,
        builder: (context, state) => BusinessCatalogPage(
          onActivate: () => context.go(BusinessServicesPage.path),
        ),
      ),
      GoRoute(
        path: BusinessServicesPage.path,
        builder: (context, state) => const BusinessServicesPage(),
      ),
      GoRoute(
        path: BusinessShopPage.path,
        builder: (context, state) => const BusinessShopPage(),
      ),

      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => const LanguagePage(),
      ),
      GoRoute(
        path: AppRoutes.role,
        builder: (context, state) => const RoleChooserPage(),
      ),
      GoRoute(
        path: AppRoutes.authChoose,
        builder: (context, state) => const AuthChoosePage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) => ResetPasswordPage(
          email: state.uri.queryParameters['email'],
          token: state.uri.queryParameters['token'],
        ),
      ),
      GoRoute(
        path: AppRoutes.customerShell,
        builder: (context, state) => const CustomerShellPage(),
      ),
      GoRoute(
        path: AppRoutes.businessShell,
        builder: (context, state) => const BusinessShellPage(),
      ),
      GoRoute(
        path: AppRoutes.comingSoon,
        builder: (context, state) => const ComingSoonPage(),
      ),
      GoRoute(
        path: AppRoutes.garage,
        builder: (context, state) => const MyGarageScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCar,
        builder: (context, state) => const AddCarScreen(),
      ),
      GoRoute(
        path: AppRoutes.bookingStatus,
        builder: (context, state) => const RealTimeBookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),

      // Dev-facing component gallery (not linked from product UI).
      // GoRoute(
      //   path: ComponentGalleryPage.path,
      //   builder: (context, state) => const ComponentGalleryPage(),
      // ),
    ],
  );
}
