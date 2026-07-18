import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/bookings/data/model/business_booking.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';

/// One real pending order on the board — customer, schedule, total, and live
/// Accept / Decline actions. [acting] disables the row while its own
/// accept/reject call is in flight; [onReject] fires before any reason is
/// collected (the board owns the reason dialog).
class PendingOrderCard extends StatelessWidget {
  const PendingOrderCard({
    required this.booking,
    required this.acting,
    required this.onAccept,
    required this.onReject,
    super.key,
  });

  final BusinessBooking booking;
  final bool acting;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final title = booking.customer?.name.trim().isNotEmpty ?? false
        ? booking.customer!.name
        : '#${booking.reference}';
    final scheduled = booking.scheduledAt;
    final subtitle = [
      if (booking.customer != null) '#${booking.reference}',
      if (scheduled != null) DateFormat.MMMd(locale).add_jm().format(scheduled),
    ].join(' · ');
    final total = booking.totalAmount;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (total != null && total > 0)
                Text(
                  '${total.toStringAsFixed(0)} ${l10n.currencyEgp}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.brandGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l10n.accept,
                  loading: acting,
                  onPressed: acting ? null : onAccept,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: l10n.decline,
                  variant: AppButtonVariant.secondary,
                  onPressed: acting ? null : onReject,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
