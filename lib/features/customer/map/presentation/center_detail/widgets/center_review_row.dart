import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/reviews/data/model/review.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// One row in a center's review list: reviewer name, star rating, and
/// optional comment.
class CenterReviewRow extends StatelessWidget {
  const CenterReviewRow({required this.review, super.key});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.reviewerName ?? l10n.reviewAnonymous,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.star_rounded,
                size: 15,
                color: context.appColors.warning,
              ),
              Text(
                '${review.rating}',
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(review.comment!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
