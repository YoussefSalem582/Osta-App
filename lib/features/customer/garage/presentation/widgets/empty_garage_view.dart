import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class EmptyGarageView extends StatelessWidget {
  const EmptyGarageView({required this.onAddVehicle, super.key});

  final VoidCallback onAddVehicle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.garage_outlined,
              size: 80,
              color: colorScheme.onSurface.withValues(alpha: 0.25),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.emptyGarageTitle,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.emptyGarageSubtitle,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAddVehicle,
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.addCar),
            ),
          ],
        ),
      ),
    );
  }
}
