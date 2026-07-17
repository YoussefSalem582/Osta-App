/// Placeholder content for the Home feed.
///
/// ponytail: the Home tab has no repository yet — every widget below the header
/// renders these literals. They live here, in one file, rather than inline in
/// the widgets so that wiring Home to real data (issue #51) is a delete of this
/// file plus the call sites, not an archaeology dig through the widget tree.
///
/// Deliberately NOT localized: this is fake *data* standing in for an API
/// response, not UI copy. Putting it in the ARBs would tell translators to
/// translate a mock customer's name.
library;

abstract final class HomeFixtures {
  /// Signed-in customer's display name, pending `GET /me`.
  static const customerName = 'أحمد فؤاد';

  /// The in-progress booking on the header card.
  static const activeBookingService = 'تغيير زيت وفلتر';
  static const activeBookingCenter = 'مركز النصر';

  /// Nearby service centres rail.
  static const List<({String distance, String name, double rate})> centers = [
    (name: 'ورشة الأمانة', distance: '2 KM', rate: 4.6),
    (name: 'مركز النصر', distance: '1.2 KM', rate: 4.8),
  ];

  /// Shop rail.
  static const List<({String name, String price})> products = [
    (name: 'إطار ميشلان', price: '2800 ج'),
    (name: 'زيت موبيل', price: '250 ج'),
  ];
}
