import 'package:flutter/material.dart';
import 'package:osta/core/theme/osta_tokens.dart';

/// Brand card — token padding, optional tap, styling from [CardThemeData].
class OstaCard extends StatelessWidget {
  const OstaCard({
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(OstaSpacing.md),
    super.key,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
