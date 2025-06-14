import 'package:brainboost/component/cards/info_card.dart';
import 'package:brainboost/component/buttons/dropshadow_button.dart';
import 'package:brainboost/models/games.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:brainboost/services/history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:brainboost/provider/theme_provider.dart';
import 'package:brainboost/component/colors.dart';

int _currentPage = 0;
List<GamesType> games = [];
const correctAnswersColor = Color.fromRGBO(32, 94, 216, 1);
const wrongAnswersColor = Color.fromRGBO(223, 69, 69, 1);
const timeColor = Color.fromRGBO(255, 193, 7, 1);
const bestScoreColor = Color.fromRGBO(75, 181, 67, 1);

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

class ResultsPage extends StatefulWidget {
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
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final GameHistoryService _historyService = GameHistoryService();
  int bestScore = 0;
  bool isNewBestScore = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _updateBestScore();
  }

  Future<void> _updateBestScore() async {
    if (widget.gameReference != null) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final currentScore = widget.correct;
        DocumentReference gameDocRef =
            FirebaseFirestore.instance.doc(widget.gameReference!);

        final updatedBestScore = await _historyService.updateGameScore(
          email: currentUser.email!,
          gameId: gameDocRef,
          newScore: currentScore,
        );

        setState(() {
          bestScore = updatedBestScore;
          isNewBestScore = currentScore >= bestScore;
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : const Color(0xFFF0F7FF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // const SizedBox(height: 80),
              _buildTrophy(isDarkMode),
              const SizedBox(height: 10),
              _buildCongratulationsText(context, isDarkMode),
              const SizedBox(height: 20),
              _buildScoreRow(context, widget.correct, widget.wrong, widget.time,
                  isDarkMode),
              const SizedBox(height: 20),
              if (isLoading)
                const CircularProgressIndicator()
              else if (bestScore > 0)
                _buildBestScore(context, isDarkMode),
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
                  const SizedBox(width: 10),
                  DropShadowButton(
                    width: 275,
                    height: 64,
                    backgroundColor: const Color(0xFF205ED8),
                    shadowColor: const Color(0xFF1746A2),
                    onPressed: () {
                      context.go(Routes.playGamePage, extra: {
                        'games': widget.gameData ?? [],
                        'reference': widget.gameReference
                      });
                    },
                    child: Text(
                      AppLocalizations.of(context)!.playagain,
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

  Widget _buildBestScore(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InfoCard(
              title: AppLocalizations.of(context)!.bestScore,
              value: bestScore.toString(),
              icon: isNewBestScore ? Icons.emoji_events : Icons.star,
              cardColor: isDarkMode ? Colors.green[700]! : bestScoreColor,
            ),
          ],
        ),
        if (isNewBestScore)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Text(
              AppLocalizations.of(context)!.newBestScore,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.greenAccent : Colors.green[800],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTrophy(bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, 110),
          child: ShadowEllipse(
            width: 240,
            height: 120,
            backgroundColor:
                isDarkMode ? Colors.grey[800]! : const Color(0xFFE1E3E9),
          ),
        ),
        const Center(
          child: Image(
            image: AssetImage('assets/icons/trophy.png'),
            width: 360,
            height: 340,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  Widget _buildCongratulationsText(BuildContext context, bool isDarkMode) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.resultmain,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.yellow[700] : Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          AppLocalizations.of(context)!.resultexplain,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: isDarkMode ? Colors.yellow[600] : Colors.grey[800],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildScoreRow(BuildContext context, int correct, int wrong,
      String time, bool isDarkMode) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InfoCard(
          title: AppLocalizations.of(context)!.correct,
          value: correct.toString(),
          icon: Icons.check_circle,
          cardColor: correctAnswersColor,
        ),
        InfoCard(
          title: AppLocalizations.of(context)!.wrong,
          value: wrong.toString(),
          icon: Icons.cancel,
          cardColor: isDarkMode ? Colors.red[700]! : wrongAnswersColor,
        ),
        InfoCard(
          title: AppLocalizations.of(context)!.time,
          value: time,
          icon: Icons.watch_later,
          cardColor: isDarkMode ? Colors.amber[700]! : timeColor,
        ),
      ],
    );
  }
}
