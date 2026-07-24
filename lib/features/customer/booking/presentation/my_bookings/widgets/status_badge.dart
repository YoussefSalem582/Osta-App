import 'package:flutter/material.dart';
import 'package:osta/features/customer/booking/data/models/booking_item.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_pill.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, super.key});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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

    return AppPill(label: label, background: bg, foreground: fg);
  }
}
