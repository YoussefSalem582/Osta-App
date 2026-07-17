import 'package:flutter/material.dart';
import 'package:osta/shared/ui/app_pill.dart';

class PaymentBadge extends StatelessWidget {
  const PaymentBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppPill(
      label: label,
      background: colorScheme.primary.withValues(alpha: 0.12),
      foreground: colorScheme.primary,
    );
  }
}
