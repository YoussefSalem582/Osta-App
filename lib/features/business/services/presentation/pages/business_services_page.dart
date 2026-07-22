import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/data/model/promotion.dart';
import 'package:osta/features/business/services/data/repo/business_service_repo.dart';
import 'package:osta/features/business/services/presentation/bloc/promotions_bloc.dart';
import 'package:osta/features/business/services/presentation/bloc/services_bloc.dart';
import 'package:osta/features/business/services/presentation/pages/promotion_form_screen.dart';
import 'package:osta/features/business/services/presentation/pages/service_form_screen.dart';
import 'package:osta/features/business/services/presentation/widgets/promotion_row.dart';
import 'package:osta/features/business/services/presentation/widgets/service_management_row.dart';
import 'package:osta/features/business/services/presentation/widgets/services_header.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_confirm_dialog.dart';
import 'package:osta/shared/ui/app_segmented_toggle.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/status_states.dart';

/// الكتالوج والأسعار — Catalog tab body: Services (`/business/services`) and
/// Offers (`/business/promotions`).
class BusinessServicesPage extends StatelessWidget {
  const BusinessServicesPage({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => ServicesBloc()..add(const ServicesLoadRequested()),
      ),
      BlocProvider(
        create: (_) => PromotionsBloc()..add(const PromotionsLoadRequested()),
      ),
    ],
    child: const _BusinessServicesView(),
  );
}

class _BusinessServicesView extends StatefulWidget {
  const _BusinessServicesView();

  @override
  State<_BusinessServicesView> createState() => _BusinessServicesViewState();
}

class _BusinessServicesViewState extends State<_BusinessServicesView> {
  int _selectedTab = 0; // 0: services, 1: offers

  Future<void> _openForm({Service? service}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ServiceFormScreen(service: service)),
    );
    if (saved == true && mounted) {
      context.read<ServicesBloc>().add(const ServicesLoadRequested());
    }
  }

  Future<void> _confirmDelete(Service service) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: l10n.deleteServiceDialogTitle,
      message: l10n.deleteServiceDialogMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    // Toast fires from the BlocListener in build() once the delete completes.
    context.read<ServicesBloc>().add(ServicesDeleteRequested(service));
  }

  Future<void> _openPromotionForm({Promotion? promotion}) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => PromotionFormScreen(promotion: promotion),
      ),
    );
    if (saved == true && mounted) {
      context.read<PromotionsBloc>().add(const PromotionsLoadRequested());
    }
  }

  Future<void> _confirmDeletePromotion(Promotion promotion) async {
    final l10n = context.l10n;
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: l10n.deletePromotionDialogTitle,
      message: l10n.deletePromotionDialogMessage,
      cancelLabel: l10n.cancel,
      confirmLabel: l10n.delete,
      isDestructive: true,
    );
    if (confirmed != true || !mounted) return;
    // Toast fires from the BlocListener in build() once the delete completes.
    context.read<PromotionsBloc>().add(PromotionsDeleteRequested(promotion));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return MultiBlocListener(
      listeners: [
        BlocListener<ServicesBloc, ServicesState>(
          listener: (context, state) {
            if (state is ServicesLoaded && state.justDeleted) {
              AppToaster.showMessage(l10n.serviceDeleted);
            }
          },
        ),
        BlocListener<PromotionsBloc, PromotionsState>(
          listener: (context, state) {
            if (state is PromotionsLoaded && state.justDeleted) {
              AppToaster.showMessage(l10n.promotionDeleted);
            }
          },
        ),
      ],
      child: Column(
        children: [
          ServicesHeader(
            showAddButton: true,
            onAdd: () {
              if (_selectedTab == 0) {
                unawaited(_openForm());
              } else {
                unawaited(_openPromotionForm());
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: AppSegmentedToggle(
              options: [
                l10n.businessServicesTabServices,
                l10n.businessServicesTabOffers,
              ],
              selectedIndex: _selectedTab,
              onSelect: (val) => setState(() => _selectedTab = val),
              expand: true,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: _selectedTab == 0 ? _servicesList() : _offersList(),
          ),
        ],
      ),
    );
  }

  Widget _servicesList() {
    final l10n = context.l10n;
    return BlocBuilder<ServicesBloc, ServicesState>(
      builder: (context, state) {
        if (state is ServicesLoading || state is ServicesInitial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state is ServicesError) {
          return ErrorState(
            title: l10n.servicesErrorTitle,
            message: state.message,
            onRetry: () =>
                context.read<ServicesBloc>().add(const ServicesLoadRequested()),
          );
        }
        final loaded = state as ServicesLoaded;
        if (loaded.services.isEmpty) {
          return EmptyState(
            icon: Icons.build_outlined,
            title: l10n.servicesEmptyTitle,
            message: l10n.servicesEmptyMessage,
          );
        }
        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: loaded.services.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final service = loaded.services[index];
                return ServiceManagementRow(
                  service: service,
                  onEdit: () => _openForm(service: service),
                  onToggle: (v) => context.read<ServicesBloc>().add(
                    ServicesActiveToggled(service, isActive: v),
                  ),
                  onDelete: () => _confirmDelete(service),
                );
              },
            ),
            if (loaded.acting)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black12,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _offersList() {
    final l10n = context.l10n;
    return BlocBuilder<PromotionsBloc, PromotionsState>(
      builder: (context, state) {
        if (state is PromotionsLoading || state is PromotionsInitial) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state is PromotionsError) {
          return ErrorState(
            title: l10n.promotionsErrorTitle,
            message: state.message,
            onRetry: () => context.read<PromotionsBloc>().add(
              const PromotionsLoadRequested(),
            ),
          );
        }
        final loaded = state as PromotionsLoaded;
        if (loaded.promotions.isEmpty) {
          return EmptyState(
            icon: Icons.local_offer_outlined,
            title: l10n.promotionsEmptyTitle,
            message: l10n.promotionsEmptyMessage,
          );
        }
        return Stack(
          children: [
            ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: loaded.promotions.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final promotion = loaded.promotions[index];
                return PromotionRow(
                  promotion: promotion,
                  onEdit: () => _openPromotionForm(promotion: promotion),
                  onToggle: (v) => context.read<PromotionsBloc>().add(
                    PromotionsActiveToggled(promotion, isActive: v),
                  ),
                  onDelete: () => _confirmDeletePromotion(promotion),
                );
              },
            ),
            if (loaded.acting)
              const Positioned.fill(
                child: ColoredBox(
                  color: Colors.black12,
                  child: Center(child: CircularProgressIndicator.adaptive()),
                ),
              ),
          ],
        );
      },
    );
  }
}
