import 'package:flutter/material.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/data/models/custom_service_input.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';

/// Bottom sheet for a merchant-typed service; returns the [CustomServiceInput]
/// to stage, or null if dismissed. Validation mirrors `StoreServiceRequest` so
/// Activate can't 422 on it.
class AddCustomServiceSheet extends StatefulWidget {
  const AddCustomServiceSheet({super.key});

  static Future<CustomServiceInput?> show(BuildContext context) =>
      showModalBottomSheet<CustomServiceInput>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const AddCustomServiceSheet(),
      );

  @override
  State<AddCustomServiceSheet> createState() => _AddCustomServiceSheetState();
}

class _AddCustomServiceSheetState extends State<AddCustomServiceSheet> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _category = TextEditingController();
  final _price = TextEditingController();
  final _duration = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _category.dispose();
    _price.dispose();
    _duration.dispose();
    super.dispose();
  }

  /// Backend: `numeric|min:0|max:99999999.99`.
  String? _validatePrice(String? value, AppLocalizations l10n) {
    final price = double.tryParse((value ?? '').trim());
    if (price == null || price < 0 || price > 99999999.99) {
      return l10n.validationPrice;
    }
    return null;
  }

  /// Optional, but `integer|min:1|max:1440` when given.
  String? _validateDuration(String? value, AppLocalizations l10n) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return null;
    final minutes = int.tryParse(text);
    if (minutes == null || minutes < 1 || minutes > 1440) {
      return l10n.validationDuration;
    }
    return null;
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final category = _category.text.trim();
    Navigator.of(context).pop(
      CustomServiceInput(
        name: _name.text.trim(),
        price: double.parse(_price.text.trim()),
        category: category.isEmpty ? null : category,
        durationMinutes: int.tryParse(_duration.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Padding(
      // Keeps the fields above the keyboard.
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.businessCustomServiceTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: l10n.businessCustomServiceName,
                hint: l10n.businessCustomServiceNameHint,
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.validationRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: l10n.businessCustomServiceCategory,
                controller: _category,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: AppTextField(
                      label: l10n.businessCustomServicePrice,
                      controller: _price,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (v) => _validatePrice(v, l10n),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: l10n.businessCustomServiceDuration,
                      controller: _duration,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      validator: (v) => _validateDuration(v, l10n),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.businessCustomServiceSave,
                onPressed: _submit,
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
