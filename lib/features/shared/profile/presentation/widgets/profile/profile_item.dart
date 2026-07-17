import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

class ProfileListItem extends StatelessWidget {
  const ProfileListItem({
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
    super.key,
  });

  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final leading = this.leading;
    final subtitle = this.subtitle;
    final trailing = this.trailing;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadii.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            ?leading,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                ],
              ),
            ),
            ?trailing,
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left_rounded
                  : Icons.chevron_right_rounded,
              size: 20,
              color: colorScheme.onSurface.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded icon chip for a profile row: the icon at full strength on a 12%
/// wash of itself.
///
/// ponytail: [color] is a decorative category tint, not a semantic role — it
/// distinguishes rows at a glance and carries no success/warning/error meaning,
/// which is why callers pass raw Material colours rather than AppColors. Any
/// saturated hue reads at 12% on both themes. Give it a token only if these
/// tints ever need to mean something.
class ProfileItemIcon extends StatelessWidget {
  const ProfileItemIcon({required this.icon, required this.color, super.key});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsetsDirectional.only(end: AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }
}
