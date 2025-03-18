import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/screens/game_quiz.dart';
import 'package:brainboost/screens/game_yesno.dart';
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

class _GameWrapperState extends State<GameWrapper> with SingleTickerProviderStateMixin {
  int gameIndex = 0;
  int score = 0;
  double prevGameIndex = 0;
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  bool isTransitioning = false;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pageAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _pageController,
      curve: Curves.easeInOut,
    ));
    _pageController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onNext(int score) async {
    print('onNext: ${this.score}');
    setState(() => isTransitioning = true);
    await _pageController.reverse();
    
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    setState(() {
      this.score += score;
    });

    print('gameIndex: $gameIndex, games.length: ${widget.games.length}, ${(widget.games[gameIndex].content as GameTinderContent).correct_ans} ${(widget.games[gameIndex].content as GameTinderContent).question}');

    if (gameIndex >= widget.games.length - 1) {
      await GameServices().addStoreToPlayedHistory(
          email: email, gamePath: widget.reference, score: this.score);
      GoRouter.of(context).go(Routes.resultPage, extra: {
        'correct': this.score,
        'wrong': widget.games.length - this.score,
        'time': '10:00',
      });
      return;
    }

    setState(() {
      prevGameIndex = gameIndex.toDouble();
      gameIndex++;
    });
    
    await _pageController.forward();
    setState(() => isTransitioning = false);
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
          child: SizedBox(
            width: 280, // Adjust width as needed
            height: 16,
            // Adjust height as needed

            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInSine,
              tween: Tween<double>(
                begin: (prevGameIndex + 1) / widget.games.length,
                end: min((gameIndex + 1) / widget.games.length, 0.92),
              ),
              builder: (context, value, _) => GameScreenProgressBar(
                progress: value,
                width: 290,
                height: 16,
              ),

              // LinearProgressIndicator(
              //   value: max(min(value, 1), 0),
              //   backgroundColor: AppColors.progressBar,
              //   valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              //   minHeight: 16, // Controls height directly
              // ),
            ),

            // child: ,
          ),
        ),
      ),
      body: _buildGameScreen(),
    );
  }

  Widget _buildGameScreen() {
    return FadeTransition(
      opacity: _pageAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.2, 0),
          end: Offset.zero,
        ).animate(_pageAnimation),
        child: switch (widget.games[gameIndex].gameType) {
          'quiz' => QuizScreen(
              key: ValueKey(gameIndex),
              onNext: onNext,
              content: widget.games[gameIndex].content as GameQuizContent,
              isTransitioning: isTransitioning,
            ),
          'yesno' => TinderGameScreen(
              key: ValueKey(gameIndex),
              onNext: onNext,
              content: widget.games[gameIndex].content as GameTinderContent,
              isTransitioning: isTransitioning,
            ),
          _ => const Center(child: Text('Unknown game type')),
        },
      ),
    );
  }
}

class GameScreenProgressBar extends StatelessWidget {
  final double progress;
  final double width;
  final double height;

  const GameScreenProgressBar({
    required this.progress,
    required this.width,
    required this.height,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Container(
            width: width * progress,
            height: height,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Align(
              alignment: Alignment.topCenter,
              child: Opacity(
                  opacity: 0.2,
                  child: Container(
                    width: width * progress / 1.2,
                    height: height / 3,
                    margin: const EdgeInsets.only(top: 3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}