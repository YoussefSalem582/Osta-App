import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Brand card — token padding, optional tap, styling from [CardThemeData].
class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.border,
    this.color,
    this.elevation,
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final BorderSide? border;
  final Color? color;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    final shape = border != null
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.lg),
            side: border!,
          )
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      color: color,
      elevation: elevation,
      shape: shape,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
