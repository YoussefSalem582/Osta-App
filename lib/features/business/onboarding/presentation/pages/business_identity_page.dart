import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/services/location_service.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/business_location_picker_mixin.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_onboarding_cubit.dart';
import 'package:osta/features/business/onboarding/presentation/pages/business_catalog_page.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/business_type_dropdown.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/founding_year_dropdown.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/location_picker_card.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/logo_upload_box.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/step_header.dart';
import 'package:osta/features/shared/auth/presentation/validators/auth_validators.dart';
import 'package:osta/features/shared/auth/presentation/widgets/dial_prefix.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// Step 1 — business identity & location.
class BusinessIdentityPage extends StatefulWidget {
  const BusinessIdentityPage({super.key});

  static const String path = AppRoutes.businessIdentity;

  @override
  State<BusinessIdentityPage> createState() => _BusinessIdentityPageState();
}

class _BusinessIdentityPageState extends State<BusinessIdentityPage>
    with BusinessLocationPickerMixin<BusinessIdentityPage> {
  final _formKey = GlobalKey<FormState>();
  final _tradeName = TextEditingController();
  final _legalName = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  bool _showLocationError = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<BusinessOnboardingCubit>().state;
    _tradeName.text = state.tradeName;
    _legalName.text = state.legalName;
    _phone.text = state.phone;
    _city.text = state.city;
    _address.text = state.addressLine;
  }

  @override
  void dispose() {
    _tradeName.dispose();
    _legalName.dispose();
    _phone.dispose();
    _city.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      context.read<BusinessOnboardingCubit>().setLogoPath(picked.path);
    }
  }

  @override
  GeoPoint? get pickerLocation {
    final state = context.read<BusinessOnboardingCubit>().state;
    return state.hasLocation
        ? (lat: state.latitude!, lng: state.longitude!)
        : null;
  }

  @override
  TextEditingController get cityController => _city;

  @override
  TextEditingController get addressController => _address;

  @override
  void onLocationPicked(GeoPoint point) {
    context.read<BusinessOnboardingCubit>().setLocation(point);
    setState(() => _showLocationError = false);
  }

  void _onBusinessTypeChanged(String value) =>
      context.read<BusinessOnboardingCubit>().updateBusinessType(value);

  void _onYearFoundedChanged(int value) =>
      context.read<BusinessOnboardingCubit>().updateYearFounded(value);

  void _submit() {
    // Sync controllers → cubit before submit.
    final cubit = context.read<BusinessOnboardingCubit>()
      ..updateTradeName(_tradeName.text)
      ..updateLegalName(_legalName.text)
      ..updatePhone(_phone.text)
      ..updateCity(_city.text)
      ..updateAddressLine(_address.text);

    final formOk = _formKey.currentState?.validate() ?? false;
    final hasLocation = cubit.state.hasLocation;
    // Re-derive every submit so a fixed location clears the card error too.
    setState(() => _showLocationError = !hasLocation);
    if (!formOk || !hasLocation) return;
    unawaited(cubit.submitProfile());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<BusinessOnboardingCubit, BusinessOnboardingState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == BusinessOnboardingStatus.profileSubmitted) {
          context.read<BusinessOnboardingCubit>().acknowledgeNavigation();
          unawaited(context.push(BusinessCatalogPage.path));
        } else if (state.status == BusinessOnboardingStatus.failure &&
            state.fieldErrors.isEmpty) {
          AppToaster.showError(
            state.networkError
                ? context.l10n.errorNetwork
                : (state.errorMessage ?? context.l10n.errorGeneric),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppTopBar(
            title: l10n.businessOnboardingTitle,
            subtitle: l10n.businessOnboardingLiveInstantly,
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _BusinessIdentityForm(
                    formKey: _formKey,
                    state: state,
                    tradeNameController: _tradeName,
                    legalNameController: _legalName,
                    phoneController: _phone,
                    cityController: _city,
                    addressController: _address,
                    showLocationError: _showLocationError,
                    onPickLogo: () => unawaited(_pickLogo()),
                    onPickLocation: () => unawaited(pickLocation()),
                    onBusinessTypeChanged: _onBusinessTypeChanged,
                    onYearFoundedChanged: _onYearFoundedChanged,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: AppButton(
                    label: l10n.businessOnboardingContinueToCatalog,
                    loading: state.isSubmittingProfile,
                    onPressed: state.isSubmittingProfile ? null : _submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The scrollable form body — trade/legal name, phone, location, business
/// type and year founded. Split out of [_BusinessIdentityPageState.build] so
/// that method stays scaffold + BlocConsumer wiring only.
class _BusinessIdentityForm extends StatelessWidget {
  const _BusinessIdentityForm({
    required this.formKey,
    required this.state,
    required this.tradeNameController,
    required this.legalNameController,
    required this.phoneController,
    required this.cityController,
    required this.addressController,
    required this.showLocationError,
    required this.onPickLogo,
    required this.onPickLocation,
    required this.onBusinessTypeChanged,
    required this.onYearFoundedChanged,
  });

  final GlobalKey<FormState> formKey;
  final BusinessOnboardingState state;
  final TextEditingController tradeNameController;
  final TextEditingController legalNameController;
  final TextEditingController phoneController;
  final TextEditingController cityController;
  final TextEditingController addressController;
  final bool showLocationError;
  final VoidCallback onPickLogo;
  final VoidCallback onPickLocation;
  final ValueChanged<String> onBusinessTypeChanged;
  final ValueChanged<int> onYearFoundedChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StepHeader(
              currentStep: 1,
              totalSteps: 2,
              stepText: l10n.businessOnboardingStep1Indicator,
            ),
            const SizedBox(height: AppSpacing.lg),
            LogoUploadBox(onTap: onPickLogo, imagePath: state.logoPath),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              label: l10n.businessOnboardingTradeNameLabel,
              hint: l10n.businessOnboardingTradeNameHint,
              controller: tradeNameController,
              textInputAction: TextInputAction.next,
              errorText: state.fieldErrors['trade_name']?.first,
              validator: (v) => AuthValidators.requiredField(context, v),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.businessOnboardingLegalNameLabel,
              hint: l10n.businessOnboardingLegalNameHint,
              controller: legalNameController,
              textInputAction: TextInputAction.next,
              errorText: state.fieldErrors['legal_name']?.first,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.businessOnboardingPhoneLabel,
              hint: l10n.businessOnboardingPhoneHint,
              controller: phoneController,
              prefix: const DialPrefix(),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              errorText: state.fieldErrors['phone']?.first,
              validator: (v) => AuthValidators.egyptPhone(context, v),
            ),
            const SizedBox(height: AppSpacing.lg),
            LocationPickerCard(
              hasLocation: state.hasLocation,
              latitude: state.latitude,
              longitude: state.longitude,
              hasError: showLocationError,
              onTap: onPickLocation,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: BusinessTypeDropdown(
                    key: ValueKey(state.businessType),
                    value: state.businessType,
                    onChanged: onBusinessTypeChanged,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppTextField(
                    label: l10n.businessOnboardingCityLabel,
                    hint: l10n.businessOnboardingCityValue,
                    controller: cityController,
                    textInputAction: TextInputAction.next,
                    errorText: state.fieldErrors['city']?.first,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.businessOnboardingAddressLabel,
              hint: l10n.businessOnboardingAddressHint,
              controller: addressController,
              textInputAction: TextInputAction.done,
              errorText: state.fieldErrors['address_line']?.first,
            ),
            const SizedBox(height: AppSpacing.md),
            FoundingYearDropdown(
              value: state.yearFounded,
              errorText: state.fieldErrors['year_founded']?.first,
              onChanged: onYearFoundedChanged,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
