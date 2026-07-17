import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_theme.dart';
import 'package:osta/features/customer/home/presentation/widgets/center_card.dart';

void main() {
  Future<void> pump(WidgetTester tester, Locale locale) => tester.pumpWidget(
    MaterialApp(
      locale: locale,
      // AppTheme registers the AppColors extension the star icon reads.
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: CenterCard(name: 'Nasr', distance: '2 KM', rate: 4.6),
      ),
    ),
  );

  testWidgets('renders a star icon, not a hardcoded emoji', (tester) async {
    await pump(tester, const Locale('en'));
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(
      find.textContaining('⭐'),
      findsNothing,
      reason: 'the rating used to be interpolated with a literal star emoji',
    );
  });

  testWidgets('formats the rating per locale', (tester) async {
    await pump(tester, const Locale('en'));
    expect(find.text('4.6'), findsOneWidget);

    // ar_EG uses Arabic-Indic digits and a decimal comma. The old
    // '$rate ⭐' interpolation printed Latin 4.6 in Arabic too.
    await pump(tester, const Locale('ar'));
    expect(find.text('4.6'), findsNothing);
    expect(find.text('٤٫٦'), findsOneWidget);
  });
}
