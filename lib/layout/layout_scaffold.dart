import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/component/navbar.dart';

class LayoutScaffold extends StatelessWidget {
  const LayoutScaffold({
    required this.navigationShell,
    Key? key,
  }) : super(key: key ?? const ValueKey<String>('LayoutScaffold'));

  final StatefulNavigationShell navigationShell;
  
  /// The [Scaffold] widget is used to define the app's layout.
  /// The [Stack] widget is used to stack the [navigationShell] and [Navbar] widgets.
  /// [navigationShell] is the main content of the app. (e.g. [HomePage], [ProfilePage], [SettingsPage])
  /// [Navbar] is the bottom navigation bar.
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(

      /// The [Stack] widget is used to stack the [navigationShell] and [Navbar] widgets.
      children: [
        navigationShell,

        /// [Navbar] is the bottom navigation bar.
        Align(
          alignment: Alignment.bottomCenter,
          child: Navbar(navigationShell: navigationShell),
        ),
      ],
    )
  );
}
