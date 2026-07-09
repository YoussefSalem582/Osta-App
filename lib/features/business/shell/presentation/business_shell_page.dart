import 'package:flutter/material.dart';
import 'package:osta/features/business/services/presentation/pages/business_services_page.dart';
import 'package:osta/features/shell/presentation/role_shell.dart';
import 'package:osta/features/shop/presentation/pages/business_shop_page.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';
import 'package:osta/shared/ui/app_toaster.dart';

/// Provider (business) shell — the landing surface for the `business` role.
/// Same UI as the customer shell (rounded bar + raised center action), but the
/// action is black and the tabs show the business's own screens.
class BusinessShellPage extends StatelessWidget {
  const BusinessShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RoleShell(
      // Center action: the provider booking calendar (black, vs the customer's
      // green map action).
      centerIcon: Icons.calendar_today_outlined,
      centerColor: Colors.black,
      onCenterTap: () => AppToaster.showMessage(l10n.comingSoonBody),
      tabs: [
        // Dashboard — placeholder until the provider dashboard is built.
        AppBottomNavItem(
          icon: Icons.grid_view_outlined,
          label: l10n.shellNavDashboard,
        ),
        // Catalog & pricing — the business's own services screen.
        AppBottomNavItem(
          icon: Icons.local_offer_outlined,
          label: l10n.shellNavCatalog,
          body: const BusinessServicesPage(),
        ),
        // Store — the business's own shop screen.
        AppBottomNavItem(
          icon: Icons.shopping_bag_outlined,
          label: l10n.shellNavStore,
          body: const BusinessShopPage(),
        ),
        // More — placeholder until the provider profile is built.
        AppBottomNavItem(
          icon: Icons.more_horiz,
          label: l10n.shellNavMore,
        ),
      ],
    );
  }
}
