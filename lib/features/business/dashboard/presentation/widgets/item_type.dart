import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

class ItemType extends StatelessWidget {
  const ItemType({
    required this.text1,
    required this.text2,
    required this.color,
    this.maxLines,
    super.key,
  });

  final String text1;
  final String text2;
  final int? maxLines;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.lg)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            children: [
              Text(
                text1,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: AppSpacing.xs,
              ),
              Text(
                maxLines: maxLines,
                text2,
                style:
                    Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
