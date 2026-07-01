import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_theme.dart';
import 'package:osta/shared/ui/app_button.dart';
import 'package:osta/shared/ui/app_card.dart';
import 'package:osta/shared/ui/app_text_field.dart';
import 'package:osta/shared/ui/status_states.dart';

/// Pumps [child] under a full Osta theme in the given mode and locale
/// (locale `ar` renders RTL, `en` renders LTR).
Future<void> pumpThemed(
  WidgetTester tester,
  Widget child, {
  required Brightness brightness,
  required String locale,
}) => tester.pumpWidget(
  MaterialApp(
    theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
    locale: Locale(locale),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Center(child: child)),
  ),
);

void main() {
  final matrix = [
    (Brightness.light, 'en', TextDirection.ltr),
    (Brightness.light, 'ar', TextDirection.rtl),
    (Brightness.dark, 'en', TextDirection.ltr),
    (Brightness.dark, 'ar', TextDirection.rtl),
  ];

  for (final (brightness, locale, direction) in matrix) {
    testWidgets('components render in ${brightness.name}/$locale', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(label: 'Go', onPressed: () {}),
            const AppTextField(label: 'Name', hint: 'Hint'),
            const AppCard(child: Text('Card')),
            const Expanded(child: EmptyState(title: 'Empty')),
          ],
        ),
        brightness: brightness,
        locale: locale,
      );

      expect(tester.takeException(), isNull);
      // Direction actually follows the locale.
      expect(
        Directionality.of(tester.element(find.text('Card'))),
        direction,
      );
      expect(find.byType(FilledButton), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });
  }

  testWidgets('loading button shows spinner and swallows taps', (
    tester,
  ) async {
    var taps = 0;
    await pumpThemed(
      tester,
      AppButton(label: 'Save', loading: true, onPressed: () => taps++),
      brightness: Brightness.light,
      locale: 'en',
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
    await tester.tap(find.byType(FilledButton), warnIfMissed: false);
    expect(taps, 0);
  });

  testWidgets('button variants map to the right Material widgets', (
    tester,
  ) async {
    await pumpThemed(
      tester,
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton(label: 'p', onPressed: () {}),
          AppButton(
            label: 's',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
          AppButton(
            label: 't',
            variant: AppButtonVariant.text,
            onPressed: () {},
          ),
        ],
      ),
      brightness: Brightness.light,
      locale: 'en',
    );

    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('ErrorState retry fires callback with localized label', (
    tester,
  ) async {
    var retried = 0;
    await pumpThemed(
      tester,
      ErrorState(title: 'Oops', onRetry: () => retried++),
      brightness: Brightness.light,
      locale: 'ar',
    );

    // Arabic retry label from l10n.
    await tester.tap(find.text('حاول مرة أخرى'));
    expect(retried, 1);
  });
}
