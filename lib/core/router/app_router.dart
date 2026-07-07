import 'package:go_router/go_router.dart';
import 'package:osta/features/business/onboarding/presentation/pages/business_catalog_page.dart';
import 'package:osta/features/business/onboarding/presentation/pages/business_identity_page.dart';
import 'package:osta/features/business/onboarding/presentation/pages/provider_onboarding_page.dart';
import 'package:osta/features/role/presentation/page/role_selection_page.dart';
import 'package:osta/features/splash/presentation/splash_page.dart';

/// Declarative app router. Boots at splash, then the first-run role selection.
class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: ProviderOnboardingPage.path,
    routes: [
      GoRoute(
        path: SplashPage.path,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoleSelectionPage.path,
        builder: (context, state) => const RoleSelectionPage(),
      ),
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
        builder: (context, state) => const BusinessCatalogPage(),
      ),
    ],
  );
}
