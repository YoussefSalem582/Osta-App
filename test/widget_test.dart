import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/app.dart';
import 'package:osta/core/di/injection.dart';

void main() {
  testWidgets('OstaApp boots into splash then role selection', (tester) async {
    await configureDependencies();
    addTearDown(getIt.reset);

    await tester.pumpWidget(const OstaApp());
    await tester.pump();

    // Splash is shown first.
    expect(find.byType(FlutterLogo), findsOneWidget);

    // After the splash delay, first-run role selection appears.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(FilledButton), findsOneWidget);
  });
}
