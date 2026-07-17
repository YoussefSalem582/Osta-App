import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Progress bar, step indicator and completion percent for the business
/// onboarding wizard (#53's `SetupProgressHeader`).
class StepHeader extends StatelessWidget {
  const StepHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.stepText,
    super.key,
  });

  final int currentStep;
  final int totalSteps;
  final String stepText;

  /// Derived rather than passed in, so the bars and the number can't disagree.
  int get _percent =>
      totalSteps <= 0 ? 0 : ((currentStep / totalSteps) * 100).round();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isCompletedOrCurrent = index < currentStep;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsetsDirectional.only(
                  end: index < totalSteps - 1 ? AppSpacing.sm : 0,
                ),
                decoration: BoxDecoration(
                  color: isCompletedOrCurrent
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.pill),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                stepText,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.start,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              context.l10n.setupPercentComplete(_percent),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
