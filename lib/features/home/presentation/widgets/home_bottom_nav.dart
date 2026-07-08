import 'package:flutter/material.dart';
import 'package:osta/features/home/presentation/pages/home_page.dart';

class HomeBottomNav extends StatefulWidget {
  const HomeBottomNav({super.key});

  static const path = '/home';

  @override
  State<HomeBottomNav> createState() => _HomeBottomNavState();
}

class _HomeBottomNavState extends State<HomeBottomNav> {
  int currentIndex = 0;

  final List<Widget> screens = const [
    HomePage(),
    Center(
      child: Text('data'),
    ),
    Center(
      child: Text('data'),
    ),
    Center(
      child: Text('data'),
    ),
    Center(
      child: Text('data'),
    ),
    //   BookingPage(),
    //   MapPage(),
    //   ShopPage(),
    //   MorePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.secondaryContainer,
        surfaceTintColor: theme.colorScheme.surfaceTint,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'الحجوزات',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on),
            label: 'الخريطة',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_bag_outlined),
            selectedIcon: Icon(Icons.shopping_bag),
            label: 'المتجر',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu),
            selectedIcon: Icon(Icons.menu),
            label: 'المزيد',
          ),
        ],
      ),
    );
  }
}
