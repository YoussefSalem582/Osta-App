/// Placeholder content for the booking screens.
///
/// ponytail: `/bookings/*` is shipped server-side but not wired here yet
/// (issues #44, #45, #47). These literals were inline in the screens — and
/// `upcoming`/`past` were public top-level consts. Collecting them here keeps
/// the wiring work to a delete of this file plus the call sites.
///
/// Deliberately NOT localized: fake data standing in for an API response, not
/// UI copy.
library;

import 'package:osta/features/customer/booking/data/model/booking_item.dart';

abstract final class BookingFixtures {
  static const upcoming = [
    BookingItem(
      id: 'OSTA-B2046',
      centerName: 'مركز النصر للصيانة',
      address: 'شبرا زيد وفلر',
      date: 'النهاردة ١٢:٠٠',
      price: 'ج٣٦٠',
      status: BookingStatus.pending,
    ),
    BookingItem(
      id: 'OSTA-B2047',
      centerName: 'ورشة الأمانة',
      address: 'مكمش قوارص الداخلية',
      date: 'بكرة ١٠:٣٠',
      price: 'ج٤٢٠',
      status: BookingStatus.confirmed,
    ),
  ];

  static const past = [
    BookingItem(
      id: 'OSTA-B2040',
      centerName: 'مركز النصر للصيانة',
      address: 'مواتير وطزارب',
      date: '٢ يناير',
      price: 'ج١٨٠',
      status: BookingStatus.completed,
    ),
  ];

  /// Booking-date screen summary total.
  static const totalPrice = '٢٥٠ ج';

  // LiveBookingScreen's placeholders are deliberately left where they are:
  // they're already grouped as named consts at the top of BookingView
  // alongside bookingCode and liveChannel, which is the same "one place to
  // delete" this file exists to create.
}
