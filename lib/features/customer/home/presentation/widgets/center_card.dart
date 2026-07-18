import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/home/presentation/widgets/home_tile.dart';
import 'package:osta/shared/formatters/app_formatters.dart';

class CenterCard extends StatelessWidget {
  const CenterCard({
    required this.distance,
    required this.name,
    required this.rate,
    this.onTap,
    this.imageUrl,
    super.key,
  });
  final String name;
  final String distance;
  final double rate;
  final VoidCallback? onTap;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();

    return HomeTile(
      title: name,
      onTap: onTap,
      imageUrl: imageUrl,
      placeholderIcon: Icons.store_mall_directory_outlined,
      footer: Row(
        children: [
          Expanded(
            child: Text(
              distance,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Matches PlaceDialog: a real icon on the warning token, and digits
          // through NumberFormatter so Arabic renders ٤٫٦ not 4.6.
          Icon(Icons.star_rounded, size: 16, color: context.appColors.warning),
          const SizedBox(width: 2),
          Text(
            NumberFormatter.decimal(rate, locale: locale),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
