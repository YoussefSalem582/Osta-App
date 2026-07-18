import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/data/repo/business_service_repo.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_segmented_toggle.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// Create or edit one catalogue service. Pops with `true` on a successful save.
class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({this.service, super.key});

  final Service? service;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  static const _priceTypes = ['fixed', 'starting_from', 'hourly'];

  // Same wire values as the onboarding wizard's category filter
  // (`business_catalog_page.dart`'s `_categoryForChip`) — index 3 is "Other",
  // which reveals the free-text field below for anything outside this preset
  // set (the backend has no enum for `category`, so custom values are valid).
  static const _presetCategories = ['oil', 'brakes', 'ac'];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _category;
  late final TextEditingController _duration;
  late final TextEditingController _description;
  late String _priceType;
  late int _categorySelection;
  late bool _isActive;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _name = TextEditingController(text: s?.name ?? '');
    _price = TextEditingController(
      text: s == null ? '' : s.price.toStringAsFixed(0),
    );
    final existingCategory = s?.category;
    _categorySelection =
        existingCategory != null && _presetCategories.contains(existingCategory)
        ? _presetCategories.indexOf(existingCategory)
        : _presetCategories.length;
    _category = TextEditingController(
      text: _categorySelection == _presetCategories.length
          ? (existingCategory ?? '')
          : '',
    );
    _duration = TextEditingController(
      text: s?.durationMinutes == null ? '' : '${s!.durationMinutes}',
    );
    _description = TextEditingController(text: s?.description ?? '');
    _priceType = _priceTypes.contains(s?.priceType) ? s!.priceType : 'fixed';
    _isActive = s?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _category.dispose();
    _duration.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final l10n = context.l10n;
    final price = num.tryParse(_price.text.trim()) ?? 0;
    final duration = int.tryParse(_duration.text.trim());
    final category = _categorySelection < _presetCategories.length
        ? _presetCategories[_categorySelection]
        : _category.text.trim();
    final description = _description.text.trim();
    try {
      final existing = widget.service;
      if (existing == null) {
        await BusinessServiceRepo.create(
          name: _name.text.trim(),
          price: price,
          priceType: _priceType,
          category: category.isEmpty ? null : category,
          durationMinutes: duration,
          description: description.isEmpty ? null : description,
          isActive: _isActive,
        );
      } else {
        await BusinessServiceRepo.updateService(
          existing.id,
          name: _name.text.trim(),
          price: price,
          priceType: _priceType,
          category: category.isEmpty ? null : category,
          durationMinutes: duration,
          description: description.isEmpty ? null : description,
          isActive: _isActive,
        );
      }
      if (!mounted) return;
      AppToaster.showMessage(l10n.serviceSaved);
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) AppToaster.showError(e.message);
    } on Object catch (_) {
      if (mounted) AppToaster.showError(l10n.serviceSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.service != null;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        centerTitle: false,
        title: isEdit ? l10n.serviceEditTitle : l10n.serviceAddTitle,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppTextField(
                controller: _name,
                label: l10n.serviceName,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.serviceNameRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _price,
                label: l10n.servicePrice,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => (num.tryParse(v?.trim() ?? '') == null)
                    ? l10n.servicePriceRequired
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.servicePriceType,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              AppSegmentedToggle(
                options: [
                  l10n.servicePriceFixed,
                  l10n.servicePriceStartingFrom,
                  l10n.servicePriceHourly,
                ],
                selectedIndex: _priceTypes.indexOf(_priceType),
                onSelect: (i) => setState(() => _priceType = _priceTypes[i]),
                expand: true,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.serviceCategoryLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: AppSegmentedToggle(
                  options: [
                    l10n.businessCatalogFilterOils,
                    l10n.businessCatalogFilterBrakes,
                    l10n.businessCatalogFilterAc,
                    l10n.serviceCategoryOther,
                  ],
                  selectedIndex: _categorySelection,
                  onSelect: (i) => setState(() => _categorySelection = i),
                ),
              ),
              if (_categorySelection == _presetCategories.length) ...[
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  controller: _category,
                  label: l10n.serviceCategory,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _duration,
                label: l10n.serviceDuration,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _description,
                label: l10n.serviceDescription,
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
                title: Text(l10n.serviceActive),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppButton(
                label: l10n.save,
                onPressed: _saving ? null : _submit,
                loading: _saving,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
