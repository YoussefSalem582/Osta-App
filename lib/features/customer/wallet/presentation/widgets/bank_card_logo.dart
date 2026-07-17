import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

class BankCardLogo extends StatelessWidget {
  const BankCardLogo({required this.brand, super.key});

  // Third-party brand marks. These are deliberately NOT tokens and must not
  // follow the theme — Visa blue and Mastercard red are fixed by their owners,
  // and a themed approximation would misrepresent the mark.
  static const _visaBlue = Color(0xFF1A1F71);
  static const _mastercardRed = Color(0xFFEB001B);

  final String brand;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isVisa = brand.toUpperCase() == 'VISA';
    final bg = isVisa ? _visaBlue : _mastercardRed;

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
          color: isVisa ? Colors.white : _mastercardRed,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
