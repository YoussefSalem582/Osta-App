import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

class SelectedType extends StatelessWidget {
  const SelectedType({
    required this.textColor,
    required this.text,
    required this.conColor,
    super.key,
  });

  final Color conColor;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: conColor,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.lg)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
