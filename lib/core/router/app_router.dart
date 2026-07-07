import 'package:go_router/go_router.dart';
import 'package:osta/features/customer/booking/presentation/real_time_booking_screen.dart';
import 'package:osta/features/customer/garage/presentation/add_car_screen.dart';
import 'package:osta/features/customer/garage/presentation/my_garage_screen.dart';
import 'package:osta/features/customer/profile/presentation/profile_screen.dart';
import 'package:osta/features/role/presentation/role_selection_page.dart';
import 'package:osta/features/splash/presentation/splash_page.dart';

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
      GoRoute(
        path: MyGarageScreen.path,
        builder: (context, state) => const MyGarageScreen(),
      ),
      GoRoute(
        path: AddCarScreen.path,
        builder: (context, state) => const AddCarScreen(),
      ),
      GoRoute(
        path: RealTimeBookingScreen.path,
        builder: (context, state) => const RealTimeBookingScreen(),
      ),
      GoRoute(
        path: ProfileScreen.path,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
