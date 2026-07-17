import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/shared/ui/app_segmented_toggle.dart';

void main() {
  Future<int?> tapSecond(WidgetTester tester, {bool expand = false}) async {
    int? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSegmentedToggle(
            options: const ['Light', 'Dark'],
            selectedIndex: 0,
            onSelect: (i) => picked = i,
            expand: expand,
          ),
        ),
      ),
    );
    await tester.tap(find.text('Dark'));
    return picked;
  }

  testWidgets('reports the tapped index, not the label', (tester) async {
    expect(await tapSecond(tester), 1);
  });

  testWidgets('index API survives duplicate labels', (tester) async {
    // The string-based API this replaced could not distinguish these — the old
    // SegmentedToggle compared `option == selected`, so both would highlight.
    var picked = -1;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AppSegmentedToggle(
            options: const ['All', 'All'],
            selectedIndex: 0,
            onSelect: (i) => picked = i,
          ),
        ),
      ),
    );
    await tester.tap(find.text('All').last);
    expect(picked, 1);
  });

  testWidgets('expand splits width evenly; compact hugs the labels', (
    tester,
  ) async {
    for (final expand in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSegmentedToggle(
              options: const ['A', 'Much longer label'],
              selectedIndex: 0,
              onSelect: (_) {},
              expand: expand,
            ),
          ),
        ),
      );
      final a = tester.getSize(find.text('A'));
      final b = tester.getSize(find.text('Much longer label'));
      if (expand) {
        expect(
          find.byType(Expanded),
          findsNWidgets(2),
          reason: 'expand must lay tabs out with Expanded',
        );
      } else {
        expect(find.byType(Expanded), findsNothing);
        expect(
          a.width < b.width,
          isTrue,
          reason: 'compact tabs size to their own label',
        );
      }
    }
  });
}
