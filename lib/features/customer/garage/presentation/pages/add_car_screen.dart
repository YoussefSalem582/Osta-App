import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/garage/data/car_catalog.dart';
import 'package:osta/features/customer/garage/data/model/garage_response/datum.dart';
import 'package:osta/features/customer/garage/presentation/cubit/garage_cubit.dart';
import 'package:osta/features/customer/garage/presentation/cubit/garage_state.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({this.vehicle, this.parentCubit, super.key});

  /// Non-null in edit mode; prefills the form and switches the submit call
  /// from `addVehicle` to `updateVehicle`.
  final Datum? vehicle;

  /// The caller's garage cubit (add mode), refreshed after a successful add so
  /// the list updates without relying on the pop return value.
  final GarageCubit? parentCubit;

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final _formKey = GlobalKey<FormState>();

  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _mileageController = TextEditingController();
  final _plateController = TextEditingController();
  final _colorController = TextEditingController();

  String? _brand;
  String? _model;
  int? _year;

  static const _earliestYear = 1980;

  bool get _brandIsOther => _brand == otherOption;
  bool get _modelIsOther => _model == otherOption;

  List<int> get _years {
    final latest = DateTime.now().year + 1;
    return [for (var y = latest; y >= _earliestYear; y--) y];
  }

  @override
  void initState() {
    super.initState();
    final vehicle = widget.vehicle;
    if (vehicle == null) return;

    _plateController.text = vehicle.plateNumber?.toString() ?? '';
    _mileageController.text = vehicle.currentMileage == null
        ? ''
        : '${(vehicle.currentMileage as num).toInt()}';
    _colorController.text = vehicle.color ?? '';
    _year = vehicle.year;

    final make = vehicle.make;
    if (make != null && carBrands.contains(make)) {
      _brand = make;
    } else {
      _brand = otherOption;
      _brandController.text = make ?? '';
    }

    final model = vehicle.model;
    if (!_brandIsOther && model != null && modelsFor(_brand).contains(model)) {
      _model = model;
    } else {
      _model = otherOption;
      _modelController.text = model ?? '';
    }
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
    if (year == null) return; 

    final make = _brandIsOther ? _brandController.text.trim() : _brand!;
    // An "Other" brand hides the model dropdown entirely, so _model is null
    // there and the free-text field is the only source.
    final model = (_brandIsOther || _modelIsOther)
        ? _modelController.text.trim()
        : _model!;
    final plateNumber = _plateController.text.trim();
    final currentMileage = int.tryParse(_mileageController.text.trim());
    final color = _colorController.text.trim().isEmpty
        ? null
        : _colorController.text.trim();

    final vehicle = widget.vehicle;
    if (vehicle == null) {
      unawaited(
        context.read<GarageCubit>().addVehicle(
          make: make,
          model: model,
          year: year,
          plateNumber: plateNumber,
          currentMileage: currentMileage,
          color: color,
        ),
      );
    } else {
      unawaited(
        context.read<GarageCubit>().updateVehicle(
          vehicleId: vehicle.id!,
          make: make,
          model: model,
          year: year,
          plateNumber: plateNumber,
          currentMileage: currentMileage,
          color: color,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GarageCubit>(
      create: (_) => GarageCubit(),
      child: BlocConsumer<GarageCubit, GarageState>(
        listenWhen: (_, current) =>
            current is GarageAddSuccess ||
            current is GarageAddError ||
            current is GarageUpdateSuccess ||
            current is GarageUpdateError,
        listener: (context, state) async {
          if (state is GarageAddSuccess) {
            AppToaster.showMessage(context.l10n.saveAndProceed);
            unawaited(context.read<SessionController>().markVehicleAdded());
            if (widget.parentCubit != null) {
              await widget.parentCubit!.getVehicles();
            }
            if (context.mounted) {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.customerShell);
              }
            }
          } else if (state is GarageUpdateSuccess) {
            AppToaster.showMessage(context.l10n.vehicleUpdated);
            context.pop(true);
          } else if (state is GarageAddError) {
            AppToaster.showError(state.message);
          } else if (state is GarageUpdateError) {
            AppToaster.showError(state.message);
          }
        },
        builder: (context, state) {
          final isLoading =
              state is GarageAddLoading ||
              state is GarageAddSuccess ||
              state is GarageUpdateLoading ||
              state is GarageUpdateSuccess;
          final colorScheme = Theme.of(context).colorScheme;
          final textTheme = Theme.of(context).textTheme;
          final l10n = context.l10n;
          final isGating =
              context.read<SessionController>().state.hasVehicle == false;

          return Scaffold(
            appBar: AppTopBar(
              centerTitle: false,
              title: widget.vehicle != null
                  ? l10n.editCarTitle
                  : (isGating ? l10n.addYourFirstCar : l10n.addCar),
            ),
            body: Form(
              key: _formKey,
              child: Column(
                children: [
                  if (widget.vehicle == null) ...[
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
                  ] else
                    const SizedBox(height: AppSpacing.lg),

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
