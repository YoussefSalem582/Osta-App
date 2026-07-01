import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:osta/shared/formatters/app_formatters.dart';
import 'package:osta/shared/ui/app_bottom_sheet.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Dev gallery previewing every shared component under the live theme.
/// The AppBar action cycles light → dark → system to eyeball both modes.
class ComponentGalleryPage extends StatelessWidget {
  const ComponentGalleryPage({super.key});

  static const path = '/gallery';

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final colors = context.appColors;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Component gallery'),
        actions: [
          BlocBuilder<ThemeModeController, ThemeMode>(
            builder: (context, mode) => IconButton(
              tooltip: mode.name,
              icon: Icon(switch (mode) {
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
                ThemeMode.system => Icons.brightness_auto,
              }),
              onPressed: context.read<ThemeModeController>().cycle,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _section(context, 'Buttons'),
          AppButton(label: 'Primary', onPressed: () {}),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Secondary',
            variant: AppButtonVariant.secondary,
            icon: Icons.add,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Text',
            variant: AppButtonVariant.text,
            onPressed: () {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(label: 'Loading', loading: true, onPressed: () {}),
          _section(context, 'Text field'),
          const AppTextField(
            label: 'Label',
            hint: 'Hint text',
            prefixIcon: Icons.search,
          ),
          _section(context, 'Card'),
          AppCard(
            onTap: () {},
            child: const Text('Tappable card content'),
          ),
          _section(context, 'Bottom sheet'),
          AppButton(
            label: 'Open sheet',
            variant: AppButtonVariant.secondary,
            onPressed: () => AppBottomSheet.show<void>(
              context,
              title: 'Sheet title',
              child: const Text('Sheet body'),
            ),
          ),
          _section(context, 'Status states'),
          const SizedBox(height: 140, child: LoadingState(label: 'Loading…')),
          const EmptyState(title: 'Nothing here', message: 'Empty state'),
          ErrorState(
            title: 'Something broke',
            message: 'Error state',
            onRetry: () {},
          ),
          _section(context, 'Semantic colors'),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _swatch('accent', colors.accent, colors.onAccent),
              _swatch('success', colors.success, colors.onSuccess),
              _swatch('warning', colors.warning, colors.onWarning),
              _swatch(
                'error',
                Theme.of(context).colorScheme.error,
                Theme.of(context).colorScheme.onError,
              ),
            ],
          ),
          _section(context, 'Formatters ($locale)'),
          Text(EgpFormatter.format(1250.5, locale: locale)),
          Text(EgpFormatter.compact(12500, locale: locale)),
          Text(NumberFormatter.decimal(1234567.89, locale: locale)),
          Text(NumberFormatter.percent(0.42, locale: locale)),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(
      top: AppSpacing.lg,
      bottom: AppSpacing.sm,
    ),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _swatch(String name, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadii.sm),
    ),
    child: Text(name, style: TextStyle(color: fg)),
  );
}
