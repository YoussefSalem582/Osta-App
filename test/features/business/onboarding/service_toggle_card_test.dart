import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/l10n/app_localizations.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/service_toggle_card.dart';

/// The custom-service row used to be a `Switch` wired to remove-on-off — a
/// merchant flipping it off silently deleted their typed service. These pin the
/// two modes apart: presets toggle, custom services delete, and never the mix.
void main() {
  Future<void> pump(WidgetTester tester, Widget card) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: card),
    ),
  );

  group('toggle mode (presets)', () {
    testWidgets('shows a Switch and flips it by tapping the card', (
      tester,
    ) async {
      bool? changed;
      await pump(
        tester,
        ServiceToggleCard(
          title: 'Oil change',
          subtitle: 'Oils',
          price: 'EGP 350',
          isSelected: false,
          onChanged: (v) => changed = v,
        ),
      );

      expect(find.byType(Switch), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNothing);

      await tester.tap(find.byType(ServiceToggleCard));
      expect(changed, isTrue);
    });
  });

  group('removable mode (custom services)', () {
    testWidgets('shows a delete button and a Custom badge, never a Switch', (
      tester,
    ) async {
      var removed = 0;
      await pump(
        tester,
        ServiceToggleCard(
          title: 'Ceramic coating',
          subtitle: 'Detailing',
          price: 'EGP 1,200',
          onRemove: () => removed++,
        ),
      );

      // The trap this replaced: a removable row must not carry a Switch.
      expect(find.byType(Switch), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
      final l10n = await AppLocalizations.delegate.load(const Locale('en'));
      expect(find.text(l10n.businessCatalogCustomBadge), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(removed, 1);
    });
  });

  test('requires exactly one of onChanged / onRemove', () {
    expect(
      () => ServiceToggleCard(
        title: 't',
        subtitle: 's',
        price: 'p',
        onChanged: (_) {},
        onRemove: () {},
      ),
      throwsAssertionError,
    );
    expect(
      () => ServiceToggleCard(title: 't', subtitle: 's', price: 'p'),
      throwsAssertionError,
    );
  });
}
