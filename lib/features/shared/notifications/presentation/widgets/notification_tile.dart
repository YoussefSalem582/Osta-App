import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/notifications/data/model/app_notification.dart';
import 'package:osta/features/shared/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class NotificationTile extends StatelessWidget {
  const NotificationTile({required this.notification, super.key});

  final AppNotification notification;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final unread = !notification.isRead;
    final createdAt = notification.createdAt;
    final when = createdAt == null
        ? null
        : MaterialLocalizations.of(context).formatShortDate(createdAt);

    return ListTile(
      onTap: unread
          ? () => context.read<NotificationsBloc>().add(
              NotificationsMarkReadRequested(notification.id),
            )
          : null,
      leading: CircleAvatar(
        backgroundColor: unread
            ? AppColors.brandGreen.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.notifications_outlined,
          color: unread
              ? AppColors.brandGreen
              : theme.colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(
        notification.title ?? l10n.notifications,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      subtitle: notification.body == null
          ? null
          : Text(notification.body!, style: theme.textTheme.bodyMedium),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (when != null)
            Text(
              when,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (unread) ...[
            const SizedBox(height: AppSpacing.xs),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.brandGreen,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
