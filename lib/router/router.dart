import 'dart:math';

import 'package:brainboost/models/games.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/layout/layout_scaffold.dart';
import 'package:brainboost/screens/all.dart';
import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brainboost/presentation/pages/auth/auth.dart';
import 'package:brainboost/presentation/pages/profile/profile.dart';
import 'package:brainboost/presentation/pages/home/home.dart';
import 'package:brainboost/presentation/pages/games/games.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',

  /// Define routes here.
  routes: [
    /// Auth routes using clean architecture
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomePage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupPage(),
    ),
    
    // Profile routes using clean architecture
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfilePage(),
    ),

    GoRoute(
        path: '/home-wrapper',
        builder: (context, state) => const LoadingHomeWrapper()),

    GoRoute(
        path: Routes.settingsPage,
        builder: (context, state) => const SettingsPage()),

    GoRoute(
        path: Routes.playGamePage,
        builder: (context, state) {
          final extra = state.extra as dynamic;
          // print(extra['games'][0]['content']);
          final List<GameData> games = [];

          for (var item in extra['games']) {
            games.add(GameData(
              gameType: item['game_type'],
              content: GameData.createContent(
                item['game_type'],
                item['content'],
              ),
            ));
          }

          // Shuffle and select 12 random games
          if (games.length > 12) {
            final random = Random();
            if (games.length > 12) {
              games.shuffle(random);
              games.length = 12;
            } else {
              games.shuffle(random);
            }
          }

          return GameWrapper(
              games: games, reference: extra['reference'] as String);
        }),

    GoRoute(
        path: Routes.resultPage,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ResultsPage(
            correct: extra?['correct'] as int? ?? 0,
            wrong: extra?['wrong'] as int? ?? 0,
            time: extra?['time'] as String? ?? '',
            gameReference: extra?['reference'] as String?,
            gameData: extra?['games'] as List<dynamic>?,
          );
        }),

    /// Navigation Shell
    /// This is a special route that allows you to define a layout for your app.
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          LayoutScaffold(navigationShell: navigationShell),
      branches: [
        // Home
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homePage,
              builder: (context, state) => const HomePage(), // Using clean architecture HomePage
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.gamePage,
              builder: (context, state) => const MyGamesPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.historyPage,
              builder: (context, state) => History(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profilePage,
              builder: (context, state) => const ProfilePage(), // Using clean architecture ProfilePage
            ),
          ],
        ),
        
      ],
    ),
  ],
);