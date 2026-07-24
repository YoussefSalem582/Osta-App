import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/profile/presentation/profile/widgets/profile_card.dart';
import 'package:osta/features/shared/profile/presentation/profile/widgets/profile_item.dart';
import 'package:osta/shared/ui/app_segmented_toggle.dart';

/// A `ProfileCard` row pairing an icon + label with a segmented toggle —
/// used for the language and appearance settings rows.
class SettingsToggleRow extends StatelessWidget {
  const SettingsToggleRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.options,
    required this.selectedIndex,
    required this.onSelect,
    super.key,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ProfileCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            ProfileItemIcon(icon: icon, color: iconColor),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            AppSegmentedToggle(
              options: options,
              selectedIndex: selectedIndex,
              onSelect: onSelect,
            ),
          ],
        ),
      ),
    );
  }
}
