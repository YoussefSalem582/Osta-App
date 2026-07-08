import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/app.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/di/injection.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/fakes.dart';

/// Boots [OstaApp] with mocked persistence: [SharedPreferences] seeded with
/// [prefs] and an in-memory [TokenStorage] holding [token] (secure storage has
/// no platform channel in tests).
Future<void> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  String? token,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  await configureDependencies();
  final tokens = FakeTokenStorage()..access = token;
  if (getIt.isRegistered<TokenStorage>()) getIt.unregister<TokenStorage>();
  getIt.registerLazySingleton<TokenStorage>(() => tokens);
  addTearDown(getIt.reset);

  await tester.pumpWidget(const OstaApp());
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first run: splash → language → role chooser', (tester) async {
    await _pumpApp(tester);

    // Language screen is shown on a true first run.
    expect(find.text('Choose your language'), findsOneWidget);

    // Splash is shown first (brand logo).
    expect(find.byType(Image), findsOneWidget);

    // After the splash delay, onboarding appears.
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
