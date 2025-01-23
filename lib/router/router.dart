import 'package:flutter/material.dart';
import 'package:brainboost/layout/layout_scaffold.dart';

import 'package:brainboost/screens/all.dart';

import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.homePage,
  
  /// Define routes here.
  routes: [

    /// Example of a simple route.
    /// GoRoute(
    ///   path: '/simple', You should add the routes to the routes.dart file
    ///   builder: (context, state) => const SimplePage(),
    /// ),
    /// 
    GoRoute(
      path: Routes.settingsPage,
      builder: (context, state) => const SettingsPage()
    ),

    GoRoute(
      path: Routes.playGamePage,
      builder: (context, state) => const GameWrapper()
    ),


    // GoRoute(
    //   path: Routes.resultPage,
    //   builder: (context, state) => ResultScreen(score: state.pathParameters['score'] as int)
    // ),

    GoRoute(
      path: Routes.resultPage,
      builder: (context, state) {
        // correct, wrong, time
        // Map<String, int> args = state.extra as Map<String, int>;
        final extra = state.extra as Map<String, dynamic>?;
        return ResultsPage(
          correct: extra?['correct'] as int? ?? 0,
          wrong: extra?['wrong'] as int? ?? 0,
          time: extra?['time'] as String? ?? '',
        );
      }
    ),


    /// Navigation Shell
    /// This is a special route that allows you to define a layout for your app.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) => LayoutScaffold(navigationShell: navigationShell),

      branches: [

        // Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homePage,
              builder: (context, state) => const Home(), 
            ),
          ],
        ),

        // My Games
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.gamePage,
              builder: (context, state) => const MyGames(), 
            ),
          ],
        ),

        // History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.historyPage,
              builder: (context, state) => const History(), 
            ),
          ],
        ),

        // Profile
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profilePage,
              builder: (context, state) => const ProfilePage(),
              
              // Example of nested routes on navigation shell.
              // Don't remove this comment (kept for future reference)
              // routes: [
              //   GoRoute(
              //     path: Routes.settingsPage,
              //     builder: (context, state) => const SettingsPage()
              //   ),
              // ], 
            ),
          ],
        ),
      ],
    ),
  ],
);
