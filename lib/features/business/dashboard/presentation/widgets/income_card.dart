import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class IncomeCard extends StatelessWidget {
  const IncomeCard({
    required this.revenue,
    required this.loading,
    required this.error,
    super.key,
  });

  final double? revenue;
  final bool loading;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;
    final String value;
    if (loading) {
      value = '…';
    } else if (error || revenue == null) {
      value = '—';
    } else {
      value = '${revenue!.toStringAsFixed(0)} ${l10n.currencyEgp}';
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
        gradient: LinearGradient(
          colors: [AppColors.brandGreen, context.appColors.success],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          spacing: AppSpacing.sm,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.todayIncome,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: onPrimary),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
