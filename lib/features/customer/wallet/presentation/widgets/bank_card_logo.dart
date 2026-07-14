import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

class BankCardLogo extends StatelessWidget {
  const BankCardLogo({required this.brand, super.key});

  final String brand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isVisa = brand.toUpperCase() == 'VISA';
    final bg = isVisa ? const Color(0xFF1A1F71) : const Color(0xFFEB001B);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isVisa ? bg : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadii.sm),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Text(
        brand == 'MC' ? 'MC' : 'VISA',
        style: textTheme.labelSmall?.copyWith(
          color: isVisa ? Colors.white : const Color(0xFFEB001B),
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
