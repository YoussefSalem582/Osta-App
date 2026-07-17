import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/service_toggle_card.dart';
import 'package:osta/features/business/services/data/models/promotion_model/promotion_item.dart';
import 'package:osta/features/business/services/data/models/services_model/service_item.dart';
import 'package:osta/features/business/services/presentation/cubit/services_cubit.dart';
import 'package:osta/features/business/services/presentation/cubit/services_state.dart';
import 'package:osta/features/business/services/presentation/widgets/discount_promotion_banner.dart';
import 'package:osta/features/business/services/presentation/widgets/services_filter_toggle.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// الكتالوج والأسعار (الخدمات والعروض) — the Catalog tab body of the business
class BusinessServicesPage extends StatelessWidget {
  const BusinessServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ServicesCubit()..loadServices(),
      child: const _BusinessServicesView(),
    );
  }
}

class _BusinessServicesView extends StatefulWidget {
  const _BusinessServicesView();

  @override
  State<_BusinessServicesView> createState() => _BusinessServicesViewState();
}

class _BusinessServicesViewState extends State<_BusinessServicesView> {
  int _selectedTab = 0; // 0: الخدمات, 1: العروض
  bool _oilSelected = true;
  bool _brakesSelected = true;
  bool _acSelected = true;
  bool _electricSelected = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header bar exactly matching Image 1
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.businessServicesEyebrow,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.businessServicesTitle,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  if (_selectedTab == 0) {
                    _showAddServiceSheet(context);
                  } else {
                    _showAddPromotionSheet(context);
                  }
                },
                borderRadius: BorderRadius.circular(AppRadii.lg),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                  ),
                  child: Icon(
                    Icons.add,
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ServicesFilterToggle(
                  selectedTab: _selectedTab,
                  onTabChanged: (val) => setState(() => _selectedTab = val),
                  servicesLabel: l10n.businessServicesTabServices,
                  offersLabel: l10n.businessServicesTabOffers,
                ),
                const SizedBox(height: AppSpacing.md),
                BlocBuilder<ServicesCubit, ServicesState>(
                  builder: (context, state) {
                    if (state is ServicesLoadingState) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (state is ServicesErrorState) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl,
                        ),
                        child: Center(
                          child: Text(l10n.errorNetwork),
                        ),
                      );
                    }

                    final List<ServiceItem> services =
                        state is ServicesSuccessState
                        ? state.services
                        : const <ServiceItem>[];
                    final List<PromotionItem> promotions =
                        state is ServicesSuccessState
                        ? state.promotions
                        : const <PromotionItem>[];

                    if (_selectedTab == 0) {
                      if (services.isEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ServiceToggleCard(
                              title: l10n.businessServicesOilTitle,
                              subtitle: l10n.businessServicesOilSubtitle,
                              price: l10n.businessServicesOilPrice,
                              isSelected: _oilSelected,
                              onChanged: (val) =>
                                  setState(() => _oilSelected = val),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ServiceToggleCard(
                              title: l10n.businessServicesBrakesTitle,
                              subtitle: l10n.businessServicesBrakesSubtitle,
                              price: l10n.businessServicesBrakesPrice,
                              isSelected: _brakesSelected,
                              onChanged: (val) =>
                                  setState(() => _brakesSelected = val),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ServiceToggleCard(
                              title: l10n.businessServicesAcTitle,
                              subtitle: l10n.businessServicesAcSubtitle,
                              price: l10n.businessServicesAcPrice,
                              isSelected: _acSelected,
                              onChanged: (val) =>
                                  setState(() => _acSelected = val),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            ServiceToggleCard(
                              title: l10n.businessServicesElectricTitle,
                              subtitle: l10n.businessServicesElectricSubtitle,
                              price: l10n.businessServicesElectricPrice,
                              isSelected: _electricSelected,
                              onChanged: (val) =>
                                  setState(() => _electricSelected = val),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            DiscountPromotionBanner(
                              title: l10n.businessServicesPromoTitle,
                              subtitle: l10n.businessServicesPromoSubtitle,
                              activeBadgeText:
                                  l10n.businessServicesPromoActiveBadge,
                            ),
                          ],
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: services.length,
                            itemBuilder: (context, index) {
                              final service = services[index];
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
                                  onChanged: (val) {
                                    if (service.id != null) {
                                      context
                                          .read<ServicesCubit>()
                                          .toggleService(
                                            serviceId: service.id!,
                                            isActive: val,
                                          );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (promotions.isNotEmpty)
                            DiscountPromotionBanner(
                              title:
                                  promotions.first.title ??
                                  l10n.businessServicesPromoTitle,
                              subtitle:
                                  promotions.first.subtitle ??
                                  l10n.businessServicesPromoSubtitle,
                              activeBadgeText:
                                  l10n.businessServicesPromoActiveBadge,
                            )
                          else
                            DiscountPromotionBanner(
                              title: l10n.businessServicesPromoTitle,
                              subtitle: l10n.businessServicesPromoSubtitle,
                              activeBadgeText:
                                  l10n.businessServicesPromoActiveBadge,
                            ),
                        ],
                      );
                    } else {
                      if (promotions.isEmpty) {
                        return DiscountPromotionBanner(
                          title: l10n.businessServicesPromoTitle,
                          subtitle: l10n.businessServicesPromoSubtitle,
                          activeBadgeText:
                              l10n.businessServicesPromoActiveBadge,
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final promo in promotions) ...[
                            DiscountPromotionBanner(
                              title:
                                  promo.title ??
                                  l10n.businessServicesPromoTitle,
                              subtitle:
                                  promo.subtitle ??
                                  l10n.businessServicesPromoSubtitle,
                              activeBadgeText:
                                  l10n.businessServicesPromoActiveBadge,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      );
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddServiceSheet(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "إضافة خدمة جديدة",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "اسم الخدمة",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "السعر",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "المدة بالدقائق",
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (nameController.text.isNotEmpty &&
                            priceController.text.isNotEmpty &&
                            durationController.text.isNotEmpty) {
                          await context.read<ServicesCubit>().addService(
                            name: nameController.text,
                            price: int.tryParse(priceController.text) ?? 0,
                            duration:
                                int.tryParse(durationController.text) ?? 30,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text("إضافة الخدمة"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddPromotionSheet(BuildContext context) {
    final titleController = TextEditingController();
    final subtitleController = TextEditingController();
    final discountController = TextEditingController();

    unawaited(
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "إضافة عرض جديد",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: "عنوان العرض",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: subtitleController,
                    decoration: const InputDecoration(
                      labelText: "تفاصيل العرض",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: discountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "نسبة الخصم (%)",
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isNotEmpty &&
                            subtitleController.text.isNotEmpty &&
                            discountController.text.isNotEmpty) {
                          await context.read<ServicesCubit>().addPromotion(
                            title: titleController.text,
                            subtitle: subtitleController.text,
                            discountPercentage:
                                int.tryParse(discountController.text) ?? 0,
                          );
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        }
                      },
                      child: const Text("إضافة العرض"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
