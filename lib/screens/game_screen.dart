import 'package:flutter/material.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/screens/game_quiz.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/component/colors.dart';

const List<GameData> games = [
  GameData(
      gameType: GameType.quiz,
      content: GameQuizContent(
          correctAnswerIndex: 0,
          question: "ทำไมเราถึงต้องเรียน",
          options: [
            "เพราะเราต้องการเรียนรู้",
            "เพราะเราต้องการเล่นเกม",
            "เพราะเราต้องการเล่นเพลง",
            "เพราะเราต้องการเล่นกีฬา",
          ])),
  GameData(
      gameType: GameType.quiz,
      content: GameQuizContent(
          correctAnswerIndex: 0,
          question: "เราเรียนเพื่ออะไร",
          options: [
            "เพื่อเรียนรู้",
            "เพื่อเล่นเกม",
            "เพื่อเล่นเพลง",
            "เพื่อเล่นกีฬา",
          ])),
];

class GameWrapper extends StatefulWidget {
  const GameWrapper({
    super.key,
  });

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  // final GameData gameData;
  int gameIndex = 0;
  int score = 0;

  void onNext(int score) {
    if (gameIndex >= games.length - 1) {
      GoRouter.of(context).go(Routes.resultPage, extra: {
        'correct': score,
        'wrong': games.length - score,
        'time': '10:00',
      });
      return;
    }
    // print('Score: $score');
    setState(() {
      this.score += score;
      gameIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gameScreenBackground,
      appBar: AppBar(
        backgroundColor: AppColors.gameScreenBackground,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: gameIndex / games.length,
            backgroundColor: AppColors.progressBar,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 10,
          ),
        ),
      ),
      body: _buildGameScreen(),
    );
  }

  Widget _buildGameScreen() {
    switch (games[gameIndex].gameType) {
      case GameType.quiz:
        return QuizScreen(
        onNext: onNext,
        content: games[gameIndex].content as GameQuizContent,
      );

      // case Add other game types here
      
        
      default:
        return const Center(child: Text('Unknown game type'));
    }
  }
}
