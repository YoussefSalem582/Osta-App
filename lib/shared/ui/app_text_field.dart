import 'package:flutter/material.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// Brand text field — thin wrapper over [TextFormField]; visual styling
/// comes from the shared [InputDecorationTheme] (flat fill, brand focus ring,
/// error ring, focus-tinted icons).
///
/// [label] is a Material **floating label**: it sits inside the field as the
/// placeholder when empty, then floats to the border (in the brand colour) once
/// focused or filled — so the placeholder always reads as the field's name and
/// stays visually distinct from typed text. [hint] is an optional example shown
/// only while focused (e.g. a phone format).
///
/// Set [obscureToggle] on a password field to render a show/hide eye button
/// that flips [obscureText] locally (state lives in the field, not the caller).
/// Pass a [prefix] widget (e.g. a `+20` dial code) for an always-visible
/// leading element, or [prefixIcon] for a leading icon.
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
    this.textCapitalization = TextCapitalization.none,
    this.prefixIcon,
    this.prefix,
    this.autofillHints,
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
  final TextCapitalization textCapitalization;

  /// Leading icon (e.g. a mail or lock glyph). Ignored when [prefix] is set.
  final IconData? prefixIcon;

  /// Always-visible custom leading widget (e.g. a `+20` dial prefix). Takes
  /// precedence over [prefixIcon].
  final Widget? prefix;

  /// OS autofill / password-manager hints (e.g. `[AutofillHints.email]`).
  final Iterable<String>? autofillHints;

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
    final leading =
        widget.prefix ??
        (widget.prefixIcon == null ? null : Icon(widget.prefixIcon));
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      validator: widget.validator,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: leading,
        // Let a custom [prefix] size to its content instead of the default
        // 48px icon box.
        prefixIconConstraints: widget.prefix == null
            ? null
            : const BoxConstraints(),
        suffixIcon: showToggle
            ? IconButton(
                tooltip: _obscured
                    ? context.l10n.showPassword
                    : context.l10n.hidePassword,
                onPressed: () => setState(() => _obscured = !_obscured),
                icon: Icon(
                  _obscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : null,
      ),
    );
  }
}
