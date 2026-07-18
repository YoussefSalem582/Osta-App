import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Primary Home call-to-action: a full-width branded card that opens the
/// nearest center's booking flow (or re-requests location when there's no fix).
/// The whole card is the tap target — no cramped inner button.
class BookServiceCard extends StatelessWidget {
  const BookServiceCard({this.onTap, super.key});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    const onGreen = Colors.white;

    return Material(
      color: AppColors.brandGreen,
      borderRadius: BorderRadius.circular(AppRadii.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: onGreen.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.handyman_outlined, color: onGreen),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeBookServiceTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: onGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.homeBookServiceSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onGreen.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                rtl ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
                color: onGreen,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
