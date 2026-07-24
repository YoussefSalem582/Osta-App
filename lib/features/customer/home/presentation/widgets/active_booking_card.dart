import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/booking/data/models/booking.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Home hero for the customer's current booking. Only rendered when there is a
/// non-terminal booking (see `HomeBloc`), so [booking] is always present.
/// Tapping it opens the live status screen.
class ActiveBookingCard extends StatelessWidget {
  const ActiveBookingCard({required this.booking, this.onTap, super.key});

  final Booking booking;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    final service = booking.items?.isNotEmpty ?? false
        ? booking.items!.first.name
        : booking.reference;
    final center = booking.center?.name ?? booking.center?.city ?? '';
    // "In Progress" (statusPending) covers both pending and in_progress.
    final statusLabel = booking.status == 'confirmed'
        ? l10n.statusConfirmed
        : l10n.statusPending;
    final progress = switch (booking.status) {
      'confirmed' => 0.6,
      'in_progress' => 0.85,
      _ => 0.3,
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(AppRadii.lg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  statusLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Text(
                    l10n.homeActiveBookingBadge,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              service,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (center.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.8),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            LinearProgressIndicator(
              value: progress,
              color: colorScheme.onPrimary,
              backgroundColor: colorScheme.onPrimary.withValues(alpha: 0.24),
            ),
          ],
        ),
      ),
    );
  }
}
