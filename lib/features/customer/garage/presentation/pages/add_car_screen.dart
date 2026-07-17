import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/garage/data/car_catalog.dart';
import 'package:osta/features/customer/garage/presentation/cubit/garage_cubit.dart';
import 'package:osta/features/customer/garage/presentation/cubit/garage_state.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  /// Free-text fallbacks, used only when the picker is on [otherOption].
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _mileageController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();

  String? _brand;
  String? _model;
  int? _year;

  /// #39 asks for 1980+; the backend allows back to 1900. Narrower on purpose —
  /// a dropdown of 120 years is worse than one of 40, and the server stays the
  /// real bound for anything older.
  static const _earliestYear = 1980;

  bool get _brandIsOther => _brand == otherOption;
  bool get _modelIsOther => _model == otherOption;

  List<int> get _years {
    final latest = DateTime.now().year + 1;
    return [for (var y = latest; y >= _earliestYear; y--) y];
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _mileageController.dispose();
    _plateController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  /// Mirrors `current_mileage`'s `integer|min:0`.
  String? _validateMileage(String? value, AppLocalizations l10n) {
    final required = AuthValidators.requiredField(
      context,
      value,
      message: l10n.enterMileage,
    );
    if (required != null) return required;
    final km = int.tryParse(value!.trim());
    return (km == null || km < 0) ? l10n.validationMileage : null;
  }

  /// Present, and within the backend's `max:20`.
  ///
  /// ponytail: deliberately no format regex. Egyptian plates vary by
  /// governorate and vintage (Arabic letters, Latin transliterations, differing
  /// digit counts), and this screen gates entry to the app — a false reject
  /// here locks a real customer out of Home with no way past. The server is the
  /// real guard; this only catches empty and absurd.
  String? _validatePlate(String? value, AppLocalizations l10n) {
    final required = AuthValidators.requiredField(
      context,
      value,
      message: l10n.enterPlateNumber,
    );
    if (required != null) return required;
    return value!.trim().length > 20 ? l10n.validationPlateLength : null;
  }

  void _onSave(BuildContext context) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final year = _year;
    if (year == null) return; // validator covers it; guard anyway

    context.read<GarageCubit>().addVehicle(
      make: _brandIsOther ? _brandController.text.trim() : _brand!,
      // An "Other" brand hides the model dropdown entirely, so _model is null
      // there and the free-text field is the only source.
      model: (_brandIsOther || _modelIsOther)
          ? _modelController.text.trim()
          : _model!,
      year: year,
      plateNumber: _plateController.text.trim(),
      currentMileage: int.tryParse(_mileageController.text.trim()),
      color: _colorController.text.trim().isEmpty
          ? null
          : _colorController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GarageCubit>(
      create: (_) => GarageCubit(),
      child: BlocConsumer<GarageCubit, GarageState>(
        listenWhen: (_, current) =>
            current is GarageAddSuccess || current is GarageAddError,
        listener: (context, state) {
          if (state is GarageAddSuccess) {
            AppToaster.showMessage(context.l10n.saveAndProceed);
            unawaited(context.read<SessionController>().markVehicleAdded());
            // Pushed from the garage → pop back to it. Forced by the #39 gate →
            // the router replaced the location, so there is nothing to pop and
            // the user must be sent on explicitly. Releasing the gate is not
            // enough on its own: once hasVehicle is true, resolveRedirect
            // allows /add-car (the garage pushes it to add an Nth car), so it
            // returns null and would leave the user sitting here.
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.customerShell);
            }
          } else if (state is GarageAddError) {
            AppToaster.showError(state.message);
          }
        },
        builder: (context, state) {
          // Stays locked after success, not just during flight: navigation is a
          // frame away, and a second tap in that window posts a second car.
          final isLoading =
              state is GarageAddLoading || state is GarageAddSuccess;
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          final l10n = context.l10n;
          // Only the gate is the *first* car; the garage's "+" adds an Nth.
          final isGating =
              context.read<SessionController>().state.hasVehicle == false;

          return Scaffold(
            appBar: AppTopBar(
              centerTitle: false,
              title: isGating ? l10n.addYourFirstCar : l10n.addCar,
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
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.5,
                        ),
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
                          DropdownButtonFormField<String>(
                            initialValue: _brand,
                            decoration: InputDecoration(labelText: l10n.brand),
                            items: [
                              for (final brand in carBrands)
                                DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand),
                                ),
                              DropdownMenuItem(
                                value: otherOption,
                                child: Text(l10n.carBrandOther),
                              ),
                            ],
                            onChanged: (v) => setState(() {
                              _brand = v;
                              // The model list is derived from the brand, so a
                              // stale pick would submit a mismatched pair.
                              _model = null;
                              _modelController.clear();
                            }),
                            validator: (v) =>
                                v == null ? l10n.enterBrand : null,
                          ),

                          if (_brandIsOther) ...[
                            const SizedBox(height: AppSpacing.sm),
                            AppTextField(
                              label: l10n.brand,
                              hint: l10n.carBrandOtherHint,
                              controller: _brandController,
                              textInputAction: TextInputAction.next,
                              validator: (v) => AuthValidators.requiredField(
                                context,
                                v,
                                message: l10n.enterBrand,
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.md),

                          // Depends on the brand; "Other" brand has no model
                          // list, so it goes straight to free text.
                          if (!_brandIsOther)
                            DropdownButtonFormField<String>(
                              initialValue: _model,
                              decoration: InputDecoration(
                                labelText: l10n.model,
                              ),
                              items: [
                                for (final model in modelsFor(_brand))
                                  DropdownMenuItem(
                                    value: model,
                                    child: Text(model),
                                  ),
                                DropdownMenuItem(
                                  value: otherOption,
                                  child: Text(l10n.carBrandOther),
                                ),
                              ],
                              onChanged: (v) => setState(() => _model = v),
                              validator: (v) =>
                                  v == null ? l10n.enterModel : null,
                            ),

                          if (_brandIsOther || _modelIsOther) ...[
                            if (!_brandIsOther)
                              const SizedBox(height: AppSpacing.sm),
                            AppTextField(
                              label: l10n.model,
                              hint: l10n.carModelOtherHint,
                              controller: _modelController,
                              textInputAction: TextInputAction.next,
                              validator: (v) => AuthValidators.requiredField(
                                context,
                                v,
                                message: l10n.enterModel,
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSpacing.md),

                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: _year,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    labelText: l10n.year,
                                  ),
                                  items: [
                                    for (final y in _years)
                                      DropdownMenuItem(
                                        value: y,
                                        child: Text('$y'),
                                      ),
                                  ],
                                  onChanged: (v) => setState(() => _year = v),
                                  validator: (v) =>
                                      v == null ? l10n.enterYear : null,
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
                                  validator: (v) => _validateMileage(v, l10n),
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
                            validator: (v) => _validatePlate(v, l10n),
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
                        loading: isLoading,
                        onPressed: isLoading ? null : () => _onSave(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
