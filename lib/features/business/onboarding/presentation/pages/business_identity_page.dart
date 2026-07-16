import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_onboarding_cubit.dart';
import 'package:osta/features/business/onboarding/presentation/pages/business_catalog_page.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/location_picker_card.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/logo_upload_box.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/map_pin_picker_sheet.dart';
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

  static const path = '/business-identity';

  @override
  State<BusinessIdentityPage> createState() => _BusinessIdentityPageState();
}

class _BusinessIdentityPageState extends State<BusinessIdentityPage> {
  final _formKey = GlobalKey<FormState>();
  final _tradeName = TextEditingController();
  final _legalName = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  String? _locationError;

  static const _businessTypes = [
    'workshop',
    'dealership',
    'mobile',
    'tire_shop',
    'car_wash',
  ];

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

  String _typeLabel(BuildContext context, String wire) {
    final l10n = context.l10n;
    return switch (wire) {
      'dealership' => l10n.businessTypeDealership,
      'mobile' => l10n.businessTypeMobile,
      'tire_shop' => l10n.businessTypeTireShop,
      'car_wash' => l10n.businessTypeCarWash,
      _ => l10n.businessTypeWorkshop,
    };
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

  Future<void> _pickLocation() async {
    final cubit = context.read<BusinessOnboardingCubit>();
    final state = cubit.state;
    final initial = state.hasLocation
        ? (lat: state.latitude!, lng: state.longitude!)
        : null;
    final point = await MapPinPickerSheet.show(context, initial: initial);
    if (point != null && mounted) {
      cubit.setLocation(point);
      setState(() => _locationError = null);
    }
  }

  void _submit() {
    final cubit = context.read<BusinessOnboardingCubit>();
    final l10n = context.l10n;
    // Sync controllers → cubit before submit.
    cubit
      ..updateTradeName(_tradeName.text)
      ..updateLegalName(_legalName.text)
      ..updatePhone(_phone.text)
      ..updateCity(_city.text)
      ..updateAddressLine(_address.text);

    final formOk = _formKey.currentState?.validate() ?? false;
    if (!cubit.state.hasLocation) {
      setState(() => _locationError = l10n.businessOnboardingLocationRequired);
    }
    if (!formOk || !cubit.state.hasLocation) return;
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
          appBar: AppTopBar(title: l10n.businessOnboardingTitle),
          body: SafeArea(
            child: Column(
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
                          StepHeader(
                            currentStep: 1,
                            totalSteps: 2,
                            stepText: l10n.businessOnboardingStep1Indicator,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          LogoUploadBox(
                            onTap: () => unawaited(_pickLogo()),
                            imagePath: state.logoPath,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            label: l10n.businessOnboardingTradeNameLabel,
                            hint: l10n.businessOnboardingTradeNameHint,
                            controller: _tradeName,
                            textInputAction: TextInputAction.next,
                            errorText: state.fieldErrors['trade_name']?.first,
                            validator: (v) =>
                                AuthValidators.requiredField(context, v),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: l10n.businessOnboardingLegalNameLabel,
                            hint: l10n.businessOnboardingLegalNameHint,
                            controller: _legalName,
                            textInputAction: TextInputAction.next,
                            errorText: state.fieldErrors['legal_name']?.first,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: l10n.businessOnboardingPhoneLabel,
                            hint: l10n.businessOnboardingPhoneHint,
                            controller: _phone,
                            prefix: const DialPrefix(),
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            errorText: state.fieldErrors['phone']?.first,
                            validator: (v) =>
                                AuthValidators.egyptPhone(context, v),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          LocationPickerCard(
                            hasLocation: state.hasLocation,
                            onTap: () => unawaited(_pickLocation()),
                          ),
                          if (_locationError != null) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _locationError!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey(state.businessType),
                                  initialValue: state.businessType,
                                  decoration: InputDecoration(
                                    labelText: l10n.businessOnboardingTypeLabel,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppRadii.md,
                                      ),
                                    ),
                                  ),
                                  items: [
                                    for (final type in _businessTypes)
                                      DropdownMenuItem(
                                        value: type,
                                        child: Text(_typeLabel(context, type)),
                                      ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      context
                                          .read<BusinessOnboardingCubit>()
                                          .updateBusinessType(v);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: AppTextField(
                                  label: l10n.businessOnboardingCityLabel,
                                  hint: l10n.businessOnboardingCityValue,
                                  controller: _city,
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
                            controller: _address,
                            textInputAction: TextInputAction.done,
                            errorText: state.fieldErrors['address_line']?.first,
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
