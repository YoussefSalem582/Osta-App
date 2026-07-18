import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Year-founded picker; optional, range mirrors backend's
/// `integer|min:1900|max:{this year}` rule.
class FoundingYearDropdown extends StatelessWidget {
  const FoundingYearDropdown({
    required this.value,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final int? value;
  final ValueChanged<int> onChanged;
  final String? errorText;

  /// Newest first — a workshop founded last year is a likelier pick than 1900.
  static List<int> get years {
    final now = DateTime.now().year;
    return [for (var y = now; y >= 1900; y--) y];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: l10n.businessOnboardingYearFoundedLabel,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
        errorText: errorText,
      ),
      items: [
        for (final y in years) DropdownMenuItem(value: y, child: Text('$y')),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
