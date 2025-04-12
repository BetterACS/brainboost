import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/component/bottom_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:brainboost/provider/theme_provider.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialize maps for all possible cells in the bingo game
    for (int i = 0; i < widget.content.bingo_list.length; i++) {
      isAnswerCorrect[i] = false;
      isAnswerChecked[i] = false;
    }
  }

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



      final jsonResponse = jsonDecode(extractResponse.body);
      print(jsonResponse);
      print("Status: ${extractResponse.statusCode}");
      if (extractResponse.statusCode == 200) {
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
      barrierDismissible: true,
      builder: (context) {
        final bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
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
              title: Stack(
                children: [
                  Container(
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
                  Positioned(
                    right: -8,
                    top: -8,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.content.bingo_list[index].question,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _answerController,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.answer,
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? AppColors.white
                            : AppColors.accentDarkmode2,
                      ),
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
                  child: Column(
                    children: [
                      Row(
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

                                      if (isCorrect) {
                                        _checkAnswer(index);
                                        _checkBingoWin();
                                        Navigator.of(context).pop();
                                      } else {
                                        // Show correct answer when user answers incorrectly
                                        setDialogState(() {});
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
                      if (isAnswerChecked[index] == true && isAnswerCorrect[index] == false)
                        Container(
                          margin: EdgeInsets.only(top: 16),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDarkMode 
                                ? Colors.red[900]!.withOpacity(0.3)
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.red[300]!,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Correct Answer:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode ? Colors.red[200] : Colors.red[800],
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.content.bingo_list[index].answer,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 12),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: isDarkMode ? Colors.blue[300] : Colors.blue[800],
                                  ),
                                  child: Text(AppLocalizations.of(context)?.close ?? "Close"),
                                ),
                              ),
                            ],
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

    final bool isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
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
                                AppLocalizations.of(context)!
                                    .yourPoints(score.toString()),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 64),
                            GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1, // This ensures square shape
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
                                      final itemSize = constraints.maxWidth;

                                      return AnimatedContainer(
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeOutBack,
                                        alignment: Alignment.center,
                                        width: itemSize,
                                        height: itemSize,
                                        decoration: BoxDecoration(
                                          color: isAnswerCorrect[index] == true
                                              ? correctColor?.withOpacity(0.9)
                                              : isAnswerChecked[index] == true
                                                  ? wrongColor?.withOpacity(0.9)
                                                  : cardColor?.withOpacity(0.85),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isAnswerCorrect[index] == true
                                                      ? Colors.blue
                                                      : isAnswerChecked[index] == true
                                                          ? Colors.red
                                                          : Colors.black)
                                                  .withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 6,
                                              offset: Offset(0, 3),
                                            ),
                                          ],
                                          border: Border.all(
                                            color: isAnswerCorrect[index] == true
                                                ? Colors.blue[300]!
                                                : isAnswerChecked[index] == true
                                                    ? Colors.red[300]!
                                                    : Colors.blue[700]!,
                                            width: 2.0,
                                          ),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: isAnswerCorrect[index] == true
                                                ? [Colors.blue[800]!, Colors.blue[600]!]
                                                : isAnswerChecked[index] == true
                                                    ? [Colors.red[700]!, Colors.red[500]!]
                                                    : isDarkMode
                                                        ? [Color(0xFF1A3268), Color(0xFF0C1E40)]
                                                        : [Color(0xFF1E40AF), Color(0xFF1E3A8A)],
                                          ),
                                        ),
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            if (isAnswerChecked[index] != true)
                                              TweenAnimationBuilder(
                                                duration: Duration(milliseconds: 300),
                                                tween: Tween<double>(begin: 0.8, end: 1.0),
                                                builder: (context, double value, child) {
                                                  return Transform.scale(
                                                    scale: value,
                                                    child: Text(
                                                      "${index + 1}",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: itemSize * 0.35,
                                                        shadows: [
                                                          Shadow(
                                                            offset: Offset(0, 2),
                                                            blurRadius: 3.0,
                                                            color: Colors.black.withOpacity(0.3),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            if (isAnswerChecked[index] == true)
                                              TweenAnimationBuilder(
                                                duration: Duration(milliseconds: 600),
                                                tween: Tween<double>(begin: 0.0, end: 1.0),
                                                curve: Curves.elasticOut,
                                                builder: (context, double value, child) {
                                                  return Opacity(
                                                    opacity: value,
                                                    child: Transform.scale(
                                                      scale: value,
                                                      child: Icon(
                                                        isAnswerCorrect[index] == true
                                                            ? Icons.check_circle_rounded
                                                            : Icons.cancel_rounded,
                                                        color: Colors.white,
                                                        size: itemSize * 0.5,
                                                        shadows: [
                                                          Shadow(
                                                            offset: Offset(0, 2),
                                                            blurRadius: 3.0,
                                                            color: Colors.black.withOpacity(0.3),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 32),
                            Container(
                              width: 340,
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isDarkMode 
                                    ? Colors.blueGrey[800]!.withOpacity(0.6)
                                    : Colors.blue[50]!.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode ? Colors.blueGrey[600]! : Colors.blue[200]!,
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .bingoRequirement,
                                  maxLines: 2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 72),  // Extra space for the bottom button
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
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              transform: Matrix4.translationValues(
                0, 
                _showBottomSlider ? 0 : 20, 
                0
              ),
              child: ElevatedButton(
                onPressed: goToNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: getNextButtonColor(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isBingoWin || _areAllQuestionsAnswered() ? 4 : 1,
                  shadowColor: isBingoWin ? Colors.blue.withOpacity(0.5) : 
                              _areAllQuestionsAnswered() ? Colors.red.withOpacity(0.5) : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.next,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Game status indicator
          Positioned(
            top: 85,
            right: 24,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isBingoWin ? Colors.green[700] : 
                        score >= 75 ? Colors.blue[700] : 
                        isDarkMode ? Colors.blueGrey[800] : Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isBingoWin ? Colors.green[400]! : 
                           score >= 75 ? Colors.blue[400]! : 
                           isDarkMode ? Colors.blueGrey[600]! : Colors.blue[200]!,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      isBingoWin ? Icons.emoji_events : Icons.star,
                      color: isBingoWin || score >= 75 ? Colors.white : 
                             isDarkMode ? Colors.white70 : Colors.blue[900],
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "$score pts",
                      style: TextStyle(
                        color: isBingoWin || score >= 75 ? Colors.white : 
                               isDarkMode ? Colors.white70 : Colors.blue[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
