import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_theme.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/features/customer/map/presentation/widgets/map_centers_list_sheet.dart';

/// Pumps a button that opens the sheet, then taps it — the sheet's real entry
/// point (`showModalBottomSheet`) needs a host with a Navigator.
Future<void> _openSheet(
  WidgetTester tester, {
  required List<CenterSummary> centers,
  required ValueChanged<CenterSummary> onCenterTap,
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showCentersListSheet(
                context,
                centers: centers,
                onCenterTap: onCenterTap,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('showCentersListSheet', () {
    const centers = [
      CenterSummary(
        id: '1',
        name: 'Nasr Center',
        rating: 4.8,
        distanceMeters: 1200,
        isOpenNow: true,
      ),
      CenterSummary(id: '2', name: 'Nile Auto'),
    ];

    testWidgets('lists every center under a count header', (tester) async {
      await _openSheet(tester, centers: centers, onCenterTap: (_) {});

      expect(find.text('2 centers'), findsOne);
      expect(find.text('Nasr Center'), findsOne);
      expect(find.text('Nile Auto'), findsOne);
      expect(find.text('4.8'), findsOne);
      expect(find.text('1.2 km'), findsOne);
      expect(find.text('Open now'), findsOne);
    });

    testWidgets('tapping a row fires onCenterTap with that center', (
      tester,
    ) async {
      CenterSummary? tapped;
      await _openSheet(
        tester,
        centers: centers,
        onCenterTap: (c) => tapped = c,
      );

      await tester.tap(find.text('Nile Auto'));
      await tester.pump();

      expect(tapped?.id, '2');
    });
  });
}
