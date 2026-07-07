import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';

/// First-run role split. `customer` + `business` are tappable and route into
/// their shell (via auth); `mechanic` + `tow` render disabled ("coming soon").
class RoleChooserPage extends StatelessWidget {
  const RoleChooserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.read<SessionController>();
    final current = session.state.activeRole;
    return BrandScaffold(
      logo: AppImages.fullLogo,
      title: l10n.chooseRole,
      children: [
        _RoleCard(
          icon: Icons.person_outline,
          label: l10n.roleCustomer,
          selected: current == AppRole.customer,
          onTap: () => session.chooseRole(AppRole.customer),
        ),
        const SizedBox(height: AppSpacing.md),
        _RoleCard(
          icon: Icons.storefront_outlined,
          label: l10n.roleBusiness,
          selected: current == AppRole.business,
          onTap: () => session.chooseRole(AppRole.business),
        ),
        const SizedBox(height: AppSpacing.md),
        _RoleCard(
          icon: Icons.build_outlined,
          label: l10n.roleMechanic,
          comingSoonLabel: l10n.comingSoon,
        ),
        const SizedBox(height: AppSpacing.md),
        _RoleCard(
          icon: Icons.local_shipping_outlined,
          label: l10n.roleTow,
          comingSoonLabel: l10n.comingSoon,
        ),
      ],
    );
  }
}

/// One role option. Tappable when [onTap] is set; otherwise dimmed with a
/// "coming soon" chip and no tap target. [selected] marks the currently saved
/// role with an accent border + check.
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.label,
    this.onTap,
    this.comingSoonLabel,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? comingSoonLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: Card(
        shape: selected
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadii.md),
                side: BorderSide(color: theme.colorScheme.primary, width: 2),
              )
            : null,
        child: ListTile(
          enabled: !disabled,
          onTap: onTap,
          leading: Icon(icon),
          title: Text(label),
          trailing: comingSoonLabel != null
              ? Chip(
                  label: Text(comingSoonLabel!),
                  labelStyle: theme.textTheme.labelSmall,
                  visualDensity: VisualDensity.compact,
                )
              : Icon(
                  selected ? Icons.check_circle : Icons.chevron_right,
                  color: selected ? theme.colorScheme.primary : null,
                ),
        ),
      ),
    );
  }
}
