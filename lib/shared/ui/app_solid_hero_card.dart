import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Solid brand-green hero shell — decoration only. Callers supply their own
/// content (avatar/name/edit-button, status/timeline, ...) as [child].
class AppSolidHeroCard extends StatelessWidget {
  const AppSolidHeroCard({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.brandGreen,
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      padding: padding,
      child: child,
    );
  }
}
