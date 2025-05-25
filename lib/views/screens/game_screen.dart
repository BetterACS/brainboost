import 'dart:math';
import 'dart:async';

import 'package:brainboost/main.dart';
import 'package:brainboost/views/screens/game_bingo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/views/screens/game_quiz.dart';
import 'package:brainboost/views/screens/game_yesno.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/views/widgets/colors.dart';
import 'package:brainboost/services/games.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:brainboost/views/screens/game_bingo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


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

class _GameWrapperState extends State<GameWrapper>
    with SingleTickerProviderStateMixin {
  // final player = AudioPlayer();
  int gameIndex = 0;
  int score = 0;
  double prevGameIndex = 0;
  late AnimationController _pageController;
  late Animation<double> _pageAnimation;
  bool isTransitioning = false;

  // Timer variables - not displayed but tracked
  Timer? _timer;
  int _seconds = 0;

  // Format seconds into MM:SS format
  String get formattedTime {
    int minutes = _seconds ~/ 60;
    int remainingSeconds = _seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

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

    // Start the timer when the game begins but don't display it
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void onNext(int score) async {
    print('onNext: ${this.score}');
    setState(() => isTransitioning = true);
    await _pageController.reverse();

    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    setState(() {
      this.score += score; // Update score for every correct answer
    });

    // print(
    //     'gameIndex: $gameIndex, games.length: ${widget.games.length}, ${(widget.games[gameIndex].content as GameYesNoContent).correct_ans} ${(widget.games[gameIndex].content as GameYesNoContent).question}');

    if (gameIndex >= widget.games.length - 1) {
      // await player.play(
      //     AssetSource('sounds/game-level-complete-universfield-pixabay.mp3'));

      // Stop the timer when all games are completed
      _timer?.cancel();

      await GameServices().addStoreToPlayedHistory(
          email: email, gamePath: widget.reference, score: this.score);

      GoRouter.of(context).go(Routes.resultPage, extra: {
        'correct': this.score,
        'wrong': widget.games.length - this.score,
        'time': formattedTime,
        'reference': widget.reference,
        'games': widget.games
            .map((game) => {
                  // Switch case for different game types
                  'game_type': game.gameType,
                  'content': game.content is GameQuizContent
                      ? (game.content as GameQuizContent).toMap()
                      : game.content is GameYesNoContent
                          ? (game.content as GameYesNoContent).toMap()
                          : game.content is BingoContent
                              ? (game.content as BingoContent).toMap()
                              : {}
                })
            .toList(),
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

  void showExitGameConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.white,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/images/alert.png', 
                  height: 100,
                  width: 100,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.exitmodalmain,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.containerBackground, // Dark blue color
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                   AppLocalizations.of(context)!.exitmodal1,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.containerBackground, // Dark blue color
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                 AppLocalizations.of(context)!.exitmodal2,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.containerBackground, // Dark blue color
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: AppColors.containerBackground), // Dark blue color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: TextStyle(
                            color: AppColors.containerBackground, // Dark blue color
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); 
                          context.go(Routes.gamePage); 
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorIcon, // Red color
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.exit,
                          style: TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
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

  @override
  Widget build(BuildContext context) {
        final currentTheme = Theme.of(context).brightness;
    final bool isDarkMode = currentTheme == Brightness.dark;
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Show confirmation dialog instead of direct navigation
        showExitGameConfirmation(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.gameScreenBackground,
        appBar: AppBar(
          backgroundColor: isDarkMode
                    ? AppColors.backgroundDarkmode
                    : AppColors.gameScreenBackground,
          elevation: 0,
          leading: BackButton(
            color:  isDarkMode
                    ? AppColors.white
                    : Colors.black, // Using AppColors.textQuizOption instead of Colors.black
            onPressed: () => showExitGameConfirmation(context), // Updated to show dialog
          ),
          title: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 280, // Original width
              height: 16,
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
              ),
            ),
          ),
        ),
        body: _buildGameScreen(),
      ),
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
          'bingo' => BingoScreen(
              content: widget.games[gameIndex].content as BingoContent,
              onNext: onNext,
              isTransitioning: isTransitioning),
          'yesno' => YesNoGameScreen(
              key: ValueKey(gameIndex),
              onNext: onNext,
              content: [widget.games[gameIndex].content as GameYesNoContent],
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
  return ValueListenableBuilder<ThemeMode>(
    valueListenable: themeNotifier,
    builder: (context, currentTheme, child) {
      bool isDarkMode = currentTheme == ThemeMode.dark;

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
                color: isDarkMode
                    ? AppColors.textQuizNonSelectedOption
                    : Colors.blue,
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
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}
