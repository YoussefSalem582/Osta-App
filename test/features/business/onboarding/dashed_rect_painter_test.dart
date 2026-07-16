import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/features/business/onboarding/presentation/widgets/dashed_rect_painter.dart';

/// Counts `drawPath` calls so the dash loop is observable — a dashed outline is
/// many short subpaths, a solid one would be a single call.
class _CountingCanvas implements Canvas {
  int drawPathCalls = 0;

  @override
  void drawPath(Path path, Paint paint) => drawPathCalls++;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('repaints only when colour or radius changes', () {
    const base = DashedRectPainter(color: Colors.red, radius: 8);

    expect(base.shouldRepaint(base), isFalse);
    expect(
      base.shouldRepaint(
        const DashedRectPainter(color: Colors.blue, radius: 8),
      ),
      isTrue,
    );
    expect(
      base.shouldRepaint(
        const DashedRectPainter(color: Colors.red, radius: 16),
      ),
      isTrue,
    );
  });

  test('paints many dashes, not one solid outline', () {
    final canvas = _CountingCanvas();
    const DashedRectPainter(
      color: Colors.black,
      radius: 8,
    ).paint(canvas, const Size(100, 50));

    // Perimeter ~300px at a 10px dash+gap stride -> roughly 30 dashes. Assert
    // the shape of the answer, not the exact count: >1 proves it dashes at all,
    // and a sane upper bound proves the loop terminates rather than spinning.
    expect(canvas.drawPathCalls, greaterThan(10));
    expect(canvas.drawPathCalls, lessThan(100));
  });

  test('a zero-size rect terminates instead of looping forever', () {
    final canvas = _CountingCanvas();
    const DashedRectPainter(
      color: Colors.black,
      radius: 0,
    ).paint(canvas, Size.zero);
    expect(canvas.drawPathCalls, 0);
  });

  testWidgets('renders inside a CustomPaint without throwing', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CustomPaint(
              painter: DashedRectPainter(color: Colors.black, radius: 8),
              size: Size(100, 50),
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  test('dash stride is independent of colour', () {
    int dashesFor(Color color) {
      final canvas = _CountingCanvas();
      DashedRectPainter(
        color: color,
        radius: 8,
      ).paint(canvas, const Size(100, 50));
      return canvas.drawPathCalls;
    }

    expect(dashesFor(Colors.red), dashesFor(Colors.blue));
  });

  test('ui.Canvas contract is still satisfied by the stub', () {
    // Guards the test double: if Canvas gains members this stub silently
    // no-ops them, but drawPath must stay real.
    expect(_CountingCanvas(), isA<ui.Canvas>());
  });
}
