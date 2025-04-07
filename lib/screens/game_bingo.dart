import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/screens/game_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/component/bottom_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:brainboost/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BingoScreen extends StatefulWidget {
  final BingoContent content;
  final Function onNext;
  final bool isTransitioning;

  const BingoScreen({
    super.key,
    required this.content,
    required this.onNext,
    required this.isTransitioning,
  });

  @override
  State<BingoScreen> createState() => _BingoScreenState();
}

class _BingoScreenState extends State<BingoScreen> {
  final TextEditingController _answerController = TextEditingController();
  Map<int, bool> isAnswerCorrect = {};
  Map<int, bool> isAnswerChecked = {};
  bool isBingoWin = false;
  int score = 0;
  bool _showBottomSlider = false;
  int _currentQuestionIndex = -1;
  bool _isCheckingAnswer = false;

  Future<bool> checkAnswerSimilarity(
      String userAnswer, String correctAnswer) async {
    try {
      final httpClient = http.Client();
      var extractResponse = await httpClient.get(
        Uri.https('monsh.xyz', '/get_similarity',
            {'context1': userAnswer.trim(), 'context2': correctAnswer}),
      );

      if (extractResponse.statusCode == 200) {
        final jsonResponse = jsonDecode(extractResponse.body);
        if (jsonResponse['status'] == 200) {
          double similarity = jsonResponse['data'];
          return similarity >= 0.80;
        }
      }
      return false;
    } catch (e) {
      print('Error checking answer similarity: $e');
      return false;
    }
  }

  void goToNextQuestion() {
    widget.onNext(isBingoWin ? 1 : 0);
  }

  dynamic getNextButtonColor() {
    if (isBingoWin) {
      return Colors.blue;
    } else if (!isBingoWin && _areAllQuestionsAnswered()) {
      return Colors.red;
    } else {
      return Colors.grey[300];
    }
  }

  void _navigateToResults() {
    int _score = isAnswerCorrect.values.where((correct) => correct).length;

    context.go(Routes.resultPage, extra: {
      'correct': _score,
      'wrong': widget.content.bingo_list.length - _score,
      'time': '00:00',
    });
  }

  void _checkAnswer(int index) {
    setState(() {
      if (isAnswerCorrect[index] == true) {
        score += widget.content.bingo_list[index].point;
      }
    });
  }

  bool _areAllQuestionsAnswered() {
    bool cond1 = isAnswerChecked.length == widget.content.bingo_list.length;
    bool cond2 = isAnswerChecked.values.every((isChecked) => isChecked == true);
    return cond1 && cond2;
  }

  void _checkBingoWin() {
    bool hasBingo = false;

    for (int row = 0; row < 3; row++) {
      if (isAnswerCorrect[row * 3] == true &&
          isAnswerCorrect[row * 3 + 1] == true &&
          isAnswerCorrect[row * 3 + 2] == true) {
        hasBingo = true;
        break;
      }
    }

    for (int col = 0; col < 3; col++) {
      if (isAnswerCorrect[col] == true &&
          isAnswerCorrect[col + 3] == true &&
          isAnswerCorrect[col + 6] == true) {
        hasBingo = true;
        break;
      }
    }

    if ((isAnswerCorrect[0] == true &&
            isAnswerCorrect[4] == true &&
            isAnswerCorrect[8] == true) ||
        (isAnswerCorrect[2] == true &&
            isAnswerCorrect[4] == true &&
            isAnswerCorrect[6] == true)) {
      hasBingo = true;
    }

    setState(() {
      isBingoWin = hasBingo;
      if (hasBingo || score >= 75 || _areAllQuestionsAnswered()) {
        _showBottomSlider = true;
        _currentQuestionIndex = -2;
      }
    });
  }

  void _showQuestionDialog(int index) {
    _answerController.clear();
    setState(() {
      isAnswerChecked[index] = false;
      _currentQuestionIndex = index;
      _showBottomSlider = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final currentTheme = Theme.of(context).brightness;
        final bool isDarkMode = currentTheme == Brightness.dark;
        final backgroundColor =
            isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor;
        final textColor = isDarkMode ? Colors.white : Colors.black;
        final cardColor =
            isDarkMode ? AppColors.accentDarkmode : Colors.blue[900];
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white),
                ),
                child: Text(
                  "${widget.content.bingo_list[index].point} Points",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.content.bingo_list[index].question,
                    textAlign: TextAlign.center,
                    style:  TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _answerController,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.answer,
                      hintStyle: TextStyle(color: Color(0xFFC2C2C2)),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF092866)),
                      ),
                      filled: true,
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isCheckingAnswer
                              ? null
                              : () async {
                                  setDialogState(() {
                                    _isCheckingAnswer = true;
                                  });

                                  final isCorrect = await checkAnswerSimilarity(
                                    _answerController.text,
                                    widget.content.bingo_list[index].answer,
                                  );

                                  setDialogState(() {
                                    _isCheckingAnswer = false;
                                  });

                                  setState(() {
                                    isAnswerCorrect[index] = isCorrect;
                                    isAnswerChecked[index] = true;
                                    _showBottomSlider = true;
                                  });

                                  Navigator.of(context).pop();

                                  if (isCorrect) {
                                    _checkAnswer(index);
                                    _checkBingoWin();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: isDarkMode
                                ? AppColors.accentDarkmode
                                : Colors.blue[900],
                          ),
                          child: _isCheckingAnswer
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)!.submit,
                                  style: TextStyle(color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void didUpdateWidget(BingoScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isTransitioning) {
      setState(() {
        _showBottomSlider = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bingoList = widget.content.bingo_list;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final cardColor = isDarkMode ? AppColors.accentDarkmode : Colors.blue[900];
    final correctColor = isDarkMode ? Colors.blue[900] : Colors.blue[900];
    final wrongColor = isDarkMode ? Colors.red[400] : Colors.red[600];

    return SafeArea(
      child: Stack(
        children: [
          Container(
            color: backgroundColor,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            Container(
                              width: 340,
                              height: 48,
                              child: Text(
                                AppLocalizations.of(context)!.playBingo,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Container(
                              width: 340,
                              child: Text(
                                AppLocalizations.of(context)!.yourPoints(score.toString()),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1,
                                mainAxisExtent: 60,
                              ),
                              itemCount: bingoList.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: isAnswerCorrect[index] == true
                                      ? null
                                      : () {
                                          _showQuestionDialog(index);
                                        },
                                  child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      final size = MediaQuery.of(context).size;
                                      final itemSize = size.width * 0.25;
                                      final fontSize = itemSize * 0.25;
                                      final iconSize = itemSize * 0.4;

                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Container(
                                            alignment: Alignment.center,
                                            width: 120,
                                            height: 480,
                                            decoration: BoxDecoration(
                                              color: isAnswerCorrect[index] ==
                                                      true
                                                  ? correctColor
                                                  : isAnswerChecked[index] ==
                                                          true
                                                      ? wrongColor
                                                      : cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      itemSize * 0.1),
                                            ),
                                            child:
                                                isAnswerChecked[index] != true
                                                    ? Text(
                                                        "${widget.content.bingo_list[index].point}",
                                                        style: TextStyle(
                                                          fontSize: fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                        ),
                                                      )
                                                    : const SizedBox(),
                                          ),
                                          if (isAnswerChecked[index] == true)
                                            Align(
                                              alignment: Alignment.center,
                                              child: Icon(
                                                isAnswerCorrect[index] == true
                                                    ? Icons.check_circle
                                                    : Icons.clear,
                                                color: Colors.white,
                                                size: iconSize,
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24),
                            Container(
                              width: 340,
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.bingoRequirement,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_currentQuestionIndex != -1)
            BottomSlider(
              isVisible: isBingoWin || _areAllQuestionsAnswered(),
              isTransitioning: widget.isTransitioning,
              data: {
                "gameType": "bingo",
                "question": AppLocalizations.of(context)!.gameCompleted,
                "correctAnswer": "",
                "selectedAnswer": "",
                "isCorrect": isBingoWin || score >= 75,
                "points": score,
                "message": isBingoWin
                    ? AppLocalizations.of(context)!.congratulationsBingo
                    : score >= 75
                        ? AppLocalizations.of(context)!.congratulationsScore
                        : AppLocalizations.of(context)!.sorryNoWin,
              },
            ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: ElevatedButton(
              onPressed: goToNextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: getNextButtonColor(),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.next,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
