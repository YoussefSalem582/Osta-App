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
  static const comingSoon = '/coming-soon';
  static const garage = '/garage';
  static const addCar = '/add-car';
  static const bookingStatus = '/booking-status';
  static const profile = '/profile';
}
