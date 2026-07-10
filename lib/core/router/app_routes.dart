/// Every navigable location, in one place, so the redirect resolver and the
/// route table can't drift apart.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const language = '/language';
  static const onboarding = '/onboarding';
  static const role = '/role';
  static const authChoose = '/auth/choose';
  static const login = '/auth';
  static const register = '/auth/register';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const customerShell = '/customer';
  static const businessShell = '/business';
  // Business technicians screen, pushed from the shell's More tab.
  static const technicians = '/business/technicians';
  // Business onboarding wizard (shown to an authed business user until done).
  static const providerOnboarding = '/provider-onboarding';
  static const businessIdentity = '/business-identity';
  static const businessCatalog = '/business-catalog';
  static const comingSoon = '/coming-soon';
  static const garage = '/garage';
  static const addCar = '/add-car';
  static const bookingStatus = '/booking-status';
  static const profile = '/profile';
  static const myBookings = '/my-bookings';
  static const home = '/home';
}
