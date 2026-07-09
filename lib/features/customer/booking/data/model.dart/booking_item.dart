enum BookingStatus { pending, confirmed, completed, cancelled }

class BookingItem {
  const BookingItem({
    required this.id,
    required this.centerName,
    required this.address,
    required this.date,
    required this.price,
    required this.status,
  });

  final String id;
  final String centerName;
  final String address;
  final String date;
  final String price;
  final BookingStatus status;
}
