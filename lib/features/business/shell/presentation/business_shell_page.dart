import 'package:flutter/material.dart';
import 'package:osta/features/shell/presentation/role_shell.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';

/// Provider (business) shell — the landing surface for the `business` role.
class BusinessShellPage extends StatelessWidget {
  const BusinessShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return RoleShell(
      title: l10n.businessHomeTitle,
      tabs: [
        AppBottomNavItem(icon: Icons.dashboard_outlined, label: l10n.navHome),
        AppBottomNavItem(
          icon: Icons.calendar_month_outlined,
          label: l10n.navBookings,
        ),
        AppBottomNavItem(icon: Icons.person_outline, label: l10n.navProfile),
      ],
    );
  }
}
