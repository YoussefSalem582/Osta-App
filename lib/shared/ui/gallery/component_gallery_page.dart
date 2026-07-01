import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:osta/core/theme/osta_colors.dart';
import 'package:osta/core/theme/osta_tokens.dart';
import 'package:osta/core/theme/theme_mode_controller.dart';
import 'package:osta/shared/formatters/osta_formatters.dart';
import 'package:osta/shared/ui/osta_bottom_sheet.dart';
import 'package:osta/shared/ui/osta_button.dart';
import 'package:osta/shared/ui/osta_card.dart';
import 'package:osta/shared/ui/osta_text_field.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Dev gallery previewing every shared component under the live theme.
/// The AppBar action cycles light → dark → system to eyeball both modes.
class ComponentGalleryPage extends StatelessWidget {
  const ComponentGalleryPage({super.key});

  static const path = '/gallery';

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final colors = context.ostaColors;
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
        padding: const EdgeInsets.all(OstaSpacing.md),
        children: [
          _section(context, 'Buttons'),
          OstaButton(label: 'Primary', onPressed: () {}),
          const SizedBox(height: OstaSpacing.sm),
          OstaButton(
            label: 'Secondary',
            variant: OstaButtonVariant.secondary,
            icon: Icons.add,
            onPressed: () {},
          ),
          const SizedBox(height: OstaSpacing.sm),
          OstaButton(
            label: 'Text',
            variant: OstaButtonVariant.text,
            onPressed: () {},
          ),
          const SizedBox(height: OstaSpacing.sm),
          OstaButton(label: 'Loading', loading: true, onPressed: () {}),
          _section(context, 'Text field'),
          const OstaTextField(
            label: 'Label',
            hint: 'Hint text',
            prefixIcon: Icons.search,
          ),
          _section(context, 'Card'),
          OstaCard(
            onTap: () {},
            child: const Text('Tappable card content'),
          ),
          _section(context, 'Bottom sheet'),
          OstaButton(
            label: 'Open sheet',
            variant: OstaButtonVariant.secondary,
            onPressed: () => OstaBottomSheet.show<void>(
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
            spacing: OstaSpacing.sm,
            runSpacing: OstaSpacing.sm,
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
          const SizedBox(height: OstaSpacing.xl),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(
      top: OstaSpacing.lg,
      bottom: OstaSpacing.sm,
    ),
    child: Text(title, style: Theme.of(context).textTheme.titleMedium),
  );

  Widget _swatch(String name, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: OstaSpacing.md,
      vertical: OstaSpacing.sm,
    ),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(OstaRadii.sm),
    ),
    child: Text(name, style: TextStyle(color: fg)),
  );
}
