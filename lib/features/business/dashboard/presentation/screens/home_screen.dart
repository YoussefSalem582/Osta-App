import 'package:flutter/material.dart';
import 'package:osta/core/theme/app_colors.dart';
import 'package:osta/features/business/dashboard/presentation/screens/board_screen.dart';
import 'package:osta/features/business/dashboard/presentation/screens/catalog_screen.dart';
import 'package:osta/features/business/dashboard/presentation/screens/more_screen.dart';
import 'package:osta/features/business/dashboard/presentation/screens/store_screen.dart';
import 'package:osta/shared/extensions/context_ext.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> screens = [
    const BoardScreen(),
    const CatalogScreen(),
    const StoreScreen(),
    const MoreScreen(),
  ];
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        shape: const ShapedInputBorder(
          shape: CircleBorder(side: BorderSide(width: 32)),
        ),
        backgroundColor: Colors.black,

        onPressed: () {},
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
      body: screens[index],
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.zero,
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        child: BottomNavigationBar(
          showUnselectedLabels: true,
          selectedItemColor: AppColors.brandGreen,
          unselectedItemColor: AppColors.greyLime,
          currentIndex: index,
          type: BottomNavigationBarType.shifting,
          onTap: (currIndex) {
            setState(() {
              index = currIndex;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.developer_board),
              label: context.l10n.board,
            ),

            BottomNavigationBarItem(
              icon: const Icon(Icons.category),
              label: context.l10n.catalog,
            ),

            BottomNavigationBarItem(
              icon: const Icon(Icons.store),
              label: context.l10n.store,
            ),

            BottomNavigationBarItem(
              icon: const Icon(Icons.more_horiz),
              label: context.l10n.more,
            ),
          ],
        ),
      ),
    );
  }
}
