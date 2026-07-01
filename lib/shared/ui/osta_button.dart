import 'package:flutter/material.dart';
import 'package:osta/core/theme/osta_tokens.dart';

enum OstaButtonVariant { primary, secondary, text }

/// Brand button. One widget, three variants, built-in loading state
/// (spinner replaces the label and taps are ignored while loading).
class OstaButton extends StatelessWidget {
  const OstaButton({
    required this.label,
    required this.onPressed,
    this.variant = OstaButtonVariant.primary,
    this.loading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final OstaButtonVariant variant;
  final bool loading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : _label();
    final effectiveOnPressed = loading ? null : onPressed;

    return switch (variant) {
      OstaButtonVariant.primary => FilledButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      OstaButtonVariant.secondary => OutlinedButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
      OstaButtonVariant.text => TextButton(
        onPressed: effectiveOnPressed,
        child: child,
      ),
    };
  }

  Widget _label() {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: OstaSpacing.sm),
        Text(label),
      ],
    );
  }
}
