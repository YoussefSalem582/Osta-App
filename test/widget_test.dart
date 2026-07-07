import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/app.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/features/role/presentation/widgets/info_banner.dart';
import 'package:osta/features/role/presentation/widgets/role_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('OstaApp boots into splash then role selection', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
    addTearDown(getIt.reset);

    await tester.pumpWidget(const OstaApp());
    await tester.pump();

    // Splash is shown first (brand logo).
    expect(find.byType(Image), findsOneWidget);

    // After the splash delay, first-run role selection appears.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(RoleCard), findsNWidgets(4));
    expect(find.byType(InfoBanner), findsOneWidget);
  });
}
