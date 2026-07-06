import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/network/auth_events.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_controller.dart';
import 'package:osta/core/session/session_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/fakes.dart';

typedef _Harness = (SessionController, FakeTokenStorage, AuthEvents);

Future<_Harness> _build(Map<String, Object> seed) async {
  SharedPreferences.setMockInitialValues(seed);
  final prefs = await SharedPreferences.getInstance();
  final tokens = FakeTokenStorage();
  final events = AuthEvents();
  final controller = SessionController(SessionStore(prefs, tokens), events);
  return (controller, tokens, events);
}

Future<void> _teardown(_Harness harness) async {
  await harness.$1.close();
  await harness.$3.dispose();
}

void main() {
  test('bootstrap with a persisted token + role lands authenticated', () async {
    final harness = await _build({
      'session_locale': 'en',
      'session_active_role': 'business',
    });
    final (controller, tokens, _) = harness;
    tokens.access = 'token';

    await controller.bootstrap();

    expect(controller.state.bootstrapped, isTrue);
    expect(controller.state.locale, const Locale('en'));
    expect(controller.state.activeRole, AppRole.business);
    expect(controller.state.hasToken, isTrue);
    await _teardown(harness);
  });

  test('first-run bootstrap has no locale, role or token', () async {
    final harness = await _build({});
    await harness.$1.bootstrap();

    expect(harness.$1.state.isLanguageSelected, isFalse);
    expect(harness.$1.state.activeRole, isNull);
    expect(harness.$1.state.hasToken, isFalse);
    await _teardown(harness);
  });

  test('chooseLanguage persists and emits the locale', () async {
    final harness = await _build({});
    await harness.$1.bootstrap();
    await harness.$1.chooseLanguage(const Locale('ar'));

    expect(harness.$1.state.locale, const Locale('ar'));
    await _teardown(harness);
  });

  test('switchRole clears the role but keeps the token', () async {
    final harness = await _build({
      'session_locale': 'en',
      'session_active_role': 'customer',
    });
    final (controller, tokens, _) = harness;
    tokens.access = 'token';
    await controller.bootstrap();

    await controller.switchRole();

    expect(controller.state.activeRole, isNull);
    expect(controller.state.hasToken, isTrue);
    expect(tokens.access, 'token');
    await _teardown(harness);
  });

  test('onAuthenticated heals a wrong-shell choice and flags it', () async {
    final harness = await _build({'session_locale': 'en'});
    final controller = harness.$1;
    await controller.bootstrap();

    await controller.onAuthenticated(
      AppRole.business,
      requested: AppRole.customer,
    );

    expect(controller.state.activeRole, AppRole.business);
    expect(controller.state.hasToken, isTrue);
    expect(controller.state.correctedRole, AppRole.business);

    controller.acknowledgeCorrection();
    expect(controller.state.correctedRole, isNull);
    await _teardown(harness);
  });

  test('a matching role does not flag a correction', () async {
    final harness = await _build({'session_locale': 'en'});
    await harness.$1.onAuthenticated(
      AppRole.customer,
      requested: AppRole.customer,
    );

    expect(harness.$1.state.correctedRole, isNull);
    expect(harness.$1.state.hasToken, isTrue);
    await _teardown(harness);
  });

  test('the session-expired signal drops the token', () async {
    final harness = await _build({
      'session_locale': 'en',
      'session_active_role': 'customer',
    });
    final (controller, tokens, events) = harness;
    tokens.access = 'token';
    await controller.bootstrap();

    events.emitSessionExpired();
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(controller.state.hasToken, isFalse);
    await _teardown(harness);
  });
}
