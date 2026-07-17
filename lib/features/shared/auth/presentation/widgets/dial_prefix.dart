import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Always-visible `+20` dial-code prefix for the Egyptian phone field, with a
/// divider separating it from the input.
class DialPrefix extends StatelessWidget {
  const DialPrefix({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        0,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('+20', style: theme.textTheme.bodyLarge),
          const SizedBox(width: AppSpacing.sm),
          Container(
            width: 1,
            height: 24,
            color: theme.colorScheme.outlineVariant,
          ),
        ],
      ),
    );
  }
}
