import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/ui/app_pill.dart';

class ComingSoonBadge extends StatelessWidget {
  const ComingSoonBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppPill(
      label: label,
      background: context.appColors.gray,
      // ponytail: white on the neutral gray pill; no on-gray token exists
      foreground: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      textStyle: theme.textTheme.labelMedium,
      fontWeight: FontWeight.w700,
    );
  }
}
