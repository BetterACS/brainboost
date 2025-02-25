import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/screens/game_quiz.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/component/colors.dart';
import 'package:brainboost/services/games.dart';

class GameWrapper extends StatefulWidget {
  final List<GameData> games;
  final String reference;

  const GameWrapper({
    required this.games,
    required this.reference,
    super.key,
  });

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {

  int gameIndex = 0;
  int score = 0;

  void onNext(int score) async {
    String? email = FirebaseAuth.instance.currentUser?.email;

    if (email == null) return;
    if (gameIndex >= widget.games.length - 1) {
      
      await GameServices().addStoreToPlayedHistory(email: email, gamePath: widget.reference, score: score);
      GoRouter.of(context).go(Routes.resultPage, extra: {
        'correct': score,
        'wrong': widget.games.length - score,
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
            value: gameIndex / widget.games.length,
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
    switch (widget.games[gameIndex].gameType) {
      case 'quiz':
        return QuizScreen(
          onNext: onNext,
          content: widget.games[gameIndex].content as GameQuizContent,
        );

      // case Add other game types here


      default:
        return const Center(child: Text('Unknown game type'));
    }
  }
}
