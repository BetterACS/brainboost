import 'package:brainboost/component/colors.dart';
import 'package:brainboost/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../provider/theme_provider.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('Navbar'));

  final StatefulNavigationShell navigationShell;

  VoidCallback _handleTap(int index) {
    if (navigationShell.goBranch != null) {
      navigationShell.goBranch!(index);
    }
    return () {};
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = context.watch<ThemeProvider>().isDarkMode;

    // return ValueListenableBuilder<ThemeMode>(
    //   valueListenable: themeNotifier,
    //   builder: (context, currentTheme, child) {
    // final isDarkMode = currentTheme == ThemeMode.dark;

    final activeColor =
        isDarkMode ? AppColors.accentDarkmode : AppColors.activeColor;
    final inactiveColor =
        isDarkMode ? AppColors.accentDarkmode : AppColors.inactiveColor;
    final backgroundColor = isDarkMode ? AppColors.white : AppColors.white;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          onTap: _handleTap,
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: navigationShell.currentIndex,
          backgroundColor: backgroundColor,
          items: <BottomNavigationBarItem>[
            for (int i = 0; i < destinations.length; i++)
              BottomNavigationBarItem(
                activeIcon: Column(
                  children: [
                    SvgPicture.asset(
                      destinations[i].assetPath,
                      width: 34,
                      height: 34,
                      color: activeColor, // ใช้ activeColor
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 3,
                      width: 30,
                      decoration: BoxDecoration(
                        color: activeColor, // ใช้ activeColor
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                icon: SvgPicture.asset(
                  destinations[i].assetPath,
                  width: 34,
                  height: 34,
                  color: inactiveColor, // ใช้ inactiveColor
                ),
                label: destinations[i].label,
              ),
          ],
        ),
      ),
    );
    //   },
    // );
  }
}

class ItemNAVBar extends NavigationDestination {
  ItemNAVBar({
    super.key,
    required this.assetPath,
    required this.label,
    required this.isSelected,
  }) : super(
          icon: SvgPicture.asset(
            assetPath,
            width: 34,
            height: 34,
            color: isSelected ? AppColors.activeColor : AppColors.inactiveColor,
          ),
          // label: label,
          label: label,
          selectedIcon: SvgPicture.asset(
            assetPath,
            width: 34,
            height: 34,
            color: AppColors.activeColor,
          ),
        );

  final String assetPath;
  final bool isSelected;
  final String label;
}

class Destination {
  const Destination({
    required this.assetPath,
    required this.label,
  });

  final String assetPath;
  final String label;
}

final destinations = [
  const Destination(assetPath: 'assets/images/home.svg', label: 'home'),
  const Destination(assetPath: 'assets/images/game.svg', label: 'games'),
  const Destination(assetPath: 'assets/images/history.svg', label: 'history'),
  const Destination(assetPath: 'assets/images/profile.svg', label: 'profile'),
];
