import 'package:flutter_test/flutter_test.dart';
import 'package:osta/core/router/app_routes.dart';
import 'package:osta/core/router/session_redirect.dart';
import 'package:osta/core/session/app_role.dart';
import 'package:osta/core/session/session_state.dart';

void main() {
  group('resolveRedirect — role-split first-run', () {
    test('customer hits marketing carousel before auth', () {
      const session = SessionState(
        bootstrapped: true,
        languageAcknowledged: true,
        roleAcknowledged: true,
        activeRole: AppRole.customer,
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.authChoose),
        AppRoutes.onboarding,
      );
    });

    test('business hits merchant carousel, not customer slides', () {
      const session = SessionState(
        bootstrapped: true,
        languageAcknowledged: true,
        roleAcknowledged: true,
        activeRole: AppRole.business,
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.role),
        AppRoutes.merchantOnboarding,
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.onboarding),
        AppRoutes.merchantOnboarding,
      );
      expect(
        resolveRedirect(
          session: session,
          location: AppRoutes.merchantOnboarding,
        ),
        isNull,
      );
    });

    test('business reaches auth after acknowledging merchant carousel', () {
      const session = SessionState(
        bootstrapped: true,
        languageAcknowledged: true,
        roleAcknowledged: true,
        onboardingAcknowledged: true,
        activeRole: AppRole.business,
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.authChoose),
        isNull,
      );
    });
  });

  group('resolveRedirect — business onboarding', () {
    test(
      'forces identity wizard when business authenticated and not onboarded',
      () {
        const session = SessionState(
          bootstrapped: true,
          hasToken: true,
          activeRole: AppRole.business,
        );
        expect(
          resolveRedirect(session: session, location: AppRoutes.businessShell),
          AppRoutes.businessIdentity,
        );
        expect(
          resolveRedirect(
            session: session,
            location: AppRoutes.businessIdentity,
          ),
          isNull,
        );
      },
    );

    test('allows shell when businessOnboarded is true', () {
      const session = SessionState(
        bootstrapped: true,
        hasToken: true,
        activeRole: AppRole.business,
        businessOnboarded: true,
      );
      expect(
        resolveRedirect(session: session, location: AppRoutes.businessShell),
        isNull,
      );
    });

    test('allows identity and catalog while wizard is open', () {
      const session = SessionState(
        bootstrapped: true,
        hasToken: true,
        activeRole: AppRole.business,
      );
      expect(
        resolveRedirect(
          session: session,
          location: AppRoutes.businessIdentity,
        ),
        isNull,
      );
      expect(
        resolveRedirect(
          session: session,
          location: AppRoutes.businessCatalog,
        ),
        isNull,
      );
    });
  });
}
