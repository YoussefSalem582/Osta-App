import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/core/theme/app_theme.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';
import 'package:osta/shared/ui/app_top_bar.dart';

const _items = [
  AppBottomNavItem(icon: Icons.home_outlined, label: 'Home'),
  AppBottomNavItem(icon: Icons.map_outlined, label: 'Map'),
  AppBottomNavItem(
    icon: Icons.notifications_outlined,
    label: 'Alerts',
    badgeCount: 3,
  ),
];

Future<void> pump(
  WidgetTester tester,
  Widget home, {
  Brightness brightness = Brightness.light,
  String locale = 'en',
}) => tester.pumpWidget(
  MaterialApp(
    theme: brightness == Brightness.light ? AppTheme.light() : AppTheme.dark(),
    locale: Locale(locale),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  ),
);

void main() {
  final matrix = [
    (Brightness.light, 'en'),
    (Brightness.light, 'ar'),
    (Brightness.dark, 'en'),
    (Brightness.dark, 'ar'),
  ];

  for (final (brightness, locale) in matrix) {
    testWidgets('nav widgets render in ${brightness.name}/$locale', (
      tester,
    ) async {
      await pump(
        tester,
        Scaffold(
          appBar: const AppTopBar(title: 'Title'),
          body: const SizedBox(),
          bottomNavigationBar: AppBottomNavBar(
            items: _items,
            currentIndex: 0,
            onChanged: (_) {},
          ),
        ),
        brightness: brightness,
        locale: locale,
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Title'), findsOneWidget);
      expect(find.byType(AppBottomNavBar), findsOneWidget);
    });
  }

  testWidgets('bottom nav tap reports index and selection follows state', (
    tester,
  ) async {
    var selected = 0;
    await pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => Scaffold(
          bottomNavigationBar: AppBottomNavBar(
            items: _items,
            currentIndex: selected,
            onChanged: (i) => setState(() => selected = i),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Map'));
    await tester.pumpAndSettle();

    expect(selected, 1);
  });

  testWidgets('center action fires its callback without changing the tab', (
    tester,
  ) async {
    var selected = 0;
    var centerTaps = 0;
    await pump(
      tester,
      Scaffold(
        bottomNavigationBar: AppBottomNavBar(
          items: _items,
          currentIndex: selected,
          onChanged: (i) => selected = i,
          centerIcon: Icons.location_on_outlined,
          onCenterTap: () => centerTaps++,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.location_on_outlined));
    await tester.pumpAndSettle();

    expect(centerTaps, 1);
    expect(selected, 0); // the raised action is not a tab
  });

  testWidgets('badge shows count only when > 0', (tester) async {
    await pump(
      tester,
      Scaffold(
        bottomNavigationBar: AppBottomNavBar(
          items: _items,
          currentIndex: 0,
          onChanged: (_) {},
        ),
      ),
    );

    expect(find.byType(Badge), findsOneWidget); // only the Alerts item
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('top bar shows back button on pushed route and pops', (
    tester,
  ) async {
    await pump(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Scaffold(
                    appBar: AppTopBar(title: 'Second'),
                  ),
                ),
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );

    // Root route: no back button.
    expect(find.byType(BackButton), findsNothing);

    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsOneWidget);
    expect(find.byType(BackButton), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('Second'), findsNothing);
  });

  testWidgets('top bar onBack overrides pop', (tester) async {
    var custom = 0;
    await pump(
      tester,
      Scaffold(
        appBar: AppTopBar(title: 'T', onBack: () => custom++),
      ),
    );

    await tester.tap(find.byType(BackButton));
    expect(custom, 1);
  });
}
