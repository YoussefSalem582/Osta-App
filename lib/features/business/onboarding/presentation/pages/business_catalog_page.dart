import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/catalog_cubit.dart';
import 'package:osta/features/business/onboarding/presentation/cubit/catalog_state.dart';
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
  @override
  void initState() {
    super.initState();

    context.read<CatalogCubit>().loadInitData();
  }

  String? _selectedCategory;

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
                    BlocBuilder<CatalogCubit, CatalogState>(
                      builder: (context, state) {
                        if (state is CatalogLoadedState) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (state is CatalogErrorState) {
                          return const Center(
                            child: Text("Something went wrong"),
                          );
                        }

                        if (state is CatalogSuccessState) {
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.services.length,
                            itemBuilder: (context, index) {
                              final service = state.services[index];
                              final subtitle =
                                  "${service.durationMinutes ?? 0} دقيقة • ${service.priceType ?? ""}";
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: ServiceToggleCard(
                                  title: service.name ?? '',
                                  subtitle: subtitle,
                                  price: '${service.price ?? 0} ج',
                                  isSelected: service.isActive ?? false,
                                  onChanged: (value) {},
                                ),
                              );
                            },
                          );
                        }

                        return const SizedBox();
                      },
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
