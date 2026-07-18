import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Title + eyebrow for the Catalog tab, with an add button shown only when
/// the Services segment is selected.
class ServicesHeader extends StatelessWidget {
  const ServicesHeader({
    required this.showAddButton,
    required this.onAdd,
    super.key,
  });

  final bool showAddButton;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.businessServicesEyebrow,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.businessServicesTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (showAddButton)
            InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
                child: Icon(
                  Icons.add,
                  color: theme.colorScheme.onPrimary,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
