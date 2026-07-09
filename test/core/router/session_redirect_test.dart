import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/router/session_redirect.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_state.dart';

/// Past every logged-out gate (language, role, onboarding acknowledged) with a
/// role set: ready for the auth surface. Flow: language → role → onboarding →
/// auth.
const _enrolled = SessionState(
  bootstrapped: true,
  locale: Locale('en'),
  languageAcknowledged: true,
  roleAcknowledged: true,
  activeRole: AppRole.customer,
  onboardingAcknowledged: true,
);

/// Past language only — the next gate is the role chooser.
const _pastLanguage = SessionState(
  bootstrapped: true,
  locale: Locale('en'),
  languageAcknowledged: true,
);

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

    group('logged-out language', () {
      const state = SessionState(bootstrapped: true);

      test('routes to the language screen first', () {
        expect(
          resolveRedirect(session: state, location: AppRoutes.splash),
          AppRoutes.language,
        );
      });

      test('re-shows even when a locale is already saved', () {
        // The in-memory ack gates the screen, not the persisted locale.
        const saved = SessionState(bootstrapped: true, locale: Locale('ar'));
        expect(
          resolveRedirect(session: saved, location: AppRoutes.role),
          AppRoutes.language,
        );
      });
    });

    group('logged-out role chooser', () {
      test('routes to the role chooser after language', () {
        expect(
          resolveRedirect(session: _pastLanguage, location: AppRoutes.language),
          AppRoutes.role,
        );
      });

      test('re-shows even when a role is already saved', () {
        // Persisted role is the default; the in-memory ack gates the screen.
        final saved = _pastLanguage.copyWith(activeRole: AppRole.customer);
        expect(
          resolveRedirect(session: saved, location: AppRoutes.onboarding),
          AppRoutes.role,
        );
      });

      test('stays put once on the chooser', () {
        expect(
          resolveRedirect(session: _pastLanguage, location: AppRoutes.role),
          isNull,
        );
      });

      test('a held token skips the chooser', () {
        final authed = _pastLanguage.copyWith(
          activeRole: AppRole.customer,
          hasToken: true,
        );
        expect(
          resolveRedirect(session: authed, location: AppRoutes.role),
          AppRoutes.customerShell,
        );
      });
    });

    group('logged-out onboarding (after role)', () {
      // Language + role acknowledged, onboarding not yet.
      const state = SessionState(
        bootstrapped: true,
        locale: Locale('en'),
        languageAcknowledged: true,
        roleAcknowledged: true,
        activeRole: AppRole.customer,
      );

      test('routes to onboarding after the role chooser', () {
        expect(
          resolveRedirect(session: state, location: AppRoutes.role),
          AppRoutes.onboarding,
        );
      });

      test('stays put once on onboarding', () {
        expect(
          resolveRedirect(session: state, location: AppRoutes.onboarding),
          isNull,
        );
      });

      test('a token skips onboarding even when not acknowledged', () {
        final authed = state.copyWith(hasToken: true);
        expect(
          resolveRedirect(session: authed, location: AppRoutes.onboarding),
          AppRoutes.customerShell,
        );
      });
    });

    test('all gates done, no token, routes to auth-choose', () {
      expect(
        resolveRedirect(session: _enrolled, location: AppRoutes.role),
        AppRoutes.authChoose,
      );
      // The login and register forms are part of the same surface: stay put.
      expect(
        resolveRedirect(session: _enrolled, location: AppRoutes.login),
        isNull,
      );
      expect(
        resolveRedirect(session: _enrolled, location: AppRoutes.register),
        isNull,
      );
    });

    test('password-recovery routes are reachable without a token', () {
      expect(
        resolveRedirect(session: _enrolled, location: AppRoutes.forgotPassword),
        isNull,
      );
      expect(
        resolveRedirect(session: _enrolled, location: AppRoutes.resetPassword),
        isNull,
      );
      // Any other unauthenticated location still bounces to auth-choose.
      expect(
        resolveRedirect(session: _enrolled, location: AppRoutes.customerShell),
        AppRoutes.authChoose,
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
          var state = _enrolled.copyWith(activeRole: role, hasToken: true);
          // Business only reaches its shell after the onboarding wizard.
          if (role == AppRole.business) {
            state = state.copyWith(businessOnboarded: true);
          }
          expect(
            resolveRedirect(session: state, location: AppRoutes.login),
            shell,
          );
          // Already on the right shell: stay put.
          expect(resolveRedirect(session: state, location: shell), isNull);
        });
      }
    });

    group('authenticated business runs the onboarding wizard first', () {
      final fresh = _enrolled.copyWith(
        activeRole: AppRole.business,
        hasToken: true,
      );

      test('is forced into the wizard before the shell', () {
        expect(
          resolveRedirect(session: fresh, location: AppRoutes.businessShell),
          AppRoutes.providerOnboarding,
        );
      });

      test('the three wizard screens are reachable', () {
        for (final location in [
          AppRoutes.providerOnboarding,
          AppRoutes.businessIdentity,
          AppRoutes.businessCatalog,
        ]) {
          expect(resolveRedirect(session: fresh, location: location), isNull);
        }
      });

      test('once completed, lands in the shell and leaves the wizard', () {
        final done = fresh.copyWith(businessOnboarded: true);
        expect(
          resolveRedirect(session: done, location: AppRoutes.businessShell),
          isNull,
        );
        expect(
          resolveRedirect(
            session: done,
            location: AppRoutes.providerOnboarding,
          ),
          AppRoutes.businessShell,
        );
      });
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

    test('authenticated in-app screens are reachable (not pinned)', () {
      final state = _enrolled.copyWith(
        activeRole: AppRole.customer,
        hasToken: true,
      );
      for (final location in [
        AppRoutes.profile,
        AppRoutes.garage,
        AppRoutes.addCar,
        AppRoutes.bookingStatus,
      ]) {
        expect(
          resolveRedirect(session: state, location: location),
          isNull,
          reason: '$location should be reachable while authenticated',
        );
      }
    });
  });
}
