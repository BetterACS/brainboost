import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Navbar extends StatelessWidget {
  const Navbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: SelectedIndex(context),
          onTap: (index) {
            String targetRoute = _getRouteFromIndex(index);
            if (ModalRoute.of(context)?.settings.name != targetRoute) {
              Navigator.pushReplacementNamed(context, targetRoute);
            }
          },
          items: [
            Itemnavbar(
              assetPath: 'assets/images/home.svg',
              label: '',
              isSelected: SelectedIndex(context) == 0,
            ),
            Itemnavbar(
              assetPath: 'assets/images/game.svg',
              label: '',
              isSelected: SelectedIndex(context) == 1,
            ),
            Itemnavbar(
              assetPath: 'assets/images/history.svg',
              label: '',
              isSelected: SelectedIndex(context) == 2,
            ),
            Itemnavbar(
              assetPath: 'assets/images/profile.svg',
              label: '',
              isSelected: SelectedIndex(context) == 3,
            ),
          ],
        ),
      ),
    );
  }

  int SelectedIndex(BuildContext context) {
    String? routeName = ModalRoute.of(context)?.settings.name ?? '/home';
    return Routetoindex(routeName);
  }

  int Routetoindex(String routeName) {
    switch (routeName) {
      case '/home':
        return 0;
      case '/game':
        return 1;
      case '/history':
        return 2;
      case '/profile':
        return 3;
      default:
        return 0;
    }
  }

  String _getRouteFromIndex(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/game';
      case 2:
        return '/history';
      case 3:
        return '/profile';
      default:
        return '/home';
    }
  }

  BottomNavigationBarItem Itemnavbar({
    required String assetPath,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Column(
        children: [
          SvgPicture.asset(
            assetPath,
            width: 34,
            height: 34,
            color: isSelected ? AppColors.activeColor : AppColors.inactiveColor,
          ),
          if (isSelected)
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
      label: label,
    );
  }
}
