import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/app.dart';
import 'package:osta/core/auth/token_storage.dart';
import 'package:osta/core/di/injection.dart';
import 'package:osta/shared/ui/app_bottom_nav_bar.dart';
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
  // Splash holds for a 2s branding beat, then bootstraps; advance past it so
  // the redirect guard drives the flow.
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('first run: language → role → onboarding → auth-choose', (
    tester,
  ) async {
    await _pumpApp(tester);

    // Language screen is shown first while logged out.
    expect(find.text('Choose your language'), findsOneWidget);

    // Picking a language advances to the role chooser.
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();
    expect(find.text('Who are you?'), findsOneWidget);

    // Picking a role advances to the logged-out onboarding intro.
    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();
    expect(find.text('Car maintenance in minutes'), findsOneWidget);

    // Tap through the intro; the last slide acknowledges and the guard
    // advances to the auth-choose landing.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to OSTA'), findsOneWidget);
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
    expect(find.byType(AppBottomNavBar), findsOneWidget);
    expect(find.text('Choose your language'), findsNothing);
    expect(find.text('Who are you?'), findsNothing);
  });

  testWidgets('customer shell tabs render their bodies under one app bar', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      prefs: {'session_locale': 'en', 'session_active_role': 'customer'},
      token: 'valid-token',
    );

    // Each tab swaps the shell body; the shell keeps exactly one app bar and
    // one bottom nav (the bodies are scaffold-less views, not full screens).
    for (final tab in ['My Bookings', 'More', 'Home']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(find.byType(AppBottomNavBar), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget, reason: '$tab: one app bar');
    }
  });
}
