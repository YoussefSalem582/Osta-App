import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/session/session_controller.dart';
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
    required this.title,
    required this.tabs,
    this.pages,
    this.centerIcon,
    this.onCenterTap,
    super.key,
  });

  final String title;
  final List<AppBottomNavItem> tabs;

  /// Optional list of pages to display for each tab. When provided, the
  /// matching page is shown instead of the generic [EmptyState] placeholder.
  /// Must have the same length as [tabs] when provided.
  final List<Widget>? pages;

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
        title: widget.title,
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
      body: widget.pages != null
          ? IndexedStack(
              index: _index,
              children: widget.pages!,
            )
          : EmptyState(
              icon: tab.icon,
              title: tab.label,
              message: l10n.shellWelcome,
            ),
      bottomNavigationBar: AppBottomNavBar(
        items: widget.tabs,
        currentIndex: _index,
        onChanged: (i) => setState(() => _index = i),
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
