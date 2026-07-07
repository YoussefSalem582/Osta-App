import 'package:go_router/go_router.dart';
import 'package:osta/features/onboarding/page/onboarding_page.dart';
import 'package:osta/features/role/presentation/role_selection_page.dart';
import 'package:osta/features/splash/presentation/splash_page.dart';

/// Declarative app router.

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: SplashPage.path,
    routes: [
      GoRoute(
        path: SplashPage.path,
        builder: (context, state) => const SplashPage(),
      ),

      GoRoute(
        path: OnboardingPage.path,
        builder: (context, state) => const OnboardingPage(),
      ),

      GoRoute(
        path: RoleSelectionPage.path,
        builder: (context, state) => const RoleSelectionPage(),
      ),

      // Dev-facing component gallery (not linked from product UI).
      // GoRoute(
      //   path: ComponentGalleryPage.path,
      //   builder: (context, state) => const ComponentGalleryPage(),
      // ),
    ],
  );
}
