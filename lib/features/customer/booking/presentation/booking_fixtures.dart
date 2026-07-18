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

  static const totalPrice = '٢٥٠ ج';

}
