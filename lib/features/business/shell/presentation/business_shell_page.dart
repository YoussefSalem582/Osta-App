import 'package:flutter/material.dart';
import 'package:osta/features/business/bookings/presentation/screens/bookings.dart';
import 'package:osta/features/business/dashboard/presentation/screens/board_screen.dart';
import 'package:osta/features/business/services/presentation/pages/business_services_page.dart';
import 'package:osta/features/shared/profile/presentation/profile/profile_page.dart';
import 'package:osta/features/shared/shell/presentation/role_shell.dart';
import 'package:osta/features/shop/presentation/pages/my_products_page.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';

/// Provider (business) shell — the landing surface for the `business` role.
/// Same UI as the customer shell (rounded bar + raised center action), but the
/// action is black and the tabs show the business's own screens.
class BusinessShellPage extends StatelessWidget {
  const BusinessShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RoleShell(
      // Center action: shows the provider bookings screen inside the shell so
      // the bottom nav stays (black, vs the customer's green map action).
      centerIcon: Icons.calendar_today_outlined,
      // ponytail: fixed brand color (black action); no token
      centerColor: Colors.black,
      centerBody: const Bookings(),
      centerLabel: l10n.reservation,
      tabs: [
        // Dashboard — the provider board (income, orders, live jobs).
        AppBottomNavItem(
          icon: Icons.grid_view_outlined,
          label: l10n.shellNavDashboard,
          body: const BoardScreen(),
        ),
        // Catalog & pricing — the business's own services screen.
        AppBottomNavItem(
          icon: Icons.local_offer_outlined,
          label: l10n.shellNavCatalog,
          body: const BusinessServicesPage(),
        ),
        // Store — the business's own shop (متجري): manage listings + browse.
        AppBottomNavItem(
          icon: Icons.shopping_bag_outlined,
          label: l10n.shellNavStore,
          body: const MyProductsPage(),
        ),
        // More — the shared account/profile surface (same as customer).
        AppBottomNavItem(
          icon: Icons.more_horiz,
          label: l10n.shellNavMore,
          body: const ProfileView(),
        ),
      ],
    );
  }
}
