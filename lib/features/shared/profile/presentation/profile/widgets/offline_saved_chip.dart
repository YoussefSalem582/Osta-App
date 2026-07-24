import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Pill chip telling the user they're looking at a cached/offline copy of
/// their profile, with the last-fetched time when known.
class OfflineSavedChip extends StatelessWidget {
  const OfflineSavedChip({required this.fetchedAt, super.key});

  final DateTime? fetchedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final String label;
    if (fetchedAt == null) {
      label = l10n.profileOfflineSaved;
    } else {
      final when = MaterialLocalizations.of(
        context,
      ).formatShortDate(fetchedAt!);
      label = '${l10n.profileOfflineSaved} · ${l10n.profileLastUpdated(when)}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.cloud_off_outlined,
            size: 16,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
