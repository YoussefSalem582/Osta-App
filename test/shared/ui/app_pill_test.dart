import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/theme/app_tokens.dart';
import 'package:osta/shared/ui/app_pill.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) => tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: child)),
    ),
  );

  BoxDecoration decorationOf(WidgetTester tester) =>
      tester.widget<Container>(find.byType(Container)).decoration!
          as BoxDecoration;

  testWidgets('is always pill-shaped and paints its background', (
    tester,
  ) async {
    await pump(
      tester,
      const AppPill(
        label: 'Pending',
        background: Colors.red,
        foreground: Colors.white,
      ),
    );

    final decoration = decorationOf(tester);
    expect(decoration.color, Colors.red);
    expect(
      decoration.borderRadius,
      BorderRadius.circular(AppRadii.pill),
      reason: 'the pill radius is the whole point of the primitive',
    );
    expect(decoration.border, isNull, reason: 'no border unless asked');
    expect(tester.widget<Text>(find.byType(Text)).style?.color, Colors.white);
  });

  testWidgets('applies a border only when given one', (tester) async {
    await pump(
      tester,
      const AppPill(
        label: 'Selected',
        background: Colors.white,
        foreground: Colors.green,
        border: BorderSide(color: Colors.green, width: 1.5),
      ),
    );

    final border = decorationOf(tester).border! as Border;
    expect(border.top.color, Colors.green);
    expect(border.top.width, 1.5);
  });

  testWidgets('defaults to labelSmall/w600 and honours overrides', (
    tester,
  ) async {
    await pump(
      tester,
      const AppPill(
        label: 'Default',
        background: Colors.grey,
        foreground: Colors.black,
      ),
    );
    final context = tester.element(find.byType(AppPill));
    expect(
      tester.widget<Text>(find.byType(Text)).style?.fontSize,
      Theme.of(context).textTheme.labelSmall?.fontSize,
    );
    expect(
      tester.widget<Text>(find.byType(Text)).style?.fontWeight,
      FontWeight.w600,
    );

    await pump(
      tester,
      const AppPill(
        label: 'Loud',
        background: Colors.grey,
        foreground: Colors.black,
        textStyle: TextStyle(fontSize: 99),
        fontWeight: FontWeight.w700,
      ),
    );
    expect(tester.widget<Text>(find.byType(Text)).style?.fontSize, 99);
    expect(
      tester.widget<Text>(find.byType(Text)).style?.fontWeight,
      FontWeight.w700,
    );
  });
}
