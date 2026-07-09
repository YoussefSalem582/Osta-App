import 'package:flutter/material.dart';
import 'package:osta/features/home/presentation/widgets/active_booking_card.dart';
import 'package:osta/features/home/presentation/widgets/book_service_card.dart';
import 'package:osta/features/home/presentation/widgets/home_header.dart';
import 'package:osta/features/home/presentation/widgets/nearby_centers_section.dart';
import 'package:osta/features/home/presentation/widgets/shop_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const path = '/home';

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
