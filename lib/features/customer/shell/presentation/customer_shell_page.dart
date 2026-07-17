import 'package:flutter/material.dart';
import 'package:osta/features/customer/booking/presentation/pages/my_bookings_screen.dart';
import 'package:osta/features/customer/home/presentation/pages/home_page.dart';
import 'package:osta/features/customer/map/presentation/pages/map_screen.dart';
import 'package:osta/features/shared/profile/presentation/pages/profile_screen.dart';
import 'package:osta/features/shared/shell/presentation/role_shell.dart';
import 'package:osta/features/shop/presentation/pages/shop_browse_page.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';

/// Consumer (customer) shell — the landing surface for the `customer` role.
class CustomerShellPage extends StatelessWidget {
  const CustomerShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RoleShell(
      // Raised center action: find nearby service centers on the map, shown
      // full-screen inside the shell so the bottom nav stays reachable.
      centerIcon: Icons.location_on_outlined,
      centerBody: const MapScreen(),
      centerFullBleed: true,
      tabs: [
        AppBottomNavItem(
          icon: Icons.home_outlined,
          label: l10n.navHome,
          body: const HomePage(),
        ),
        AppBottomNavItem(
          icon: Icons.calendar_month_outlined,
          label: l10n.navBookings,
          body: const MyBookingsScreen(),
        ),
        // Store — the two-sided marketplace: browse, detail, enquire (#48).
        AppBottomNavItem(
          icon: Icons.shopping_bag_outlined,
          label: l10n.navStore,
          body: const ShopBrowsePage(),
        ),
        AppBottomNavItem(
          icon: Icons.more_horiz,
          label: l10n.navMore,
          body: const ProfileView(),
        ),
      ],
    );
  }
}
