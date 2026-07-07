import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Brand text field — thin wrapper over [TextFormField]; visual styling
/// comes from the shared [InputDecorationTheme].
class AppTextField extends StatelessWidget {
  const AppTextField({
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.prefixText,
    this.validator,
    this.onChanged,
    this.enabled = true,
    super.key,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? errorText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final String? prefixText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            prefixText: prefixText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            filled: true,
            fillColor: AppColors.light.onSuccess,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadii.md),
              borderSide: BorderSide(
                color: AppColors.light.success,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
