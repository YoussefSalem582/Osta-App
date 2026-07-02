import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/router/session_redirect.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_state.dart';

const _enrolled = SessionState(bootstrapped: true, locale: Locale('en'));

void main() {
  group('resolveRedirect', () {
    test('holds on splash until bootstrapped', () {
      const state = SessionState();
      expect(
        resolveRedirect(session: state, location: AppRoutes.role),
        AppRoutes.splash,
      );
      expect(
        resolveRedirect(session: state, location: AppRoutes.splash),
        isNull,
      );
    });

    test('first run routes to the language screen', () {
      const state = SessionState(bootstrapped: true);
      expect(
        resolveRedirect(session: state, location: AppRoutes.splash),
        AppRoutes.language,
      );
    });

    test('after language, with no role, routes to the chooser', () {
      expect(
        resolveRedirect(session: _enrolled, location: AppRoutes.language),
        AppRoutes.role,
      );
    });

    test('role chosen but no token routes to auth', () {
      final state = _enrolled.copyWith(activeRole: AppRole.customer);
      expect(
        resolveRedirect(session: state, location: AppRoutes.role),
        AppRoutes.auth,
      );
    });

    group('authenticated role lands in the matching shell', () {
      const cases = {
        AppRole.customer: AppRoutes.customerShell,
        AppRole.business: AppRoutes.businessShell,
        AppRole.mechanic: AppRoutes.comingSoon,
        AppRole.tow: AppRoutes.comingSoon,
      };
      for (final entry in cases.entries) {
        final role = entry.key;
        final shell = entry.value;
        test('${role.name} -> $shell', () {
          final state = _enrolled.copyWith(activeRole: role, hasToken: true);
          expect(
            resolveRedirect(session: state, location: AppRoutes.auth),
            shell,
          );
          // Already on the right shell: stay put.
          expect(resolveRedirect(session: state, location: shell), isNull);
        });
      }
    });

    test('cross-shell navigation is pinned back to the active shell', () {
      final state = _enrolled.copyWith(
        activeRole: AppRole.customer,
        hasToken: true,
      );
      expect(
        resolveRedirect(session: state, location: AppRoutes.businessShell),
        AppRoutes.customerShell,
      );
    });

    test('the dev gallery is always reachable', () {
      const state = SessionState();
      expect(
        resolveRedirect(session: state, location: AppRoutes.gallery),
        isNull,
      );
    });
  });
}
