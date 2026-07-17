/// API endpoint paths, relative to the `/api/v1` base URL configured in
/// `AppConfig`. Do not prefix with `/api/v1` — `ApiClient`'s base URL already
/// carries it. Mirrors the Laravel backend `routes/api/` definitions.
///
/// Fixed paths are `const` strings; paths with route params are functions.
class ApiEndpoints {
  const ApiEndpoints._();
  static const String baseUrl = 'https://osta.technology92.com/api/v1';
  // --- Auth ---
  static const authCheckUsername = '/auth/check-username';
  static const authLogin = '/auth/login';
  static const authLogout = '/auth/logout';
  // NOTE: the live repo ships these flat paths, not the REST-nested
  // `/auth/password/{forgot,reset}` this catalogue originally assumed. Kept as
  // shipped — verify against the Laravel `routes/api/` before changing either.
  static const authPasswordForgot = '/forgot-password';
  static const authPasswordReset = '/reset-password';
  static const authRefresh = '/auth/refresh';
  static const authRegister = '/auth/register';
  static String authSocial(String provider) => '/auth/social/$provider';

  // --- Me (current user) ---
  static const me = '/me';
  static const meAvatar = '/me/avatar';
  static const meAddresses = '/me/addresses';
  static String meAddress(Object address) => '/me/addresses/$address';
  static const meProducts = '/me/products';
  static String meProduct(Object product) => '/me/products/$product';

  // --- Bookings (customer) ---
  static const bookings = '/bookings';
  static String booking(Object id) => '/bookings/$id';
  static String bookingCancel(Object id) => '/bookings/$id/cancel';
  static String bookingConfirm(Object id) => '/bookings/$id/confirm';
  static String bookingReschedule(Object id) => '/bookings/$id/reschedule';
  static String bookingsByStatus(String status) => '/bookings?status=$status';

  // --- Business ---
  static const businessBookings = '/business/bookings';
  static String businessBookingAccept(Object id) =>
      '/business/bookings/$id/accept';
  static String businessBookingReject(Object id) =>
      '/business/bookings/$id/reject';
  static String businessBookingStatus(Object id) =>
      '/business/bookings/$id/status';
  static String businessBookingAssignMechanic(Object id) =>
      '/business/bookings/$id/assign-mechanic';
  static String businessBookingAssignRosterMechanic(Object id) =>
      '/business/bookings/$id/assign-roster-mechanic';
  static const businessCapacity = '/business/capacity';
  static const businessCatalog = '/business/catalog';
  static const businessCatalogPresets = '/business/catalog/presets';
  static const businessDashboard = '/business/dashboard';
  static const businessProfile = '/business/profile';
  static const businessMechanics = '/business/mechanics';
  static String businessMechanic(Object id) => '/business/mechanics/$id';
  static const businessPromotions = '/business/promotions';
  static String businessPromotion(Object id) => '/business/promotions/$id';
  static const businessServices = '/business/services';
  static String businessService(Object id) => '/business/services/$id';

  // --- Centers ---
  static const centersNearby = '/centers/nearby';
  static const centersSearch = '/centers/search';
  static String center(Object id) => '/centers/$id';
  static String centerAvailability(Object id) => '/centers/$id/availability';
  static String centerProducts(Object id) => '/centers/$id/products';
  static String centerReviews(Object id) => '/centers/$id/reviews';
  static String centerServices(Object id) => '/centers/$id/services';

  // --- Products ---
  static const products = '/products';
  static String product(Object id) => '/products/$id';
  static String productEnquiries(Object id) => '/products/$id/enquiries';

  // --- Vehicles ---
  static const vehicles = '/vehicles';
  static String vehicle(Object id) => '/vehicles/$id';
  static String vehicleMaintenance(Object id) => '/vehicles/$id/maintenance';
  static String vehicleMaintenanceExport(Object id) =>
      '/vehicles/$id/maintenance/export';
  static String vehiclePrimary(Object id) => '/vehicles/$id/primary';

  // --- Users (public) ---
  static String userProducts(Object user) => '/users/$user/products';
  static String userReviews(Object user) => '/users/$user/reviews';

  // --- Devices / Notifications / Telemetry ---
  static const devices = '/devices';
  static String device(Object token) => '/devices/$token';
  static const notifications = '/notifications';
  static String notificationRead(Object id) => '/notifications/$id/read';
  static const telemetryBroadcastLatency = '/telemetry/broadcast-latency';
}
