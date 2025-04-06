import 'package:brainboost/component/cards/info_card.dart';
import 'package:brainboost/component/buttons/dropshadow_button.dart';
import 'package:brainboost/models/games.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:lottie/lottie.dart';
int _currentPage = 0;
  List<GamesType> games = [];
const correctAnswersColor = Color.fromRGBO(32, 94, 216, 1);
const wrongAnswersColor = Color.fromRGBO(223, 69, 69, 1);
const timeColor = Color.fromRGBO(255, 193, 7, 1);

class ShadowEllipse extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;

  const ShadowEllipse({
    super.key,
    this.width = 300.0,
    this.height = 150.0,
    this.backgroundColor = const Color(0xFFE1E3E9),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(
          Radius.elliptical(width / 2, height / 2),
        ),
      ),
    );
  }
}

class ResultsPage extends StatelessWidget {
  const ResultsPage({
    super.key,
    required this.correct,
    required this.wrong,
    required this.time,
    this.gameReference,
    this.gameData,
  });

  final int correct;
  final int wrong;
  final String time;
  final String? gameReference;
  final List<dynamic>? gameData;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Padding from TOP
              const SizedBox(height: 80),
              _buildTrophy(isDarkMode),

              // Padding from Trophy
              const SizedBox(height: 20),
              _buildCongratulationsText(isDarkMode),

              // Padding from Congratulations Text
              const SizedBox(height: 30),
              _buildScoreRow(correct, wrong, time, isDarkMode),

              // Padding from Score Row
              const SizedBox(height: 20),
              _buildImprovementText(isDarkMode),

              // Padding from Improvement Text
              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropShadowButton(
                    width: 64,
                    height: 64,
                    backgroundColor: isDarkMode
                        ? Colors.grey[800]!
                        : const Color(0xFFCCDBFA),
                    shadowColor: isDarkMode
                        ? Colors.grey[700]!
                        : const Color(0xFF95A5C6),
                    onPressed: () => context.go(Routes.homePage),
                    child: Icon(
                      Icons.home,
                      color: isDarkMode ? Colors.white : const Color(0xFF7184AC),
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropShadowButton(
                    width: 275,
                    height: 64,
                    backgroundColor: isDarkMode
                        ? Colors.blueGrey[900]!
                        : const Color(0xFF205ED8),
                    shadowColor: isDarkMode
                        ? Colors.blueGrey[700]!
                        : const Color(0xFF1746A2),
                    onPressed: () {
                      context.go(Routes.playGamePage, extra: {
                        'games': gameData ?? [],
                        'reference': gameReference
                      });
                    },
                    child: Text(
                      "Play Again",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy(bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 110),
          child: ShadowEllipse(
            width: 280,
            height: 160,
            backgroundColor: isDarkMode ? Colors.grey[800]! : const Color(0xFFE1E3E9),
          ),
        ),
        const Center(
          child: Image(
            image: AssetImage('assets/icons/trophy.png'),
            width: 238,
            height: 262,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildCongratulationsText(bool isDarkMode) {
    return Column(
      children: [
        Text(
          'Congrats!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.yellow[700] : Colors.black,
          ),
        ),
        Text(
          'You are the best!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.yellow[700] : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreRow(int correct, int wrong, String time, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InfoCard(
          title: 'Correct',
          value: correct.toString(),
          icon: Icons.check_circle,
          cardColor: correctAnswersColor,
        ),
        InfoCard(
          title: 'Wrong',
          value: wrong.toString(),
          icon: Icons.cancel,
          cardColor: isDarkMode ? Colors.red[700]! : wrongAnswersColor,
        ),
        InfoCard(
          title: 'Time',
          value: time,
          icon: Icons.watch_later,
          cardColor: isDarkMode ? Colors.amber[700]! : timeColor,
        )
      ],
    );
  }

  Widget _buildImprovementText(bool isDarkMode) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Text(
        'You scored 20% more than the previous time.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.white70 : Colors.black,
        ),
      ),
    );
  }
}
