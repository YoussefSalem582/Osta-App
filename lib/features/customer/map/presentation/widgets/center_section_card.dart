import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_pill.dart';
import 'package:osta/shared/ui/app_section_title.dart';

/// A titled section on the center detail page: a header (title, optional count
/// pill and trailing action) over a body of [children] separated by hairlines,
/// or a muted [emptyLabel] when there are none.
///
/// Shared by About, Services and Reviews so all three read as one system —
/// built on the common [AppCard] / [AppPill] / [AppSectionTitle].
class CenterSectionCard extends StatelessWidget {
  const CenterSectionCard({
    required this.title,
    required this.children,
    this.count,
    this.action,
    this.emptyLabel,
    super.key,
  });

  final String title;
  final List<Widget> children;

  /// Shown as a pill beside the title when greater than zero.
  final int? count;

  /// Trailing header widget (e.g. the reviews "write" button).
  final Widget? action;

  /// Muted line rendered when [children] is empty.
  final String? emptyLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppSectionTitle(title: title),
              if (count != null && count! > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                AppPill(
                  label: '$count',
                  background: theme.colorScheme.surfaceContainerHighest,
                  foreground: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ],
              const Spacer(),
              ?action,
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (children.isEmpty)
            Text(
              emptyLabel ?? '',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else ...[
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const Divider(height: 1),
              children[i],
            ],
          ],
        ],
      ),
    );
  }
}
