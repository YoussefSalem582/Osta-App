import 'package:flutter/material.dart';
// <<<<<<< HEAD
// import 'package:osta/features/customer/booking/presentation/my_bookings_screen.dart';
// =======
import 'package:osta/features/customer/booking/presentation/real_time_booking_screen.dart';
// >>>>>>> 05dd7eefce8d3884570b01b7e0b4d8e0d864abad
import 'package:osta/features/customer/profile/presentation/profile_screen.dart';
import 'package:osta/features/shell/presentation/role_shell.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Consumer (customer) shell — the landing surface for the `customer` role.
class CustomerShellPage extends StatelessWidget {
  const CustomerShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RoleShell(
      // Raised center action: find nearby service centers on the map.
      centerIcon: Icons.location_on_outlined,
      onCenterTap: () => AppToaster.showMessage(l10n.comingSoonBody),
      tabs: [
        AppBottomNavItem(icon: Icons.home_outlined, label: l10n.navHome),
        AppBottomNavItem(
          icon: Icons.calendar_month_outlined,
          label: l10n.navBookings,
          body: const BookingView(),
        ),
        AppBottomNavItem(
          icon: Icons.shopping_bag_outlined,
          label: l10n.navStore,
        ),
        AppBottomNavItem(
          icon: Icons.more_horiz,
          label: l10n.navMore,
          body: const ProfileView(),
        ),
      ],
      pages: [
        // Index 0 — Home (placeholder until the Home screen is built)
        EmptyState(
          icon: Icons.home_outlined,
          title: l10n.navHome,
          message: l10n.shellWelcome,
        ),
        // Index 1 — Bookings
        const BookingView(),
        // Index 2 — Store (placeholder)
        EmptyState(
          icon: Icons.shopping_bag_outlined,
          title: l10n.navStore,
          message: l10n.shellWelcome,
        ),
        // Index 3 — More → Profile Screen
        const ProfileScreen(),
      ],
    );
  }
}
