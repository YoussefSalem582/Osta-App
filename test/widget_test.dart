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

    // Picking a language advances to the role chooser (never back to language).
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Choose how you want to continue'), findsOneWidget);
    expect(find.text('Choose your language'), findsNothing);
  });

  testWidgets('relaunch with {token, activeRole} skips straight to the shell', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      prefs: {'session_locale': 'en', 'session_active_role': 'customer'},
      token: 'valid-token',
    );

    // Lands in the shell (bottom nav) — no language or chooser in sight.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Choose your language'), findsNothing);
    expect(find.text('Choose how you want to continue'), findsNothing);
  });
}
