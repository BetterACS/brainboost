import 'package:brainboost/models/games.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/layout/layout_scaffold.dart';

import 'package:brainboost/screens/all.dart';

import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',

  /// Define routes here.
  routes: [
    /// Example of a simple route.
    /// GoRoute(
    ///   path: '/simple', You should add the routes to the routes.dart file
    ///   builder: (context, state) => const SimplePage(),
    /// ),
    ///
    GoRoute(
        path: '/home-wrapper',
        builder: (context, state) => const LoadingHomeWrapper()),
    GoRoute(path: '/login', builder: (context, state) => Login()),
    GoRoute(path: '/signup', builder: (context, state) => Signup()),

    GoRoute(
        path: Routes.settingsPage,
        builder: (context, state) => const SettingsPage()),

    GoRoute(
        path: Routes.playGamePage,
        builder: (context, state) {
          print("Play Game Page");
          final extra = state.extra as dynamic;
          print(extra);
          final List<GameData> games = [];

          for (var item in extra['games']) {
            print(item['content']['choices']);
            // print()
            games.add(GameData(
                gameType: item['game_type'],
                // item['content'] as GameContent
                content: (item['game_type'] == 'quiz')
                    ? GameQuizContent(
                        correctAnswerIndex:
                            item['content']['correct_idx'] as int,
                        question: item['content']['question'] as String,
                        options: (item['content']['choices'] as List<dynamic>)
                            .map((e) => e as String)
                            .toList(),
                      )
                    : GameContent()));
          }
          // final extra = state.extra as List<Map<String, dynamic>>;
          // final List<GameData> games = [];
          // print(extra);

          // for (var item in extra) {
          //   print("Item: $item");
          // games.add(GameData(
          //   gameType: item['gameType'] as GameType,
          //   content: item['content'] as GameContent,
          // ));
          // }
          // print("Games: $games");

          // return ResultsPage(
          //   correct: extra?['correct'] as int? ?? 0,
          //   wrong: extra?['wrong'] as int? ?? 0,
          //   time: extra?['time'] as String? ?? '',
          // );
          return GameWrapper(games: games, reference: extra['reference'] as String);
          // return Text("Play Game Page");
        }),

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
