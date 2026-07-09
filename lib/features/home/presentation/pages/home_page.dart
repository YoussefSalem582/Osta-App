import 'package:flutter/material.dart';
import 'package:osta/features/home/presentation/widgets/active_booking_card.dart';
import 'package:osta/features/home/presentation/widgets/book_service_card.dart';
import 'package:osta/features/home/presentation/widgets/home_header.dart';
import 'package:osta/features/home/presentation/widgets/nearby_centers_section.dart';
import 'package:osta/features/home/presentation/widgets/shop_section.dart';

/// Customer Home tab content: header, active booking, quick book, nearby
/// centers, and the shop strip. Rendered as index 0 of the customer shell.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(),
            SizedBox(height: 20),
            ActiveBookingCard(),
            SizedBox(height: 20),
            BookServiceCard(),
            SizedBox(height: 30),
            NearbyCentersSection(),
            SizedBox(height: 30),
            ShopSection(),
          ],
        ),
      ),
    );
  }
}
