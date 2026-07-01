import 'package:flutter/material.dart';
import 'package:osta/core/theme/osta_tokens.dart';

/// Brand modal bottom sheet — rounded top + drag handle come from
/// [BottomSheetThemeData]; this adds token padding and an optional title.
abstract final class OstaBottomSheet {
  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isScrollControlled = false,
  }) => showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          OstaSpacing.md,
          0,
          OstaSpacing.md,
          OstaSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: OstaSpacing.md),
            ],
            child,
          ],
        ),
      ),
    ),
  );
}
