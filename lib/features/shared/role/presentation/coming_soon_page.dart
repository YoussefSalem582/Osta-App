import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Placeholder shell for the not-yet-live roles (`mechanic`, `tow`). Only
/// reachable defensively — those roles can't be picked in the chooser — so it
/// always offers a way back via "switch role".
class ComingSoonPage extends StatelessWidget {
  const ComingSoonPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppTopBar(title: l10n.appTitle),
      body: EmptyState(
        icon: Icons.hourglass_empty,
        title: l10n.comingSoon,
        message: l10n.comingSoonBody,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.read<SessionController>().switchRole(),
        icon: const Icon(Icons.swap_horiz),
        label: Text(l10n.switchRole),
      ),
    );
  }
}
