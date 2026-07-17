import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_theme.dart';
import 'package:osta/features/customer/map/data/model/center_summary.dart';
import 'package:osta/features/customer/map/presentation/widgets/place_dialog.dart';

/// The real theme, not a bare MaterialApp: `context.appColors` reads the
/// AppColors ThemeExtension and null-checks it.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
}) => tester.pumpWidget(
  MaterialApp(
    locale: locale,
    theme: AppTheme.light(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: Align(child: child)),
  ),
);

void main() {
  group('PlaceDialog', () {
    testWidgets('shows the summary the epic specifies', (tester) async {
      await _pump(
        tester,
        PlaceDialog(
          center: const CenterSummary(
            id: '1',
            name: 'Nasr Center',
            rating: 4.8,
            distanceMeters: 1200,
            isOpenNow: true,
          ),
          onBook: () {},
          onDetails: () {},
        ),
      );

      expect(find.text('Nasr Center'), findsOne);
      expect(find.text('4.8'), findsOne);
      expect(find.text('1.2 km'), findsOne);
      expect(find.text('Open now'), findsOne);
      expect(find.text('Book'), findsOne);
      expect(find.text('Details'), findsOne);
    });

    testWidgets('renders the Arabic copy from the mockup', (tester) async {
      await _pump(
        tester,
        PlaceDialog(
          center: const CenterSummary(
            id: '1',
            name: 'مركز النصر للصيانة',
            isOpenNow: true,
          ),
          onBook: () {},
          onDetails: () {},
        ),
        locale: const Locale('ar'),
      );

      expect(find.text('مركز النصر للصيانة'), findsOne);
      expect(find.text('مفتوح الآن'), findsOne);
      expect(find.text('احجز'), findsOne);
      expect(find.text('التفاصيل'), findsOne);
    });

    testWidgets('drops the fields the API omitted instead of showing blanks', (
      tester,
    ) async {
      await _pump(
        tester,
        PlaceDialog(
          center: const CenterSummary(id: '1', name: 'Sparse'),
          onBook: () {},
          onDetails: () {},
        ),
      );

      expect(find.text('Sparse'), findsOne);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
      expect(find.textContaining('km'), findsNothing);
      expect(find.text('Open now'), findsNothing);
      expect(find.text('Closed'), findsNothing);
      // The actions always render.
      expect(find.text('Book'), findsOne);
    });

    testWidgets('marks a closed center as closed', (tester) async {
      await _pump(
        tester,
        PlaceDialog(
          center: const CenterSummary(id: '1', name: 'Shut', isOpenNow: false),
          onBook: () {},
          onDetails: () {},
        ),
      );

      expect(find.text('Closed'), findsOne);
      expect(find.text('Open now'), findsNothing);
    });

    testWidgets('Book and Details fire their callbacks', (tester) async {
      var booked = 0;
      var details = 0;
      await _pump(
        tester,
        PlaceDialog(
          center: const CenterSummary(id: '1', name: 'Nasr Center'),
          onBook: () => booked++,
          onDetails: () => details++,
        ),
      );

      await tester.tap(find.text('Book'));
      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(booked, 1);
      expect(details, 1);
    });
  });
}
