import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_identity_cubit.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_identity_state.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/location_picker_card.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/logo_upload_box.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/step_header.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// سجل نشاطك
class BusinessIdentityPage extends StatefulWidget {
  const BusinessIdentityPage({
    this.onContinue,
    this.onLogoTap,
    this.onLocationTap,
    super.key,
  });

  static const path = '/business-identity';

  final VoidCallback? onContinue;
  final VoidCallback? onLogoTap;
  final VoidCallback? onLocationTap;

  @override
  State<BusinessIdentityPage> createState() => _BusinessIdentityPageState();
}

class _BusinessIdentityPageState extends State<BusinessIdentityPage> {
  final _formKey = GlobalKey<FormState>();
  final _tradeNameCtrl = TextEditingController();
  final _legalNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String? _logoPath;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _tradeNameCtrl.dispose();
    _legalNameCtrl.dispose();
    _phoneCtrl.dispose();
    _typeCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    widget.onLogoTap?.call();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked != null && mounted) {
      setState(() => _logoPath = picked.path);
    }
  }

  void _pickLocation() {
    widget.onLocationTap?.call();
    setState(() {
      _latitude = 30.0444;
      _longitude = 31.2357;
    });
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<BusinessIdentityCubit>().submitIdentity(
      tradeName: _tradeNameCtrl.text.trim(),
      legalName: _legalNameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      type: _typeCtrl.text.trim(),
      city: _cityCtrl.text.trim(),
      logoPath: _logoPath,
      latitude: _latitude,
      longitude: _longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<BusinessIdentityCubit, BusinessIdentityState>(
      listener: (context, state) {
        if (state is BusinessIdentitySuccessState) {
          widget.onContinue?.call();
        } else if (state is BusinessIdentityErrorState) {
          AppToaster.showError(state.message ?? context.l10n.errorNetwork);
        }
      },
      builder: (context, state) {
        final l10n = context.l10n;
        final theme = Theme.of(context);

        return Scaffold(
          appBar: AppTopBar(
            title: l10n.businessOnboardingTitle,
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StepHeader(
                            currentStep: 1,
                            totalSteps: 2,
                            stepText: l10n.businessOnboardingStep1Indicator,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          //--------------------------{شعار المركز}-------------------------------//
                          LogoUploadBox(onTap: _pickLogo),

                          //--------------------------------{}-------------------------------//
                          const SizedBox(height: AppSpacing.lg),
                          AppTextField(
                            controller: _tradeNameCtrl,
                            label: l10n.businessOnboardingTradeNameLabel,
                            hint: l10n.businessOnboardingTradeNameHint,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            controller: _legalNameCtrl,
                            label: l10n.businessOnboardingLegalNameLabel,
                            hint: l10n.businessOnboardingLegalNameHint,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          // ---- رقم تليفون المركز ----
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                height: 52,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.light.onWarning,
                                  borderRadius: BorderRadius.circular(
                                    AppRadii.md,
                                  ),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '+20',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    const Text(
                                      '🇪🇬',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: AppTextField(
                                  controller: _phoneCtrl,
                                  label: l10n.businessOnboardingPhoneLabel,
                                  hint: l10n.businessOnboardingPhoneHint,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),
                            ],
                          ),
                          // ---- مكان المركز ----
                          const SizedBox(height: AppSpacing.lg),
                          LocationPickerCard(onTap: _pickLocation),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            children: [
                              Expanded(
                                child: AppTextField(
                                  controller: _typeCtrl,
                                  label: l10n.businessOnboardingTypeLabel,
                                  hint: l10n.businessOnboardingTypeValue,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: AppTextField(
                                  controller: _cityCtrl,
                                  label: l10n.businessOnboardingCityLabel,
                                  hint: l10n.businessOnboardingCityValue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: AppButton(
                      label: l10n.businessOnboardingContinueToCatalog,
                      loading: state is BusinessIdentityLoadingState,
                      onPressed: _submit,
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
