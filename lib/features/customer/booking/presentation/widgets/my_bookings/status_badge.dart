import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/data/model.dart/booking_item.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (label, bg, fg) = switch (status) {
      BookingStatus.pending => (
        context.l10n.statusPending,
        colorScheme.primaryContainer,
        colorScheme.onPrimaryContainer,
      ),
      BookingStatus.confirmed => (
        context.l10n.statusConfirmed,
        colorScheme.secondaryContainer,
        colorScheme.onSecondaryContainer,
      ),
      BookingStatus.completed => (
        context.l10n.statusCompleted,
        colorScheme.surfaceContainerHighest,
        colorScheme.onSurfaceVariant,
      ),
      BookingStatus.cancelled => (
        context.l10n.statusCancelled,
        colorScheme.errorContainer,
        colorScheme.onErrorContainer,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
