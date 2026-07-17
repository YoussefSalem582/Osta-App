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
    this.centerColor,
    this.centerBody,
    this.centerLabel,
    this.centerFullBleed = false,
    super.key,
  });

  final List<AppBottomNavItem> tabs;

  /// Optional raised center action for the bottom bar (e.g. a map button).
  final IconData? centerIcon;
  final VoidCallback? onCenterTap;

  /// Fill colour of the center action; defaults to the brand green.
  final Color? centerColor;

  /// Optional screen the center action shows *inside* the shell (keeping the
  /// bottom nav), instead of firing [onCenterTap]. Tapping any tab leaves it.
  final Widget? centerBody;

  /// App-bar title shown while [centerBody] is on screen. Unused when
  /// [centerFullBleed] drops the bar.
  final String? centerLabel;

  /// Lets [centerBody] have the whole body with no app bar — the customer map
  /// is specified full-screen, while business Bookings keeps its bar + title.
  final bool centerFullBleed;

  @override
  State<RoleShell> createState() => _RoleShellState();
}

class _RoleShellState extends State<RoleShell> {
  int _index = 0;
  bool _centerActive = false;

  void _onCenter() {
    if (widget.centerBody != null) {
      setState(() => _centerActive = true);
    } else {
      widget.onCenterTap?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tab = widget.tabs[_index];
    final showingCenter = _centerActive && widget.centerBody != null;
    final fullBleed = showingCenter && widget.centerFullBleed;
    return Scaffold(
      // Let full-bleed bodies (e.g. the customer map) paint behind the
      // protruding center FAB instead of the scaffold surface.
      extendBody: true,
      appBar: fullBleed
          ? null
          : AppTopBar(
              title: showingCenter
                  ? (widget.centerLabel ?? tab.label)
                  : tab.label,
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
      body: showingCenter
          ? widget.centerBody!
          : (tab.body ??
                EmptyState(
                  icon: tab.icon,
                  title: tab.label,
                  message: l10n.shellWelcome,
                )),
      bottomNavigationBar: AppBottomNavBar(
        items: widget.tabs,
        // No tab is selected while the center body is on screen.
        currentIndex: showingCenter ? -1 : _index,
        centerActive: showingCenter,
        onChanged: (i) {
          final onTap = widget.tabs[i].onTap;
          if (onTap != null) {
            onTap();
          } else {
            setState(() {
              _centerActive = false;
              _index = i;
            });
          }
        },
        centerIcon: widget.centerIcon,
        onCenterTap: widget.centerIcon != null ? _onCenter : null,
        centerColor: widget.centerColor,
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
