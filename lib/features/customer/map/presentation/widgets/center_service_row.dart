import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/map/data/model/center_detail.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// One row in a center's service list: name, optional duration, and price.
class CenterServiceRow extends StatelessWidget {
  const CenterServiceRow({required this.service, super.key});

  final CenterService service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (service.durationMinutes != null)
                  Text(
                    l10n.centerDetailDurationMin(service.durationMinutes!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${service.price.toStringAsFixed(0)} ${l10n.currencyEgp}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.brandGreen,
            ),
          ),
        ],
      ),
    );
  }
}
