import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/routes.dart';
import 'package:osta/features/business/bookings/presentation/screens/bookings.dart';
import 'package:osta/features/business/dashboard/presentation/screens/board_screen.dart';
import 'package:osta/features/business/dashboard/presentation/screens/catalog_screen.dart';
import 'package:osta/features/business/dashboard/presentation/screens/home_screen.dart';
import 'package:osta/features/business/dashboard/presentation/screens/more_screen.dart';
import 'package:osta/features/business/dashboard/presentation/screens/store_screen.dart';
import 'package:osta/features/business/dashboard/presentation/screens/techScreen.dart';
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
import 'package:osta/features/business/shell/presentation/business_shell_page.dart';
import 'package:osta/features/customer/booking/presentation/pages/live_booking_screen.dart';
import 'package:osta/features/customer/booking/presentation/pages/my_bookings_screen.dart';
import 'package:osta/features/customer/garage/presentation/pages/add_car_screen.dart';
import 'package:osta/features/customer/garage/presentation/pages/my_garage_screen.dart';
import 'package:osta/features/customer/profile/presentation/pages/profile_screen.dart';
import 'package:osta/features/customer/shell/presentation/customer_shell_page.dart';
import 'package:osta/features/home/presentation/pages/home_page.dart';
import 'package:osta/features/onboarding/presentation/language_page.dart';
import 'package:osta/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:osta/features/role/presentation/coming_soon_page.dart';
import 'package:osta/features/role/presentation/page/role_selection_page.dart';
import 'package:osta/features/splash/presentation/splash_page.dart';

/// Declarative app router. Boots at the splash and defers all navigation to a
/// single [resolveRedirect] guard keyed on the [SessionController] state, so
/// the first-run/role-split flow lives in one pure, tested place.
///
/// Registered by hand in `configureDependencies()` — no injectable codegen.
class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: SplashPage.path,
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
          // Wizard done: mark onboarding complete, then land in the shell.
          // (The redirect guard bounces to the shell once the flag flips.)
          onActivate: () {
            context.read<SessionController>().completeBusinessOnboarding();
            context.go(AppRoutes.businessShell);
          },
        ),
      ),

      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => const LanguagePage(),
      ),
      GoRoute(
        path: RoleSelectionPage.path,
        builder: (context, state) => const RoleSelectionPage(),
      ),
    ],
  );
}
