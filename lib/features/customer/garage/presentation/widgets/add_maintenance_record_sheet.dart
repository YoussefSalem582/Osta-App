import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/customer/garage/presentation/cubit/maintenance_cubit.dart';
import 'package:osta/features/customer/garage/presentation/cubit/maintenance_state.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/adaptive_pickers.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';

/// Add-one-record form, shown as a modal sheet over `MaintenanceScreen` and
/// sharing that screen's `MaintenanceCubit` instance (same vehicle, no need
/// for a second one). Pops `true` on a successful save so the caller knows to
/// reload history; pops nothing (stays open) on error so the user can retry.
///
/// Receipt upload is a deliberate scope cut — `MaintenanceRepo.addRecord`
/// accepts an optional `receiptPath`, but no image/file picker is wired here.
class AddMaintenanceRecordSheet extends StatefulWidget {
  const AddMaintenanceRecordSheet({super.key});

  @override
  State<AddMaintenanceRecordSheet> createState() =>
      _AddMaintenanceRecordSheetState();
}

class _AddMaintenanceRecordSheetState extends State<AddMaintenanceRecordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _mileageController = TextEditingController();
  final _costController = TextEditingController();

  String? _type;
  DateTime? _performedAt;
  bool _dateError = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _mileageController.dispose();
    _costController.dispose();
    super.dispose();
  }

  List<(String value, String label)> _typeOptions(AppLocalizations l10n) => [
    ('fuel', l10n.maintenanceTypeFuel),
    ('parts', l10n.maintenanceTypeParts),
    ('salary', l10n.maintenanceTypeSalary),
    ('rent', l10n.maintenanceTypeRent),
    ('utilities', l10n.maintenanceTypeUtilities),
    ('other', l10n.maintenanceTypeOther),
  ];

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showAdaptiveDatePicker(
      context: context,
      // performed_at must be today-or-earlier server-side.
      firstDate: DateTime(now.year - 15),
      lastDate: now,
      initialDate: _performedAt ?? now,
    );
    if (date == null) return;
    setState(() {
      _performedAt = date;
      _dateError = false;
    });
  }

  String? _validateNumber(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return null;
    return num.tryParse(value.trim()) == null
        ? l10n.maintenanceValidationNumber
        : null;
  }

  void _onSave(BuildContext context) {
    final formValid = _formKey.currentState?.validate() ?? false;
    setState(() => _dateError = _performedAt == null);
    if (!formValid || _performedAt == null) return;

    final description = _descriptionController.text.trim();
    unawaited(
      context.read<MaintenanceCubit>().addRecord(
        type: _type!,
        performedAt: _performedAt!,
        description: description.isEmpty ? null : description,
        mileage: int.tryParse(_mileageController.text.trim()),
        cost: double.tryParse(_costController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return BlocConsumer<MaintenanceCubit, MaintenanceState>(
      listenWhen: (_, current) =>
          current is MaintenanceAddSuccess || current is MaintenanceAddError,
      listener: (context, state) {
        if (state is MaintenanceAddSuccess) {
          Navigator.of(context).pop(true);
        } else if (state is MaintenanceAddError) {
          AppToaster.showError(state.message);
        }
      },
      buildWhen: (_, current) =>
          current is MaintenanceAddLoading ||
          current is MaintenanceAddSuccess ||
          current is MaintenanceAddError,
      builder: (context, state) {
        final isSaving = state is MaintenanceAddLoading;
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.maintenanceAddRecordTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  DropdownButtonFormField<String>(
                    initialValue: _type,
                    decoration: InputDecoration(
                      labelText: l10n.maintenanceType,
                    ),
                    items: [
                      for (final option in _typeOptions(l10n))
                        DropdownMenuItem(
                          value: option.$1,
                          child: Text(option.$2),
                        ),
                    ],
                    onChanged: isSaving
                        ? null
                        : (v) => setState(() => _type = v),
                    validator: (v) =>
                        v == null ? l10n.maintenanceSelectType : null,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  InkWell(
                    onTap: isSaving ? null : _pickDate,
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: l10n.maintenanceDate,
                        errorText: _dateError
                            ? l10n.maintenanceSelectDate
                            : null,
                      ),
                      child: Text(
                        _performedAt == null
                            ? l10n.maintenanceSelectDate
                            : DateFormat.yMMMd(locale).format(_performedAt!),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  AppTextField(
                    label: l10n.maintenanceDescription,
                    controller: _descriptionController,
                    enabled: !isSaving,
                    maxLines: 2,
                  ),
                  const SizedBox(height: AppSpacing.md),

                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          label: l10n.maintenanceMileage,
                          controller: _mileageController,
                          enabled: !isSaving,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) => _validateNumber(v, l10n),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: l10n.maintenanceCost,
                          controller: _costController,
                          enabled: !isSaving,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp('[0-9.]'),
                            ),
                          ],
                          validator: (v) => _validateNumber(v, l10n),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: l10n.saveAndProceed,
                      loading: isSaving,
                      onPressed: isSaving ? null : () => _onSave(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
