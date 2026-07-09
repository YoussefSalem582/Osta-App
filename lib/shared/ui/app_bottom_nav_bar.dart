import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';

const double _kBarHeight = 64;
const double _kFabSize = 64;
const double _kFabProtrusion = 24; // how far the FAB rises above the bar top
const double _kFabSlot = 76; // horizontal gap the tabs leave for the FAB

/// One tab of [AppBottomNavBar]. `badgeCount > 0` shows an unread badge
/// (notifications, pending bookings, …).
class AppBottomNavItem {
  const AppBottomNavItem({
    required this.icon,
    required this.label,
    this.selectedIcon,
    this.badgeCount = 0,
    this.onTap,
    this.body,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final int badgeCount;

  /// When set, tapping the tab runs this instead of selecting it — for tabs
  /// that navigate to a pushed screen rather than swap the shell body.
  final VoidCallback? onTap;

  /// When set, selecting the tab shows this as the shell body (bottom nav
  /// stays) instead of the default placeholder.
  final Widget? body;
}

/// Brand bottom navigation — a rounded, elevated bar with icon + label tabs and
/// an optional raised circular center action (e.g. a map / location button)
/// that protrudes above the bar. Shared by the customer and provider shells;
/// RTL ordering is handled by the framework.
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    required this.items,
    required this.currentIndex,
    required this.onChanged,
    this.centerIcon,
    this.onCenterTap,
    this.centerColor,
    super.key,
  });

  final List<AppBottomNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  /// Raised circular action in the middle of the bar. Rendered only when both
  /// [centerIcon] and [onCenterTap] are set; it's an action, not a tab, so it
  /// never changes [currentIndex].
  final IconData? centerIcon;
  final VoidCallback? onCenterTap;

  /// Fill colour of the center action; defaults to the brand green.
  final Color? centerColor;

  bool get _hasCenter => centerIcon != null && onCenterTap != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // With a center action, split the tabs around the FAB slot.
    final split = _hasCenter ? (items.length / 2).ceil() : items.length;

    List<Widget> tabs(int start, int end) => [
      for (var i = start; i < end; i++)
        Expanded(
          child: _NavTab(
            item: items[i],
            selected: i == currentIndex,
            onTap: () => onChanged(i),
          ),
        ),
    ];

    // SafeArea lives INSIDE the Material so the surface paints through the
    // home-indicator inset — otherwise a gap shows below the bar.
    final bar = Material(
      color: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent, // keep a flat surface, no M3 tint
      elevation: AppElevation.high,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.lg)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _kBarHeight,
          child: Row(
            children: [
              ...tabs(0, split),
              if (_hasCenter) const SizedBox(width: _kFabSlot),
              if (_hasCenter) ...tabs(split, items.length),
            ],
          ),
        ),
      ),
    );

    if (!_hasCenter) return bar;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Reserve the top strip the FAB rises into.
        Padding(
          padding: const EdgeInsets.only(top: _kFabProtrusion),
          child: bar,
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: _CenterFab(
              icon: centerIcon!,
              onTap: onCenterTap!,
              color: centerColor ?? AppColors.brandGreen,
            ),
          ),
        ),
      ],
    );
  }
}

/// A single icon + label tab. Selected → brand colour + bold label.
class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;
    final icon = selected ? (item.selectedIcon ?? item.icon) : item.icon;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _badged(Icon(icon, color: color), item.badgeCount),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badged(Widget icon, int count) =>
      count > 0 ? Badge.count(count: count, child: icon) : icon;
}

/// The raised circular center action.
class _CenterFab extends StatelessWidget {
  const _CenterFab({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      shape: const CircleBorder(),
      elevation: AppElevation.high,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: _kFabSize,
          height: _kFabSize,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
