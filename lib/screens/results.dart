import 'package:brainboost/component/cards/info_card.dart';
import 'package:brainboost/component/buttons/dropshadow_button.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/models/games.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:lottie/lottie.dart';

int _currentPage = 0;
List<GamesType> games = [];
const correctAnswersColor = AppColors.progressBlue; // Updated to use AppColors
const wrongAnswersColor = AppColors.errorColor; // Updated to use AppColors
const timeColor = AppColors.yellowButton; // Updated to use AppColors

class ShadowEllipse extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor = AppColors.gray4; // Updated to use AppColors

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
    return Scaffold(
      backgroundColor: AppColors.gameScreenBackground, // Updated to use AppColors
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
                    backgroundColor: AppColors.gray4, // Updated to use AppColors
                    shadowColor: AppColors.gray5, // Updated to use AppColors
                    onPressed: () => context.go(Routes.homePage),
                    child: Icon(
                      Icons.home,
                      color: AppColors.unselectedTab, // Updated to use AppColors
                      size: 42,
                    ),
                  ),
                  const SizedBox(width: 10),
                  DropShadowButton(
                    width: 275,
                    height: 64,
                    backgroundColor: AppColors.progressBlue, // Updated to use AppColors
                    shadowColor: AppColors.primaryBackground, // Updated to use AppColors
                    onPressed: () {
                      // ยังคงใช้ context.go เพื่อล้างประวัติการนำทาง
                      // ทำให้เมื่อกดปุ่มย้อนกลับจะไม่กลับมาที่หน้า Results
                      context.go(Routes.playGamePage, extra: {
                        'games': gameData ?? [],
                        'reference': gameReference
                      });
                    },
                    child: Text(
                      "Play Again",
                      style: TextStyle(
                        color: AppColors.white, // Updated to use AppColors
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
        ),
      ],
    );
  }

  Widget _buildCongratulationsText() {
    return Column(
      children: [
        Text(
          'Congrats!',
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary.withOpacity(0.8), // Added color with AppColors
          ),
        ),
        Text(
          'You are the best!',
          style: TextStyle(
            fontSize: 32, 
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary.withOpacity(0.8), // Added color with AppColors
          ),
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
          icon: Icons.check_circle, 
          cardColor: correctAnswersColor,
        ),
        InfoCard(
          title: 'Wrong',
          value: wrong.toString(),
          icon: Icons.cancel, 
          cardColor: wrongAnswersColor,
        ),
        InfoCard(
          title: 'Time',
          value: time,
          icon: Icons.watch_later,
          cardColor: timeColor,
        )
      ],
    );
  }

  Widget _buildImprovementText() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 250),
      child: Text(
        'You scored 20% more than the previous time.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary.withOpacity(0.7), // Added color with AppColors
        ),
      ),
    );
  }
}