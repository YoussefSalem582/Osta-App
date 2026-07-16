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

    test('each role is pinned to its own register screen', () {
      SessionState atAuth(AppRole role) => SessionState(
        bootstrapped: true,
        languageAcknowledged: true,
        roleAcknowledged: true,
        onboardingAcknowledged: true,
        activeRole: role,
      );

      // RegisterBloc takes account_type from the session, not the URL. If a
      // customer could sit on /auth/register/business they would read "Create
      // business account" and register as a customer.
      expect(
        resolveRedirect(
          session: atAuth(AppRole.customer),
          location: AppRoutes.register,
        ),
        isNull,
      );
      expect(
        resolveRedirect(
          session: atAuth(AppRole.customer),
          location: AppRoutes.registerBusiness,
        ),
        AppRoutes.register,
        reason: 'a customer must be bounced off the business register',
      );

      expect(
        resolveRedirect(
          session: atAuth(AppRole.business),
          location: AppRoutes.registerBusiness,
        ),
        isNull,
      );
      expect(
        resolveRedirect(
          session: atAuth(AppRole.business),
          location: AppRoutes.register,
        ),
        AppRoutes.registerBusiness,
        reason: 'a business user must be bounced off the customer register',
      );
    });

    test('the two register routes are distinct', () {
      expect(AppRoutes.register, isNot(AppRoutes.registerBusiness));
      expect(AppRoutes.registerBusiness, startsWith(AppRoutes.register));
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
