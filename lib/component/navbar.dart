import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class Navbar extends StatelessWidget {
  const Navbar({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('Navbar'));

  /// The [StatefulNavigationShell] widget is used to define the app's main content. (e.g. [HomePage], [ProfilePage], [SettingsPage])
  final StatefulNavigationShell navigationShell;

  /// The [_handleTap] function is used to handle the tap event on the bottom navigation bar.
  VoidCallback _handleTap(int index) {
    // Original code from the tutorial.
    // navigationShell.goBranch!(index);z
    // return navigationShell.goBranch != null
    //     ? () => navigationShell.goBranch!(index)
    //     : () {};

    if (navigationShell.goBranch != null) 
      navigationShell.goBranch!(index);
    
    return () {};
  }

  @override
  Widget build(BuildContext context) {
    /// The [Container] widget is used to contain the [BottomNavigationBar] widget. (Design purpose)
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),

        /// The [BottomNavigationBar] widget is used to define the bottom navigation bar.
        child: BottomNavigationBar(
          onTap: _handleTap, // Handle the tap event on the bottom navigation bar.
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          currentIndex: navigationShell.currentIndex,

          /// Generate the bottom navigation bar items based on the [destinations] list.
          items: <BottomNavigationBarItem>[
            for (int i = 0; i < destinations.length; i++)
              BottomNavigationBarItem(

                /// Active icon.
                activeIcon: Column(
                  children: [
                    SvgPicture.asset(
                      destinations[i].assetPath,
                      width: 34,
                      height: 34,
                      color: AppColors.activeColor,
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      height: 3,
                      width: 30,
                      decoration: BoxDecoration(
                        color: AppColors.activeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),

                /// Inactive icon. (Default)
                icon: SvgPicture.asset(
                  destinations[i].assetPath,
                  width: 34,
                  height: 34,
                  color: AppColors.inactiveColor,
                ),
                label: destinations[i].label,
              )
          ],
        ),
      ),
    );
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
