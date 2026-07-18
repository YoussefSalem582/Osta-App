import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_solid_hero_card.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    required this.mechanicName,
    required this.centerName,
    required this.statusLabel,
    super.key,
  });

  final String mechanicName;
  final String centerName;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    return AppSolidHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.appColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.live,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              const Text('🔧 ', style: TextStyle(fontSize: 22)),
              Expanded(
                child: Text(
                  statusLabel,
                  style: textTheme.titleLarge?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (mechanicName.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              mechanicName,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimary.withValues(alpha: 0.85),
              ),
            ),
          ],
          Text(
            centerName,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onPrimary.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
