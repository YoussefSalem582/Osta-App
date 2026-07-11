import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/ui/app_card.dart';

class PaymentMethodCard extends StatelessWidget {
  const PaymentMethodCard({
    required this.isSelected,
    required this.onTap,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.badge,
    this.bottomNote,
    this.trailingLogos,
    this.addCardLabel,
    this.walletChips,
    super.key,
  });

  final bool isSelected;
  final VoidCallback onTap;
  final Widget leading;
  final String title;
  final String subtitle;
  final Widget? badge;
  final String? bottomNote;
  final List<Widget>? trailingLogos;
  final String? addCardLabel;
  final List<Widget>? walletChips;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = context.appColors;

    final borderColor =
        isSelected ? appColors.success : colorScheme.outlineVariant;
    final borderWidth = isSelected ? 1.5 : 1.0;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      border: BorderSide(color: borderColor, width: borderWidth),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Radio circle
              Radio<bool>(
                value: true,
                groupValue: isSelected,
                onChanged: (_) => onTap(),
                activeColor: appColors.success,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: AppSpacing.sm),

              // Payment type icon
              leading,
              const SizedBox(width: AppSpacing.sm),

              // Title + subtitle + optional badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          badge!,
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Optional trailing card logos
              if (trailingLogos != null && trailingLogos!.isNotEmpty) ...[
                const SizedBox(width: AppSpacing.sm),
                Row(
                  children: trailingLogos!
                      .map(
                        (logo) => Padding(
                          padding: const EdgeInsetsDirectional.only(
                            start: AppSpacing.xs,
                          ),
                          child: logo,
                        ),
                      )
                      .toList(),
                ),
              ],

              // Selected check icon
              if (isSelected) ...[
                const SizedBox(width: AppSpacing.xs),
                Icon(
                  Icons.check_circle_rounded,
                  color: appColors.success,
                  size: 20,
                ),
              ],
            ],
          ),

          // ── "Add card" row (bank card) ─────────────────────────────────
          if (addCardLabel != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.xl + AppSpacing.sm + AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    addCardLabel!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // ── Wallet chips row ───────────────────────────────────────────
          if (walletChips != null && walletChips!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.xl + AppSpacing.sm + AppSpacing.lg,
              ),
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: walletChips!,
              ),
            ),
          ],

          // ── Bottom note (cash on delivery) ─────────────────────────────
          if (bottomNote != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: appColors.success,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  bottomNote!,
                  style: textTheme.bodySmall?.copyWith(
                    color: appColors.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
