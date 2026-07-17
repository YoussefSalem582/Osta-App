/// Every navigable location, in one place, so the redirect resolver and the
/// route table can't drift apart.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const language = '/language';
  static const onboarding = '/onboarding';

  /// Logged-out merchant marketing carousel (parallel to [onboarding]).
  static const merchantOnboarding = '/onboarding/business';
  static const role = '/role';
  static const authChoose = '/auth/choose';
  static const login = '/auth';

  /// Customer sign-up.
  static const register = '/auth/register';

  /// Business sign-up (parallel to [register], as [merchantOnboarding] is to
  /// [onboarding]). Same fields — `account_type` is what differs on the wire.
  static const registerBusiness = '/auth/register/business';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';
  static const customerShell = '/customer';
  static const businessShell = '/business';
  // Business technicians screen, pushed from the shell's More tab.
  static const technicians = '/business/technicians';
  // Business onboarding wizard (shown to an authed business user until done).
  static const businessIdentity = '/business-identity';
  static const businessCatalog = '/business-catalog';
  static const comingSoon = '/coming-soon';
  static const garage = '/garage';
  static const addCar = '/add-car';
  static const bookingStatus = '/booking-status';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const myBookings = '/my-bookings';
  static const home = '/home';

  // Shop (#48) — two-sided marketplace, shared by both roles.
  /// Marketplace browse grid (also the customer Store tab).
  static const shopBrowse = '/shop';

  /// Product detail; `extra` is the product id (`String`).
  static const productDetail = '/product';

  /// One seller's storefront; `extra` is a `SellerCatalogArgs`.
  static const sellerCatalog = '/seller-catalog';

  /// Own listings management (also the business Store tab).
  static const myProducts = '/my-products';

  /// Create / edit an own product; `extra` is a `Product?` (null = create).
  static const productForm = '/product-form';
}
