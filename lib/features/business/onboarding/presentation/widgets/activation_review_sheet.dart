import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';

/// Last look before the center goes live (#53 activates with no verification
/// queue, so this is the one place a merchant can eyeball the whole thing).
///
/// Returns `true` to activate, `false`/`null` to keep editing.
class ActivationReviewSheet extends StatelessWidget {
  const ActivationReviewSheet({
    required this.tradeName,
    required this.typeLabel,
    required this.hasLocation,
    required this.serviceCount,
    super.key,
  });

  final String tradeName;
  final String typeLabel;
  final bool hasLocation;
  final int serviceCount;

  static Future<bool?> show(
    BuildContext context, {
    required String tradeName,
    required String typeLabel,
    required bool hasLocation,
    required int serviceCount,
  }) => showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ActivationReviewSheet(
      tradeName: tradeName,
      typeLabel: typeLabel,
      hasLocation: hasLocation,
      serviceCount: serviceCount,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.businessCatalogReviewTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _ReviewRow(
              icon: Icons.storefront_outlined,
              label: tradeName,
              value: typeLabel,
            ),
            const SizedBox(height: AppSpacing.md),
            _ReviewRow(
              icon: hasLocation ? Icons.check_circle : Icons.location_off,
              label: l10n.businessCatalogReviewLocationSet,
              valueOk: hasLocation,
            ),
            const SizedBox(height: AppSpacing.md),
            _ReviewRow(
              icon: Icons.build_circle_outlined,
              label: l10n.businessCatalogReviewServices(serviceCount),
              valueOk: true,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.businessCatalogReviewLiveNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: l10n.businessCatalogReviewConfirm,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.businessCatalogReviewCancel,
              variant: AppButtonVariant.text,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueOk,
  });

  final IconData icon;
  final String label;
  final String? value;

  /// When set, tints the leading icon success/error instead of neutral.
  final bool? valueOk;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = context.appColors;
    final iconColor = switch (valueOk) {
      true => appColors.success,
      false => theme.colorScheme.error,
      null => theme.colorScheme.primary,
    };

    return Row(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        if (value != null)
          Text(
            value!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
