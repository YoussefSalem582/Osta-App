import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Progress bar and step indicator for business onboarding wizard.
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
        Text(
          stepText,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}
