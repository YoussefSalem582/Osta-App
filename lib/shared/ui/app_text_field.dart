import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';

/// Brand text field — thin wrapper over [TextFormField]; visual styling
/// comes from the shared [InputDecorationTheme].
///
/// Set [obscureToggle] on a password field to render a show/hide eye button
/// that flips [obscureText] locally (state lives in the field, not the caller).
class AppTextField extends StatefulWidget {
  const AppTextField({
    this.label,
    this.hint,
    this.controller,
    this.errorText,
    this.obscureText = false,
    this.obscureToggle = false,
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

  /// When paired with [obscureText], shows a trailing eye button that toggles
  /// the text between hidden and visible.
  final bool obscureToggle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;

  /// Static leading text baked into the field (e.g. a `+20` dial prefix).
  final String? prefixText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final showToggle = widget.obscureText && widget.obscureToggle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(widget.label!, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: AppSpacing.xs),
        ],
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          decoration: InputDecoration(
            hintText: widget.hint,
            errorText: widget.errorText,
            prefixText: widget.prefixText,
            prefixIcon: widget.prefixIcon == null
                ? null
                : Icon(widget.prefixIcon),
            suffixIcon: showToggle
                ? IconButton(
                    onPressed: () => setState(() => _obscured = !_obscured),
                    icon: Icon(
                      _obscured ? Icons.visibility_off : Icons.visibility,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
