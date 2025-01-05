import 'package:brainboost/component/cards/info_card.dart';
import 'package:brainboost/component/buttons/dropshadow_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';

const correctAnswersColor = Color.fromRGBO(32, 94, 216, 1);
const wrongAnswersColor = Color.fromRGBO(223, 69, 69, 1);
const timeColor = Color.fromRGBO(255, 193, 7, 1);

class ShadowEllipse extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor = const Color(0xFFE1E3E9);

  const ShadowEllipse({
    super.key,
    this.width = 300.0,
    this.height = 150.0,
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
  });

  final int correct;
  final int wrong;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Padding from TOP
              const SizedBox(height: 80),
              _buildTrophy(),

              // Padding from Trophy
              const SizedBox(height: 20),
              _buildCongratulationsText(),

              // Padding from Congratulations Text
              const SizedBox(height: 30),
              _buildScoreRow(correct, wrong, time),

              // Padding from Score Row
              const SizedBox(height: 20),
              _buildImprovementText(),

              // Padding from Improvement Text
              const Spacer(),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropShadowButton(
                    width: 64,
                    height: 64,
                    backgroundColor: const Color(0xFFCCDBFA),
                    shadowColor: const Color(0xFF95A5C6),
                    onPressed: () => context.go(Routes.homePage),
                    child: const Icon(
                      Icons.home,
                      color: Color(0xFF7184AC),
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 10), // give it width
                  DropShadowButton(
                    width: 275,
                    height: 64,
                    backgroundColor: const Color(0xFF205ED8),
                    shadowColor: const Color(0xFF1746A2),
                    onPressed: () => context.go(Routes.playGamePage),
                    child: const Text(
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

              // Padding from BOTTOM
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrophy() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 110),
          child: const ShadowEllipse(
            width: 280,
            height: 160,
          ),
        ),
        const Center(
          child: Image(
            image: AssetImage('assets/icons/trophy.png'),
            width: 238,
            height: 262,
            fit: BoxFit.contain,
          ),
        )
      ],
    );
  }

  Widget _buildCongratulationsText() {
    return const Column(
      children: [
        Text(
          'Congrats!',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        Text(
          'You are the best!',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildScoreRow(int correct, int wrong, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InfoCard(
          title: 'Correct',
          value: correct.toString(),
          icon: Icons.check,
          cardColor: correctAnswersColor,
        ),
        InfoCard(
          title: 'Wrong',
          value: wrong.toString(),
          icon: Icons.curtains_closed_rounded,
          cardColor: wrongAnswersColor,
        ),
        InfoCard(
          title: 'Time',
          value: time,
          icon: Icons.access_time,
          cardColor: timeColor,
        )
      ],
    );
  }

  Widget _buildImprovementText() {
    return ConstrainedBox(
      constraints:
          const BoxConstraints(maxWidth: 250),
      child: const Text(
        'You scored 20% more than the previous time.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
