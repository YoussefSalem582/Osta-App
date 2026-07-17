import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    required this.plateNumber,
    required this.brand,
    required this.model,
    required this.mileageKm,
    required this.isPrimary,
    required this.onDelete,
    required this.onSetPrimary,
    this.year,
    this.isActionLoading = false,
    this.icon = Icons.directions_car_rounded,
    super.key,
  });

  final String brand;
  final String model;
  final int mileageKm;
  final String plateNumber;
  final bool isPrimary;
  final bool isActionLoading;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;
  final int? year;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.brandGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: AppColors.brandGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$brand $model',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        if (year != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            year.toString(),
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.55,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '-',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          plateNumber,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.55,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(
                          Icons.speed_rounded,
                          size: 14,
                          color: colorScheme.onSurface.withValues(alpha: 0.55),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          '${formatMileage(mileageKm)} ${context.l10n.km}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (isPrimary) const PrimaryBadge(),

              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 32,
                height: 32,
                child: IconButton.filledTonal(
                  onPressed: isActionLoading ? null : onDelete,
                  padding: EdgeInsets.zero,
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.errorContainer.withValues(
                      alpha: 0.5,
                    ),
                    foregroundColor: colorScheme.error,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 16),
                  tooltip: context.l10n.deleteVehicleDialogTitle,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          Row(
            children: [
              if (!isPrimary) ...[
                const Spacer(),
                ActionButton(
                  label: context.l10n.setAsPrimary,
                  icon: Icons.star_outline_rounded,
                  onPressed: onSetPrimary,
                  color: AppColors.brandGreen,
                  filled: true,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String formatMileage(int km) {
    if (km >= 1000) {
      final thousands = km ~/ 1000;
      final remainder = km % 1000;
      if (remainder == 0) return '$thousands,000';
      return km.toString().replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
    }
    return km.toString();
  }
}

class PrimaryBadge extends StatelessWidget {
  const PrimaryBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandGreen,
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: colorScheme.onPrimary),
          const SizedBox(width: AppSpacing.xs),
          Text(
            context.l10n.primary,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.color,
    this.filled = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.sm),
          ),
        ),
        icon: Icon(icon, size: 14),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withValues(alpha: 0.4)),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
      icon: Icon(icon, size: 14),
      label: Text(label),
    );
  }
}
