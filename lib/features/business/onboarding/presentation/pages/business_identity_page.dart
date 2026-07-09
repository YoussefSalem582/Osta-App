import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/location_picker_card.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/logo_upload_box.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/step_header.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// سجل نشاطك
class BusinessIdentityPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.businessOnboardingTitle,
      ),
      body: SafeArea(
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
                    LogoUploadBox(onTap: onLogoTap),

                    //--------------------------------{}-------------------------------//
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      label: l10n.businessOnboardingTradeNameLabel,
                      hint: l10n.businessOnboardingTradeNameHint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
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
                            borderRadius: BorderRadius.circular(AppRadii.md),
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
                                style: theme.textTheme.bodyMedium?.copyWith(
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
                            label: l10n.businessOnboardingPhoneLabel,
                            hint: l10n.businessOnboardingPhoneHint,
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                      ],
                    ),
                    // ---- مكان المركز ----
                    const SizedBox(height: AppSpacing.lg),
                    LocationPickerCard(onTap: onLocationTap),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: l10n.businessOnboardingTypeLabel,
                            hint: l10n.businessOnboardingTypeValue,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: AppTextField(
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
                onPressed: onContinue ?? () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
