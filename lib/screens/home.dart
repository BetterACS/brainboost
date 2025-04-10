import 'dart:math';
import 'dart:ui';
import 'package:brainboost/main.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/screens/history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/services/games.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/component/cards/profile_header.dart';
// import 'package:brainboost/screens/creategame.dart';
import 'package:brainboost/services/user.dart';
import 'package:brainboost/component/history_item.dart';
import 'package:brainboost/component/circular_page_chart.dart';
import 'package:brainboost/screens/game_bingo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';


class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // วงกลมก้อนเมฆ
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 1.2), 114, paint);
    canvas.drawCircle(Offset(size.width * 0.38, size.height * 0.95), 45, paint);
    canvas.drawCircle(Offset(size.width * 0.57, size.height * 1.15), 77, paint);
    canvas.drawCircle(Offset(size.width * 0.79, size.height * 1.5), 83, paint);
    canvas.drawCircle(Offset(size.width * 1, size.height * 0.98), 95, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class _MouseScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool isProfileLoaded = false;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier, 
      builder: (context, currentTheme, child) {
        return Scaffold(
          backgroundColor: currentTheme == ThemeMode.dark
              ? AppColors.backgroundDarkmode 
              : AppColors.mainColor,
          body: ScrollConfiguration(
            behavior: _MouseScrollBehavior(),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  const ProfileContainer(),
                  const SizedBox(height: 20),
                  _buildPageView(),
                  const SizedBox(height: 10),
                  _buildPageIndicator(),
                  const SizedBox(height: 20),
                  _buildCreateSection(),
                  _buildCreateButtons(context),
                  _buildHistorySection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<DocumentSnapshot> fetchUsername() async {
    final String? email = UserServices().getCurrentUserEmail();
    final DocumentSnapshot userDoc =
        await UserServices().users.doc(email).get();

    setState(() {
      isProfileLoaded = true;
    });
    return userDoc;
  }

  Widget _buildPageView() {
    return FutureBuilder<void>(
      future: fetchGamePerformance(),
      builder: (context, snapshot) {
        return SizedBox(
          height: 330,
          width: 300,
          child: _buildCircularChartPage(),
        );
      },
    );
  }

  bool isLoadCircle = false;
  int numberGames = 0;
  int correctQuestion = 0;

  Future<void> fetchGamePerformance() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null || isLoadCircle == true) return;

    List<String> gamesPath =
        await UserServices().getGames(email: email as String);
    int _games = 0;
    int _score = 0;
    for (String gamePath in gamesPath) {
      Map<String, dynamic> game =
          await GameServices().getGame(path: gamePath) as Map<String, dynamic>;

      if (game['played_history'] == null) continue;

      int currentScore = 0;
      for (Map<String, dynamic> playedHistory in game['played_history']) {
        DocumentReference userPath = playedHistory['player'];
        String player = userPath.path.split("/")[1];

        if (player == email) {
          if (playedHistory['score'] > currentScore) {
            currentScore = playedHistory['score'];
          }
        }
      }

      _games += game['game_list'].length as int;
      _score += currentScore;
    }

    print(_score);
    setState(() {
      isLoadCircle = true;
      numberGames = _games;
      correctQuestion = _score;
    });
  }

  Widget _buildCircularChartPage() {
    return FutureBuilder<void>(
      future: fetchGamePerformance(),
      builder: (context, snapshot) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        if (!isLoadCircle) {
          return Center(
            child: SizedBox(
              height: 300,
              width: 300,
            ),
          );
        }

        if (numberGames == 0) {
          return Center(
            child: SizedBox(
              height: 300,
              width: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(285, 285),
                    painter: CircularChartPainter(0, isDarkMode),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.completeGame,
                        style: TextStyle(
                          color: isDarkMode
                              ? AppColors.textPrimary
                              : AppColors.buttonText,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        AppLocalizations.of(context)!.seeProgress,
                        style: TextStyle(
                          color: isDarkMode
                              ? AppColors.textPrimary
                              : AppColors.buttonText,
                          fontSize: 17.59,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return Center(
          child: SizedBox(
            height: 300,
            width: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(285, 285),
                  painter: CircularChartPainter(
                    (correctQuestion / numberGames) * 100,
                    isDarkMode,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.successRate,
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.textPrimary
                            : AppColors.buttonText,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${((correctQuestion / numberGames) * 100).toStringAsFixed(2)}%",
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.textPrimary
                            : AppColors.buttonText,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppLocalizations.of(context)!.outOfQuestions(numberGames),
                      style: TextStyle(
                        color: isDarkMode
                            ? AppColors.textPrimary
                            : AppColors.buttonText,
                        fontSize: 17.59,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageIndicator() {
    return const SizedBox.shrink(); // Remove page indicator completely
  }

  Widget _buildCreateSection() {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context)!.start,
          style: TextStyle(
            color:  isDarkMode
                            ? AppColors.textPrimary 
                            : AppColors.gradient1,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
Widget _buildCreateButtons(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    child: Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: AppColors.buttonGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
              child: SizedBox(
                child: CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: CloudPainter(),
                ),
              ), 
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.expianedmaincreategame,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // SizedBox(height: 10),
                        ],
                      ),
                      const Spacer(),
                      // SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the games page and show the "Add Game" card
                          GoRouter.of(context).go(Routes.gamePage, extra: {'showAddGame': true});
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow[700],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.createGame,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF002654),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Image.asset(
                      'assets/images/rockety.png',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildHistorySection() {
    final String? email = FirebaseAuth.instance.currentUser?.email;
      final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.history,
                style: TextStyle(
                  color: isDarkMode
                            ? AppColors.textPrimary 
                            : AppColors.buttonText, 
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLoadCircle && numberGames > 0)
                GestureDetector(
                  onTap: () {
                    context.push(Routes.historyPage, extra: email);
                  },
                  child: Row(
                    children: [
                      Text(
                        AppLocalizations.of(context)!.viewAll,
                        style: TextStyle(
                          color: AppColors.gray2,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.gray2,
                        size: 14,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          FutureBuilder<void>(
            future: fetchGamePerformance(),
            builder: (context, snapshot) {
              if (!isLoadCircle) {
                return const Center(
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                  ),
                );
              }

              if (numberGames == 0) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? AppColors.backgroundDarkmode : AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Text(
                        AppLocalizations.of(context)!.historyWillAppearHere,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : AppColors.buttonText,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context)!.completeGameToSeeHistory,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : AppColors.buttonText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('history')
                      .doc(email)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(child: Text(AppLocalizations.of(context)!.noHistoryFound));
                    }

                    var docData =
                        snapshot.data!.data() as Map<String, dynamic>? ?? {};
                    List<Map<String, dynamic>> allGames =
                        (docData['data'] as List<dynamic>?)
                                ?.whereType<Map<String, dynamic>>()
                                .toList() ??
                            [];

                    if (allGames.isEmpty) {
                      return Center(child: Text(AppLocalizations.of(context)!.noHistoryFound));
                    }

                    final gamesToShow = allGames.take(2).toList();

                    return Column(
                      children: gamesToShow
                          .map((game) => HistoryItem(
                                title: game['game_name'] ?? 'Unknown',
                                date: DateFormat('dd MMM yyyy').format((game['played_at'] as Timestamp).toDate()),
                                imagePath: "assets/${game['icon']}", 
                                bestScore: game['best_score'] ?? 0,
                                // gameId: game['game_id'],
                                documentReference: game['game_id'],
                              ))
                          .toList(),
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(48),
        topLeft: Radius.circular(12),
        bottomLeft: Radius.circular(12),
        bottomRight: Radius.circular(12),
      ),
      child: Container(
        height: 70,
        width: 200,
        decoration: const BoxDecoration(
          gradient: AppColors.buttonGradient,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(48),
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -10,
              left: -12,
              child: Transform.rotate(
                angle: 25 * pi / 180,
                child: Icon(
                  icon,
                  color: AppColors.accentBackground,
                  size: 54,
                ),
              ),
            ),
            Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
