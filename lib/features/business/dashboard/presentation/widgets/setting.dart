import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

class Setting extends StatelessWidget {
  const Setting({
    required this.icon,
    required this.text,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                alignment: Alignment.center,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.sm),
                  ),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: Icon(
                    icon,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(
                width: AppSpacing.md,
              ),
              Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
