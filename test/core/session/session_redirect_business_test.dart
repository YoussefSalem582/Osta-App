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

  group('resolveRedirect — required add-car gate (#39)', () {
    SessionState customer({bool? hasVehicle}) => SessionState(
      bootstrapped: true,
      hasToken: true,
      activeRole: AppRole.customer,
      hasVehicle: hasVehicle,
    );

    test('a carless customer is forced to add-car from anywhere', () {
      // "No car means no Home — the gate cannot be skipped."
      for (final location in [
        AppRoutes.customerShell,
        AppRoutes.home,
        AppRoutes.profile,
        AppRoutes.garage,
        AppRoutes.bookingStatus,
      ]) {
        expect(
          resolveRedirect(
            session: customer(hasVehicle: false),
            location: location,
          ),
          AppRoutes.addCar,
          reason: '$location must not be reachable without a car',
        );
      }
    });

    test('the gate lets its own screen through', () {
      expect(
        resolveRedirect(
          session: customer(hasVehicle: false),
          location: AppRoutes.addCar,
        ),
        isNull,
      );
    });

    test(
      'a customer with a car reaches the shell, and add-car still opens',
      () {
        expect(
          resolveRedirect(
            session: customer(hasVehicle: true),
            location: AppRoutes.customerShell,
          ),
          isNull,
        );
        // The garage's "+" pushes the same screen to add an Nth car, so
        // /add-car stays legal once a car exists.
        //
        // Which means releasing the gate does NOT evict anyone from it: this
        // returns null, i.e. "stay put". AddCarScreen has to navigate itself
        // on success — and when the gate forced the screen there is nothing to
        // pop, so it must `go` explicitly. Reading this null as "the redirect
        // will carry them to the shell" is what stranded users on a dead
        // screen, tapping Save until they had two cars.
        expect(
          resolveRedirect(
            session: customer(hasVehicle: true),
            location: AppRoutes.addCar,
          ),
          isNull,
        );
      },
    );

    test('an unresolved check fails open rather than stranding the user', () {
      // null = the GET /vehicles check never completed (offline, timeout).
      // Gating on that would lock someone out of the app over a flaky network.
      expect(
        resolveRedirect(
          session: customer(),
          location: AppRoutes.customerShell,
        ),
        isNull,
      );
    });

    test('the gate never applies to business users', () {
      // Regression guard: business has its own wizard and no vehicles.
      const business = SessionState(
        bootstrapped: true,
        hasToken: true,
        activeRole: AppRole.business,
        businessOnboarded: true,
        hasVehicle: false,
      );
      expect(
        resolveRedirect(session: business, location: AppRoutes.businessShell),
        isNull,
      );
    });

    test('auth still comes first for a logged-out customer', () {
      const loggedOut = SessionState(
        bootstrapped: true,
        languageAcknowledged: true,
        roleAcknowledged: true,
        onboardingAcknowledged: true,
        activeRole: AppRole.customer,
        hasVehicle: false,
      );
      expect(
        resolveRedirect(session: loggedOut, location: AppRoutes.customerShell),
        AppRoutes.authChoose,
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
