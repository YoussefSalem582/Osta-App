import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Brand top app bar — thin wrapper over [AppBar] so every screen gets the
/// same title style and RTL-safe back behavior. Visual styling lives in
/// [AppBarTheme]; named TopBar because Flutter owns the `AppBar` name.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.onBack,
    this.centerTitle,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;

  /// Overrides the default pop behavior of the auto back button.
  final VoidCallback? onBack;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      centerTitle: centerTitle,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      leading:
          leading ??
          ((canPop || onBack != null) ? BackButton(onPressed: onBack) : null),
      actions: actions,
      bottom: bottom,
    );
  }
}
