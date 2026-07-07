import 'package:go_router/go_router.dart';
import 'package:osta/features/role/presentation/page/role_selection_page.dart';
import 'package:osta/features/splash/presentation/splash_page.dart';

/// Declarative app router. Boots at splash, then the first-run role selection.
class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: RoleSelectionPage.path,
    routes: [
      GoRoute(
        path: SplashPage.path,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoleSelectionPage.path,
        builder: (context, state) => const RoleSelectionPage(),
      ),
    ],
  );
}
