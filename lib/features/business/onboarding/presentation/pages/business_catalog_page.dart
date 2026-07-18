import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/business_onboarding_cubit.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/activation_review_sheet.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/add_custom_service_button.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/add_custom_service_sheet.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/add_preset_card.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/preset_services_banner.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/service_category_chips.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/service_toggle_card.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/step_header.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/formatters/app_formatters.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/app_top_bar.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Step 2 — catalog presets + activate.
class BusinessCatalogPage extends StatefulWidget {
  const BusinessCatalogPage({this.onActivated, super.key});

  static const String path = AppRoutes.businessCatalog;

  /// Called after a successful `POST /business/catalog` so the router can
  /// release the onboarding gate and land in the business shell.
  final VoidCallback? onActivated;

  @override
  State<BusinessCatalogPage> createState() => _BusinessCatalogPageState();
}

class _BusinessCatalogPageState extends State<BusinessCatalogPage> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<BusinessOnboardingCubit>().loadPresets());
  }

  /// Chip label → wire category (`null` = all).
  String? _categoryForChip(String chip, BuildContext context) {
    final l10n = context.l10n;
    if (chip == l10n.businessCatalogFilterOils) return 'oil';
    if (chip == l10n.businessCatalogFilterBrakes) return 'brakes';
    if (chip == l10n.businessCatalogFilterAc) return 'ac';
    return null;
  }

  String _chipForCategory(String? category, BuildContext context) {
    final l10n = context.l10n;
    return switch (category) {
      'oil' => l10n.businessCatalogFilterOils,
      'brakes' => l10n.businessCatalogFilterBrakes,
      'ac' => l10n.businessCatalogFilterAc,
      _ => l10n.businessCatalogFilterAll,
    };
  }

  Future<void> _addCustomService() async {
    final cubit = context.read<BusinessOnboardingCubit>();
    final service = await AddCustomServiceSheet.show(context);
    if (service != null) cubit.addCustomService(service);
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

  /// Last-look review before the center goes live, then activate on confirm.
  Future<void> _confirmAndActivate(
    BuildContext context,
    BusinessOnboardingState state,
  ) async {
    final cubit = context.read<BusinessOnboardingCubit>();
    final confirmed = await ActivationReviewSheet.show(
      context,
      tradeName: state.tradeName,
      typeLabel: _typeLabel(context, state.businessType),
      hasLocation: state.hasLocation,
      serviceCount: state.selectedServiceCount,
    );
    if (confirmed ?? false) unawaited(cubit.activate());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return BlocConsumer<BusinessOnboardingCubit, BusinessOnboardingState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == BusinessOnboardingStatus.activated) {
          context.read<BusinessOnboardingCubit>().acknowledgeNavigation();
          widget.onActivated?.call();
        } else if (state.status == BusinessOnboardingStatus.failure &&
            !state.isLoadingPresets) {
          AppToaster.showError(
            state.networkError
                ? context.l10n.errorNetwork
                : (state.errorMessage ?? context.l10n.errorGeneric),
          );
        }
      },
      builder: (context, state) {
        final categories = [
          l10n.businessCatalogFilterAll,
          l10n.businessCatalogFilterOils,
          l10n.businessCatalogFilterBrakes,
          l10n.businessCatalogFilterAc,
        ];
        final selectedChip = _chipForCategory(state.categoryFilter, context);

        return Scaffold(
          appBar: AppTopBar(title: l10n.businessCatalogTitle),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: state.isLoadingPresets && state.presets.isEmpty
                      ? const Center(child: CircularProgressIndicator.adaptive())
                      : state.presets.isEmpty &&
                            state.status == BusinessOnboardingStatus.failure
                      ? ErrorState(
                          title: l10n.errorGeneric,
                          message: state.networkError
                              ? l10n.errorNetwork
                              : state.errorMessage,
                          onRetry: () => unawaited(
                            context
                                .read<BusinessOnboardingCubit>()
                                .loadPresets(),
                          ),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              StepHeader(
                                currentStep: 2,
                                totalSteps: 2,
                                stepText: l10n.businessCatalogStep2Indicator,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              const PresetServicesBanner(),
                              const SizedBox(height: AppSpacing.lg),
                              ServiceCategoryChips(
                                categories: categories,
                                selectedCategory: selectedChip,
                                onCategorySelected: (chip) {
                                  context
                                      .read<BusinessOnboardingCubit>()
                                      .setCategoryFilter(
                                        _categoryForChip(chip, context),
                                      );
                                },
                              ),
                              // Hidden once every visible preset is already in
                              // — the shortcut has nothing left to add.
                              if (!state.allFilteredSelected) ...[
                                const SizedBox(height: AppSpacing.lg),
                                AddPresetCard(
                                  count: state.filteredPresets.length,
                                  onTap: () => context
                                      .read<BusinessOnboardingCubit>()
                                      .selectFilteredPresets(),
                                ),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              for (final preset in state.filteredPresets) ...[
                                ServiceToggleCard(
                                  title: preset.name,
                                  subtitle:
                                      preset.categoryLabel ?? preset.category,
                                  price: EgpFormatter.format(
                                    preset.defaultPrice,
                                    locale: locale,
                                  ),
                                  isSelected: state.selectedPresetIds.contains(
                                    preset.id,
                                  ),
                                  onChanged: (_) => context
                                      .read<BusinessOnboardingCubit>()
                                      .togglePreset(preset.id),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              // Staged locally; Activate posts each to
                              // /business/services, which is a different
                              // endpoint from the preset catalog above.
                              for (final (i, service)
                                  in state.customServices.indexed) ...[
                                ServiceToggleCard(
                                  title: service.name,
                                  subtitle:
                                      service.category ??
                                      l10n.businessCustomServiceTitle,
                                  price: EgpFormatter.format(
                                    service.price,
                                    locale: locale,
                                  ),
                                  onRemove: () => context
                                      .read<BusinessOnboardingCubit>()
                                      .removeCustomService(i),
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                              const SizedBox(height: AppSpacing.md),
                              AddCustomServiceButton(onTap: _addCustomService),
                              const SizedBox(height: AppSpacing.xl),
                            ],
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!state.canActivate && !state.isActivating)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Text(
                            l10n.businessCatalogSelectAtLeastOne,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: l10n.commonBack,
                              variant: AppButtonVariant.secondary,
                              onPressed: state.isActivating
                                  ? null
                                  : () => context.pop(),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            flex: 2,
                            child: AppButton(
                              label: state.selectedServiceCount > 0
                                  ? l10n.businessCatalogActivateWithCount(
                                      state.selectedServiceCount,
                                    )
                                  : l10n.businessCatalogCreateAndActivate,
                              loading: state.isActivating,
                              onPressed: state.canActivate
                                  ? () => unawaited(
                                      _confirmAndActivate(context, state),
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
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
