import 'package:flutter/material.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/profile/data/model/address.dart';
import 'package:osta/features/shared/profile/data/repo/address_repo.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_segmented_toggle.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// Create / edit a saved address; pops `true` on save. PUT is full-replace, so
/// the map pin (lat/lng) is carried through unseen to avoid wiping it.
class AddressFormScreen extends StatefulWidget {
  const AddressFormScreen({this.address, super.key});

  /// Null = create mode; non-null = edit that address.
  final Address? address;

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  static const _labels = ['home', 'work', 'other'];

  final _formKey = GlobalKey<FormState>();
  late String _label;
  late final TextEditingController _recipientName;
  late final TextEditingController _recipientPhone;
  late final TextEditingController _line1;
  late final TextEditingController _line2;
  late final TextEditingController _city;
  late final TextEditingController _district;
  late final TextEditingController _building;
  late final TextEditingController _floor;
  late final TextEditingController _apartment;
  late final TextEditingController _landmark;
  late final TextEditingController _note;
  late bool _isDefault;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _label = _labels.contains(a?.label) ? a!.label : 'home';
    _recipientName = TextEditingController(text: a?.recipientName ?? '');
    _recipientPhone = TextEditingController(text: a?.recipientPhone ?? '');
    _line1 = TextEditingController(text: a?.line1 ?? '');
    _line2 = TextEditingController(text: a?.line2 ?? '');
    _city = TextEditingController(text: a?.city ?? '');
    _district = TextEditingController(text: a?.district ?? '');
    _building = TextEditingController(text: a?.buildingNumber ?? '');
    _floor = TextEditingController(text: a?.floorNumber ?? '');
    _apartment = TextEditingController(text: a?.apartmentNumber ?? '');
    _landmark = TextEditingController(text: a?.landmark ?? '');
    _note = TextEditingController(text: a?.note ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _recipientName.dispose();
    _recipientPhone.dispose();
    _line1.dispose();
    _line2.dispose();
    _city.dispose();
    _district.dispose();
    _building.dispose();
    _floor.dispose();
    _apartment.dispose();
    _landmark.dispose();
    _note.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildBody() {
    String? clean(TextEditingController c) {
      final t = c.text.trim();
      return t.isEmpty ? null : t;
    }

    final body = <String, dynamic>{
      'label': _label,
      'recipient_name': clean(_recipientName),
      'recipient_phone': clean(_recipientPhone),
      'line1': clean(_line1),
      'line2': clean(_line2),
      'city': clean(_city),
      'district': clean(_district),
      'building_number': clean(_building),
      'floor_number': clean(_floor),
      'apartment_number': clean(_apartment),
      'landmark': clean(_landmark),
      'note': clean(_note),
      'is_default': _isDefault,
    };
    // PUT is full-replace: carry the existing map pin through so editing the
    // text fields doesn't null out latitude/longitude server-side.
    final existing = widget.address;
    if (existing != null) {
      body['latitude'] = existing.latitude;
      body['longitude'] = existing.longitude;
    }
    return body;
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    final l10n = context.l10n;
    try {
      final body = _buildBody();
      final existing = widget.address;
      if (existing == null) {
        await AddressRepo.create(body);
      } else {
        await AddressRepo.update(existing.id, body);
      }
      if (!mounted) return;
      AppToaster.showMessage(l10n.addressSaved);
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) AppToaster.showError(e.message);
    } on Object catch (_) {
      if (mounted) AppToaster.showError(l10n.addressSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEdit = widget.address != null;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppTopBar(
        centerTitle: false,
        title: isEdit ? l10n.editAddress : l10n.addAddress,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              AppSegmentedToggle(
                options: [
                  l10n.addressLabelHome,
                  l10n.addressLabelWork,
                  l10n.addressLabelOther,
                ],
                selectedIndex: _labels.indexOf(_label),
                onSelect: (i) => setState(() => _label = _labels[i]),
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _recipientName,
                label: l10n.addressRecipientName,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _recipientPhone,
                label: l10n.addressRecipientPhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _line1,
                label: l10n.addressLine1,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? l10n.addressLine1Required
                    : null,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(controller: _line2, label: l10n.addressLine2),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _city,
                      label: l10n.addressCity,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _district,
                      label: l10n.addressDistrict,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _building,
                      label: l10n.addressBuilding,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _floor,
                      label: l10n.addressFloor,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      controller: _apartment,
                      label: l10n.addressApartment,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(controller: _landmark, label: l10n.addressLandmark),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: _note,
                label: l10n.addressNote,
                minLines: 2,
                maxLines: 4,
              ),
              const SizedBox(height: AppSpacing.sm),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                value: _isDefault,
                onChanged: (v) => setState(() => _isDefault = v),
                title: Text(l10n.addressSetDefault),
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
