import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/business/services/data/repo/business_service_repo.dart';
import 'package:osta/features/business/services/presentation/bloc/services_bloc.dart';
import 'package:osta/features/business/services/presentation/pages/service_form_screen.dart';
import 'package:osta/features/business/services/presentation/widgets/discount_promotion_banner.dart';
import 'package:osta/features/business/services/presentation/widgets/service_management_row.dart';
import 'package:osta/features/business/services/presentation/widgets/services_header.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_confirm_dialog.dart';
import 'package:osta/shared/ui/app_segmented_toggle.dart';
import 'package:osta/shared/ui/app_toaster.dart';
import 'package:osta/shared/ui/status_states.dart';

/// الكتالوج والأسعار (الخدمات والعروض) — the Catalog tab body of the business
/// shell. Services segment is live (`/business/services` — list, toggle active,
/// add, edit, delete); the Offers segment is still the placeholder banner
/// (promotions CRUD pending).
class BusinessServicesPage extends StatelessWidget {
  const BusinessServicesPage({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ServicesBloc()..add(const ServicesLoadRequested()),
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocListener<ServicesBloc, ServicesState>(
      listener: (context, state) {
        if (state is ServicesLoaded && state.justDeleted) {
          AppToaster.showMessage(l10n.serviceDeleted);
        }
      },
      child: Column(
        children: [
          ServicesHeader(
            showAddButton: _selectedTab == 0,
            onAdd: () {
              unawaited(_openForm());
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
            child: _selectedTab == 0 ? _servicesList() : _offersPlaceholder(),
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
          return const Center(child: CircularProgressIndicator());
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
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _offersPlaceholder() {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DiscountPromotionBanner(
        title: l10n.businessServicesPromoTitle,
        subtitle: l10n.businessServicesPromoSubtitle,
        activeBadgeText: l10n.businessServicesPromoActiveBadge,
      ),
    );
  }
}
