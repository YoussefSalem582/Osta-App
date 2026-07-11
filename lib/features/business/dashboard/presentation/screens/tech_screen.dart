import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class TechScreen extends StatelessWidget {
  const TechScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 28,
                  width: 28,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(AppRadii.sm),
                    ),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).colorScheme.onSurface,
                    size: 16,
                  ),
                ),
                const SizedBox(
                  width: AppSpacing.sm,
                ),
                Text(
                  context.l10n.technicians,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                ),
                const Spacer(),
                Container(
                  height: 28,
                  width: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.brandGreen,
                    borderRadius: BorderRadius.all(
                      Radius.circular(AppRadii.sm),
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: AppSpacing.xl,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.md),
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mahmoud',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(
                          height: AppSpacing.xs,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(AppRadii.md),
                            ),
                            color: context.appColors.success,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Text(
                              context.l10n.engine,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    // ponytail: no token for this color
                                    color: const Color(0xFF3A694E),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadii.sm),
                        ),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.md),
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mahmoud',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(
                          height: AppSpacing.xs,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(AppRadii.md),
                            ),
                            color: context.appColors.success,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Text(
                              context.l10n.engine,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    // ponytail: no token for this color
                                    color: const Color(0xFF3A694E),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadii.sm),
                        ),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.md),
                ),
                color: Theme.of(context).colorScheme.surface,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mahmoud',
                          style:
                              Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(
                          height: AppSpacing.xs,
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(AppRadii.md),
                            ),
                            color: context.appColors.success,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Text(
                              context.l10n.engine,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    // ponytail: no token for this color
                                    color: const Color(0xFF3A694E),
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(AppRadii.sm),
                        ),
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerLow,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Icon(
                          Icons.edit,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: AppSpacing.sm,
            ),
            Container(
              alignment: Alignment.center,

              decoration: BoxDecoration(
                border: Border.all(color: AppColors.brandGreen),
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.md),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add,
                      color: AppColors.brandGreen,
                      size: 24,
                    ),
                    const SizedBox(
                      width: AppSpacing.sm,
                    ),
                    Text(
                      context.l10n.addTechnician,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.brandGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
