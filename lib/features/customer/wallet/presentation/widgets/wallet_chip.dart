import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/shared/ui/app_pill.dart';

class WalletChip extends StatelessWidget {
  const WalletChip({required this.label, this.isSelected = false, super.key});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final appColors = context.appColors;

    return AppPill(
      label: label,
      background: isSelected
          ? appColors.success.withValues(alpha: 0.12)
          : colorScheme.surfaceContainerHigh,
      foreground: isSelected ? appColors.success : colorScheme.onSurface,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      border: BorderSide(
        color: isSelected ? appColors.success : colorScheme.outlineVariant,
        width: isSelected ? 1.5 : 1,
      ),
    );
  }
}
