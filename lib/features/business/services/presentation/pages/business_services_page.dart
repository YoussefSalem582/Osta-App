import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/data/models/promotion_model/promotion_item.dart';
import 'package:osta/features/business/services/data/models/services_model/service_item.dart';
import 'package:osta/features/business/services/presentation/cubit/services_cubit.dart';
import 'package:osta/features/business/services/presentation/cubit/services_state.dart';
import 'package:osta/features/business/services/presentation/widgets/add_promotion_bottom_sheet.dart';
import 'package:osta/features/business/services/presentation/widgets/add_service_bottom_sheet.dart';
import 'package:osta/features/business/services/presentation/widgets/business_services_header.dart';
import 'package:osta/features/business/services/presentation/widgets/promotions_content.dart';
import 'package:osta/features/business/services/presentation/widgets/services_content.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        BusinessServicesHeader(
          onAddPressed: () {
            if (_selectedTab == 0) {
              AddServiceBottomSheet.show(context);
            } else {
              AddPromotionBottomSheet.show(context);
            }
          },
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
                      return ServicesContent(
                        services: services,
                        promotions: promotions,
                      );
                    } else {
                      return PromotionsContent(
                        promotions: promotions,
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
}
