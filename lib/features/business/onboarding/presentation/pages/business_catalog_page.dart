import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/add_custom_service_button.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/add_preset_card.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/preset_services_banner.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/service_category_chips.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/service_toggle_card.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/step_header.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

/// كتالوج الخدمات
class BusinessCatalogPage extends StatefulWidget {
  const BusinessCatalogPage({
    this.onActivate,
    this.onAddCommon,
    this.onAddCustom,
    super.key,
  });

  static const path = '/business-catalog';

  final VoidCallback? onActivate;
  final VoidCallback? onAddCommon;
  final VoidCallback? onAddCustom;

  @override
  State<BusinessCatalogPage> createState() => _BusinessCatalogPageState();
}

class _BusinessCatalogPageState extends State<BusinessCatalogPage> {
  String? _selectedCategory;
  bool _oilSelected = true;
  bool _brakesSelected = true;
  bool _acSelected = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categories = [
      l10n.businessCatalogFilterAll,
      l10n.businessCatalogFilterOils,
      l10n.businessCatalogFilterBrakes,
      l10n.businessCatalogFilterAc,
    ];
    final selectedCat = _selectedCategory ?? categories.first;

    return Scaffold(
      appBar: AppTopBar(
        title: l10n.businessCatalogTitle,
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
                      currentStep: 2,
                      totalSteps: 2,
                      stepText: l10n.businessCatalogStep2Indicator,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const PresetServicesBanner(),
                    const SizedBox(height: AppSpacing.lg),
                    ServiceCategoryChips(
                      categories: categories,
                      selectedCategory: selectedCat,
                      onCategorySelected: (cat) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AddPresetCard(
                      onTap: widget.onAddCommon ?? () {},
                    ),

                    //--------------------------------{ليستة الخدمات}-------------------------------//
                    const SizedBox(height: AppSpacing.md),
                    ServiceToggleCard(
                      title: l10n.businessCatalogServiceOilTitle,
                      subtitle: l10n.businessCatalogServiceOilSubtitle,
                      price: l10n.businessCatalogServiceOilPrice,
                      isSelected: _oilSelected,
                      onChanged: (val) => setState(() => _oilSelected = val),
                    ),

                    const SizedBox(height: AppSpacing.sm),
                    ServiceToggleCard(
                      title: l10n.businessCatalogServiceBrakesTitle,
                      subtitle: l10n.businessCatalogServiceBrakesSubtitle,
                      price: l10n.businessCatalogServiceBrakesPrice,
                      isSelected: _brakesSelected,
                      onChanged: (val) => setState(() => _brakesSelected = val),
                    ),

                    const SizedBox(height: AppSpacing.sm),
                    ServiceToggleCard(
                      title: l10n.businessCatalogServiceAcTitle,
                      subtitle: l10n.businessCatalogServiceAcSubtitle,
                      price: l10n.businessCatalogServiceAcPrice,
                      isSelected: _acSelected,
                      onChanged: (val) => setState(() => _acSelected = val),
                    ),

                    //--------------------------------{اضافة خدمة مخصصه}-------------------------------//
                    const SizedBox(height: AppSpacing.md),
                    AddCustomServiceButton(
                      onTap: widget.onAddCustom ?? () {},
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),

            //--------------------------------{زرار انشاء المركز}-------------------------------//
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: AppButton(
                label: l10n.businessCatalogCreateAndActivate,
                onPressed: widget.onActivate ?? () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
