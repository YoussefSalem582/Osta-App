import 'package:flutter/material.dart';
import 'package:osta/features/customer/booking/presentation/real_time_booking_screen.dart';
import 'package:osta/features/customer/profile/presentation/profile_screen.dart';
import 'package:osta/features/shell/presentation/role_shell.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';
import 'package:osta/shared/ui/app_toaster.dart';

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
    );
  }
}
