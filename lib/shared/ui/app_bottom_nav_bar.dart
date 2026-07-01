import 'package:flutter/material.dart';

/// One tab of [AppBottomNavBar]. `badgeCount > 0` shows an unread badge
/// (notifications, pending bookings, …).
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int badgeCount;
}

/// Brand bottom navigation — Material 3 [NavigationBar] wrapper shared by the
/// customer and provider shells. RTL ordering is handled by the framework.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    super.key,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onChanged,
      destinations: [
        for (final item in items)
          NavigationDestination(
            icon: _badged(Icon(item.icon), item.badgeCount),
            selectedIcon: item.selectedIcon == null
                ? null
                : _badged(Icon(item.selectedIcon), item.badgeCount),
            label: item.label,
          ),
      ],
    );
  }

  Widget _badged(Widget icon, int count) =>
      count > 0 ? Badge.count(count: count, child: icon) : icon;
}
