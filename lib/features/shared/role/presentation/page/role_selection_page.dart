import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/features/shared/role/presentation/widgets/info_banner.dart';
import 'package:osta/features/shared/role/presentation/widgets/role_card.dart';
import 'package:osta/shared/extensions/context_ext.dart';

/// First-run role split. `customer` + `business` are tappable and route into
/// their shell (via auth); `mechanic` + `tow` render disabled ("coming soon").
/// Tapping calls [SessionController.chooseRole]; the router redirect handles
/// navigation, so no explicit push here.
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  static const path = '/role';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final session = context.read<SessionController>();

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.roleSelectionEyebrow,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.roleSelectionTitle,
                    textAlign: TextAlign.start,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  //--------------------------------{Active Role Card}--------------------------------------//
                  RoleCard(
                    title: l10n.roleSelectionCustomerTitle,
                    subtitle: l10n.roleSelectionCustomerSubtitle,
                    icon: Icons.directions_car_rounded,
                    onTap: () => session.chooseRole(AppRole.customer),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RoleCard(
                    title: l10n.roleSelectionBusinessTitle,
                    subtitle: l10n.roleSelectionBusinessSubtitle,
                    icon: Icons.storefront_rounded,
                    onTap: () => session.chooseRole(AppRole.business),
                  ),
                  //--------------------------------{Not Active Role Card}--------------------------------------//
                  const SizedBox(height: AppSpacing.md),
                  RoleCard(
                    title: l10n.roleSelectionMechanicTitle,
                    subtitle: l10n.roleSelectionMechanicSubtitle,
                    icon: Icons.build_rounded,
                    enabled: false,
                    badgeLabel: l10n.comingSoon,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  RoleCard(
                    title: l10n.roleSelectionTowTruckTitle,
                    subtitle: l10n.roleSelectionTowTruckSubtitle,
                    icon: Icons.local_taxi_rounded,
                    enabled: false,
                    badgeLabel: l10n.comingSoon,
                  ),

                  //--------------------------------{Can Change Role Later}--------------------------------------//
                  const SizedBox(height: AppSpacing.md),
                  InfoBanner(text: l10n.roleSelectionInfoBanner),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
