import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/extensions/context_ext.dart';
import 'package:osta/shared/ui/app_button.dart';

/// First-run language pick (Arabic / English). Shown once — [SessionController]
/// persists the choice and the router never routes back here. Arabic is offered
/// first (RTL-first product).
class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final session = context.read<SessionController>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.languageTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: l10n.languageArabic,
                onPressed: () => session.chooseLanguage(const Locale('ar')),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.languageEnglish,
                variant: AppButtonVariant.secondary,
                onPressed: () => session.chooseLanguage(const Locale('en')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
