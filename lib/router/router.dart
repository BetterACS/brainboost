import 'package:brainboost/models/games.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/layout/layout_scaffold.dart';
import 'package:brainboost/screens/all.dart';
import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
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
            games.add(GameData(
                gameType: item['game_type'],
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
          return GameWrapper(games: games);
        }),
    GoRoute(
        path: Routes.resultPage,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ResultsPage(
            correct: extra?['correct'] as int? ?? 0,
            wrong: extra?['wrong'] as int? ?? 0,
            time: extra?['time'] as String? ?? '',
          );
        }),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          LayoutScaffold(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homePage,
              builder: (context, state) => const Home(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.gamePage,
              builder: (context, state) => const MyGames(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.historyPage,
              builder: (context, state) {
                final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
                return History(email: userEmail);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profilePage,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
