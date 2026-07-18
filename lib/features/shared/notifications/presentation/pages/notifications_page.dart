import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/notifications/data/model/app_notification.dart';
import 'package:osta/features/shared/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:osta/features/shared/notifications/presentation/widgets/notification_tile.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// In-app notification inbox (`GET /notifications`, `POST /notifications/{id}/read`).
/// Reached from the "Notifications" row on the profile/More tab. Tapping an
/// unread row marks it read; the app-bar action marks the whole feed read.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => NotificationsBloc()..add(const NotificationsLoadRequested()),
    child: const _NotificationsView(),
  );
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        centerTitle: false,
        title: l10n.notifications,
        actions: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              final hasUnread =
                  state is NotificationsLoaded && state.unreadCount > 0;
              if (!hasUnread) return const SizedBox.shrink();
              return TextButton(
                onPressed: () => context.read<NotificationsBloc>().add(
                  const NotificationsMarkAllReadRequested(),
                ),
                child: Text(l10n.notificationsMarkAllRead),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state is NotificationsLoading || state is NotificationsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationsError) {
            return ErrorState(
              title: l10n.notificationsErrorTitle,
              message: state.message,
              onRetry: () => context.read<NotificationsBloc>().add(
                const NotificationsLoadRequested(),
              ),
            );
          }
          final items = state is NotificationsLoaded
              ? state.items
              : const <AppNotification>[];
          if (items.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none_outlined,
              title: l10n.notificationsEmptyTitle,
              message: l10n.notificationsEmptyMessage,
            );
          }
          return RefreshIndicator.adaptive(
            onRefresh: () {
              final bloc = context.read<NotificationsBloc>()
                ..add(const NotificationsLoadRequested());
              // Keep the spinner up until the reload settles, matching the
              // awaited-load() behaviour the cubit had.
              return bloc.stream.firstWhere((s) => s is! NotificationsLoading);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  NotificationTile(notification: items[index]),
            ),
          );
        },
      ),
    );
  }
}
