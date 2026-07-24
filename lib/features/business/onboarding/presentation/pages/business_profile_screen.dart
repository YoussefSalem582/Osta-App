import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osta/core/network/api_exception.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/dashboard/data/model/business_dashboard.dart';
import 'package:osta/features/business/onboarding/data/business_onboarding_repository.dart';
import 'package:osta/features/business/onboarding/data/models/business_profile_input.dart';
import 'package:osta/features/business/onboarding/presentation/business_location_picker_mixin.dart';
import 'package:osta/features/business/onboarding/presentation/business_profile_loader.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/business_logo_field.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/business_type_dropdown.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/founding_year_dropdown.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/location_picker_card.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';
import 'package:osta/features/shared/auth/presentation/widgets/dial_prefix.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Center profile editor — prefills from `GET` and saves via partial
/// `PUT /business/profile`; mirrors onboarding's identity step but lives under the business More tab.
class BusinessProfilePage extends StatefulWidget {
  const BusinessProfilePage({super.key});

  @override
  State<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends State<BusinessProfilePage>
    with BusinessLocationPickerMixin<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _tradeName = TextEditingController();
  final _legalName = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _district = TextEditingController();

  String _businessType = 'workshop';
  int? _yearFounded;
  GeoPoint? _location;
  String? _existingLogoUrl;
  String? _newLogoPath;

  bool _loading = true;
  String? _loadError;
  bool _showLocationError = false;
  bool _saving = false;

  @override
  GeoPoint? get pickerLocation => _location;

  @override
  TextEditingController get cityController => _city;

  @override
  TextEditingController get addressController => _address;

  @override
  TextEditingController? get districtController => _district;

  @override
  void onLocationPicked(GeoPoint point) {
    setState(() {
      _location = point;
      _showLocationError = false;
    });
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _tradeName.dispose();
    _legalName.dispose();
    _phone.dispose();
    _city.dispose();
    _address.dispose();
    _district.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    await loadBusinessProfile(
      logTag: 'BusinessProfilePage',
      onLoaded: (profile) {
        if (!mounted) return;
        setState(() {
          _prefill(profile);
          _loading = false;
        });
      },
      onBlank: () {
        if (!mounted) return;
        setState(() => _loading = false);
      },
      onError: (message) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _loadError = message;
        });
      },
    );
  }

  void _prefill(BusinessProfile p) {
    _tradeName.text = p.tradeName;
    _legalName.text = p.legalName ?? '';
    _phone.text = p.phone ?? '';
    _city.text = p.city ?? '';
    _address.text = p.addressLine ?? '';
    _district.text = p.district ?? '';
    _businessType = BusinessTypeDropdown.businessTypes.contains(p.businessType)
        ? p.businessType
        : 'workshop';
    _yearFounded = p.yearFounded;
    _existingLogoUrl = p.logoUrl;
    final lat = p.location.latitude;
    final lng = p.location.longitude;
    _location = (lat != null && lng != null) ? (lat: lat, lng: lng) : null;
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _newLogoPath = picked.path);
    }
  }

  Future<void> _submit() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    final hasLocation = _location != null;
    setState(() => _showLocationError = !hasLocation);
    if (!formOk || !hasLocation) return;

    setState(() => _saving = true);
    final l10n = context.l10n;
    String? clean(TextEditingController c) {
      final t = c.text.trim();
      return t.isEmpty ? null : t;
    }

    try {
      await GetIt.instance<BusinessOnboardingRepository>().updateProfile(
        BusinessProfileInput(
          tradeName: clean(_tradeName),
          legalName: clean(_legalName),
          phone: clean(_phone),
          businessType: _businessType,
          yearFounded: _yearFounded,
          city: clean(_city),
          addressLine: clean(_address),
          district: clean(_district),
          latitude: _location?.lat,
          longitude: _location?.lng,
          logoPath: _newLogoPath,
        ),
      );
      if (!mounted) return;
      AppToaster.showMessage(l10n.businessProfileSaved);
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (mounted) AppToaster.showError(e.message);
    } on Object catch (_) {
      if (mounted) AppToaster.showError(l10n.businessProfileSaveError);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppTopBar(
        title: l10n.businessProfileTitle,
        subtitle: l10n.businessProfileSubtitle,
      ),
      body: SafeArea(child: _body(context)),
    );
  }

  Widget _body(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }
    if (_loadError != null) {
      return ErrorState(
        title: l10n.businessProfileErrorTitle,
        message: _loadError,
        onRetry: () => unawaited(_load()),
      );
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BusinessLogoField(
                    existingLogoUrl: _existingLogoUrl,
                    newLogoPath: _newLogoPath,
                    onPickLogo: () => unawaited(_pickLogo()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: l10n.businessOnboardingTradeNameLabel,
                    controller: _tradeName,
                    textInputAction: TextInputAction.next,
                    validator: (v) => AuthValidators.requiredField(context, v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: l10n.businessOnboardingLegalNameLabel,
                    controller: _legalName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: l10n.businessOnboardingPhoneLabel,
                    controller: _phone,
                    prefix: const DialPrefix(),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: (v) => AuthValidators.egyptPhone(context, v),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  LocationPickerCard(
                    hasLocation: _location != null,
                    latitude: _location?.lat,
                    longitude: _location?.lng,
                    hasError: _showLocationError,
                    onTap: () => unawaited(pickLocation()),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: BusinessTypeDropdown(
                          value: _businessType,
                          onChanged: (v) => setState(() => _businessType = v),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: AppTextField(
                          label: l10n.businessOnboardingCityLabel,
                          controller: _city,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: l10n.businessOnboardingAddressLabel,
                    controller: _address,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: l10n.addressDistrict,
                    controller: _district,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FoundingYearDropdown(
                    value: _yearFounded,
                    onChanged: (v) => setState(() => _yearFounded = v),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppButton(
            label: l10n.save,
            loading: _saving,
            onPressed: _saving ? null : _submit,
          ),
        ),
      ],
    );
  }
}
