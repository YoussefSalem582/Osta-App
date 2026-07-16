import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/constants/app_images.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/brand_scaffold.dart';

/// Language pick (Arabic / English). Shown every logged-out launch —
/// [SessionController] persists the choice and the redirect guard advances to
/// the role chooser. Arabic is offered first (RTL-first product); the currently
/// saved language reads as selected.
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.read<SessionController>();
    final current = session.state.locale?.languageCode;
    return BrandScaffold(
      logo: AppImages.fullLogo,
      title: l10n.languageTitle,
      subtitle: l10n.languageSubtitle,
      children: [
        _LanguageCard(
          label: l10n.languageArabic,
          selected: current == 'ar',
          onTap: () => session.chooseLanguage(const Locale('ar')),
        ),
        const SizedBox(height: AppSpacing.md),
        _LanguageCard(
          label: l10n.languageEnglish,
          selected: current == 'en',
          onTap: () => session.chooseLanguage(const Locale('en')),
        ),
      ],
    );
  }
}

/// One tappable language option, styled to match the app's card surfaces.
/// [selected] marks the currently saved language with a check.
class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.label,
    required this.onTap,
    this.selected = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      // AppCard's null border falls through to CardTheme's shape, which is the
      // same RoundedRectangleBorder(AppRadii.lg) this used to spell out.
      border: selected
          ? BorderSide(color: theme.colorScheme.primary, width: 2)
          : null,
      // The ListTile brings its own contentPadding.
      padding: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        leading: const Icon(Icons.translate_outlined),
        title: Text(label, style: theme.textTheme.titleMedium),
        trailing: Icon(
          selected ? Icons.check_circle : Icons.chevron_right,
          color: selected ? theme.colorScheme.primary : null,
        ),
      ),
    );
  }
}
