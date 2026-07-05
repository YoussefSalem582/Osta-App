import 'package:go_router/go_router.dart';
import 'package:osta/features/role/presentation/role_selection_page.dart';
import 'package:osta/features/splash/presentation/splash_page.dart';
import 'package:osta/shared/ui/gallery/component_gallery_page.dart';

/// Declarative app router. Boots at splash, then the first-run role selection.
class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: SplashPage.path,
    routes: [
      GoRoute(
        path: SplashPage.path,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: RoleSelectionPage.path,
        builder: (context, state) => const RoleSelectionPage(),
      ),
      // Dev-facing component gallery (not linked from product UI).
      GoRoute(
        path: ComponentGalleryPage.path,
        builder: (context, state) => const ComponentGalleryPage(),
      ),
    ],
  );
}
