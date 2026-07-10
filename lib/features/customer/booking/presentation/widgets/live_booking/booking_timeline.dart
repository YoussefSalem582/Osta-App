import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

enum BookingStep { requested, confirmed, inProgress, completed }

class BookingTimeline extends StatelessWidget {
  const BookingTimeline({required this.activeStep, super.key});

  final BookingStep activeStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final steps = [
      (BookingStep.requested, l10n.stepRequested),
      (BookingStep.confirmed, l10n.stepConfirmed),
      (BookingStep.inProgress, l10n.stepInProgress),
      (BookingStep.completed, l10n.stepCompleted),
    ];

    return Column(
      children: [
        for (int i = 0; i < steps.length; i++)
          TimelineRow(
            label: steps[i].$2,
            step: steps[i].$1,
            activeStep: activeStep,
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }
}

class TimelineRow extends StatelessWidget {
  const TimelineRow({
    required this.label,
    required this.step,
    required this.activeStep,
    required this.isLast,
    super.key,
  });

  final String label;
  final BookingStep step;
  final BookingStep activeStep;
  final bool isLast;

  bool get isDone => step.index < activeStep.index;
  bool get isActive => step == activeStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final dotColor = isDone || isActive
        ? AppColors.brandGreen
        : colorScheme.onSurface.withValues(alpha: 0.2);

    final lineColor = isDone
        ? AppColors.brandGreen
        : colorScheme.onSurface.withValues(alpha: 0.15);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                    border: isActive
                        ? Border.all(
                            color: AppColors.brandGreen.withValues(alpha: 0.35),
                            width: 4,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          )
                        : null,
                  ),
                  child: isDone
                      ? Icon(
                          Icons.check_rounded,
                          size: 12,
                          color: colorScheme.onPrimary,
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xs,
                      ),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: isActive
                      ? colorScheme.onSurface
                      : isDone
                      ? colorScheme.onSurface.withValues(alpha: 0.7)
                      : colorScheme.onSurface.withValues(alpha: 0.35),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
