import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _mileageController = TextEditingController();
  final _plateController = TextEditingController();

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _mileageController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {}
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppTopBar(
        centerTitle: false,
        title: l10n.addYourFirstCar,
        subtitle: l10n.requiredStep,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Row(
                  children: [
                    const Text('🚗', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.carDetailsPrompt,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                child: Column(
                  children: [
                    AppTextField(
                      label: l10n.brand,
                      hint: l10n.brandHint,
                      controller: _brandController,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.enterBrand : null,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: l10n.model,
                      hint: l10n.modelHint,
                      controller: _modelController,
                      textInputAction: TextInputAction.next,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? l10n.enterModel : null,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: l10n.year,
                            hint: l10n.yearHint,
                            controller: _yearController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.isEmpty)
                                ? l10n.enterYear
                                : null,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
                            label: l10n.mileage,
                            hint: l10n.mileageHint,
                            controller: _mileageController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            validator: (v) => (v == null || v.isEmpty)
                                ? l10n.enterMileage
                                : null,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    AppTextField(
                      label: l10n.plateNumber,
                      hint: l10n.plateNumberHint,
                      controller: _plateController,
                      textInputAction: TextInputAction.done,
                      validator: (v) => (v == null || v.isEmpty)
                          ? l10n.enterPlateNumber
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.saveAndProceed,
                  onPressed: _onSave,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
