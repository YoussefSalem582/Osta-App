import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';

/// Result of the write-review sheet — a 1–5 rating and an optional comment.
class WriteReviewResult {
  const WriteReviewResult({required this.rating, this.comment});

  final int rating;
  final String? comment;
}

/// Opens the rate-and-comment sheet. Returns null if dismissed without submit.
Future<WriteReviewResult?> showWriteReviewSheet(BuildContext context) =>
    showModalBottomSheet<WriteReviewResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _WriteReviewSheet(),
    );

class _WriteReviewSheet extends StatefulWidget {
  const _WriteReviewSheet();

  @override
  State<_WriteReviewSheet> createState() => _WriteReviewSheetState();
}

class _WriteReviewSheetState extends State<_WriteReviewSheet> {
  int _rating = 0;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        MediaQuery.viewInsetsOf(context).bottom + AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.writeReview,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 36,
                    color: i <= _rating
                        ? context.appColors.warning
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _comment,
            label: l10n.reviewCommentLabel,
            minLines: 2,
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.reviewSubmit,
            onPressed: _rating == 0
                ? null
                : () {
                    final text = _comment.text.trim();
                    Navigator.of(context).pop(
                      WriteReviewResult(
                        rating: _rating,
                        comment: text.isEmpty ? null : text,
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}
