import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Brand pill — a rounded label chip, replacing the `Container` +
/// `BoxDecoration` + `Text` every badge used to hand-roll.
class AppPill extends StatelessWidget {
  const AppPill({
    required this.label,
    required this.background,
    required this.foreground,
    this.border,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    this.textStyle,
    this.fontWeight = FontWeight.w600,
    super.key,
  });

  final String label;
  final Color background;
  final Color foreground;
  final BorderSide? border;
  final EdgeInsetsGeometry padding;

  /// Defaults to `labelSmall` — the size four of five badges already used.
  final TextStyle? textStyle;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: border == null ? null : Border.fromBorderSide(border!),
      ),
      child: Text(
        label,
        style: (textStyle ?? theme.textTheme.labelSmall)?.copyWith(
          color: foreground,
          fontWeight: fontWeight,
        ),
      ),
    );
  }
}
