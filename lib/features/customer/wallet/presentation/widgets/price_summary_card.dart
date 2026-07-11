import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/wallet/presentation/widgets/price_summary_row.dart';
import 'package:osta/shared/ui/app_card.dart';

class PriceSummaryCard extends StatelessWidget {
  const PriceSummaryCard({
    required this.serviceFeeLabel,
    required this.taxLabel,
    required this.totalLabel,
    required this.serviceFee,
    required this.tax,
    required this.total,
    super.key,
  });

  final String serviceFeeLabel;
  final String taxLabel;
  final String totalLabel;
  final String serviceFee;
  final String tax;
  final String total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        children: [
          PriceSummaryRow(
            label: serviceFeeLabel,
            value: serviceFee,
            labelStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            valueStyle: textTheme.bodyMedium,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(
              color: colorScheme.outlineVariant,
              height: 1,
            ),
          ),
          PriceSummaryRow(
            label: taxLabel,
            value: tax,
            labelStyle: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            valueStyle: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          PriceSummaryRow(
            label: totalLabel,
            value: total,
            labelStyle: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
            valueStyle: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
