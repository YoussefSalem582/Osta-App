import 'package:flutter/material.dart';

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
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;

  /// Overrides the default pop behavior of the auto back button.
  final VoidCallback? onBack;

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;
    return AppBar(
      title: Text(title),
      leading:
          leading ??
          ((canPop || onBack != null) ? BackButton(onPressed: onBack) : null),
      actions: actions,
      bottom: bottom,
    );
  }
}
