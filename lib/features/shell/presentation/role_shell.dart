import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

enum _ShellAction { switchRole, signOut }

/// Shared authenticated shell for the live roles. Hosts a bottom nav and the
/// overflow menu with "switch role" (clears the active role, keeps the token →
/// back to the chooser) and "sign out".
class RoleShell extends StatefulWidget {
  const RoleShell({
    required this.tabs,
    this.centerIcon,
    this.onCenterTap,
    super.key,
  });

  final List<AppBottomNavItem> tabs;

  /// Optional raised center action for the bottom bar (e.g. a map button).
  final IconData? centerIcon;
  final VoidCallback? onCenterTap;

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tab = widget.tabs[_index];
    return Scaffold(
      appBar: AppTopBar(
        title: tab.label,
        leading: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Image.asset(AppImages.logo, color: AppColors.brandGreen),
        ),
        actions: [
          PopupMenuButton<_ShellAction>(
            onSelected: (action) => _onAction(context, action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _ShellAction.switchRole,
                child: Text(l10n.switchRole),
              ),
              PopupMenuItem(
                value: _ShellAction.signOut,
                child: Text(l10n.signOut),
              ),
            ],
          ),
        ],
      ),
      body:
          tab.body ??
          EmptyState(
            icon: tab.icon,
            title: tab.label,
            message: l10n.shellWelcome,
          ),
      bottomNavigationBar: AppBottomNavBar(
        items: widget.tabs,
        currentIndex: _index,
        onChanged: (i) {
          final onTap = widget.tabs[i].onTap;
          if (onTap != null) {
            onTap();
          } else {
            setState(() => _index = i);
          }
        },
        centerIcon: widget.centerIcon,
        onCenterTap: widget.onCenterTap,
      ),
    );
  }

  void _onAction(BuildContext context, _ShellAction action) {
    final session = context.read<SessionController>();
    switch (action) {
      case _ShellAction.switchRole:
        unawaited(session.switchRole());
      case _ShellAction.signOut:
        unawaited(session.signOut());
    }
  }
}
