import 'package:flutter/material.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/screens/game_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/component/bottom_slider.dart';

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

  final List<GameBingoContent> bingoList = [
    GameBingoContent(question: "Question 1?", answer: "1", point: 10),
    GameBingoContent(question: "Question 2?", answer: "2", point: 25),
    GameBingoContent(question: "Question 3?", answer: "3", point: 30),
    GameBingoContent(question: "Question 4?", answer: "4", point: 15),
    GameBingoContent(question: "Question 5?", answer: "5", point: 15),
    GameBingoContent(question: "Question 6?", answer: "6", point: 25),
    GameBingoContent(question: "Question 7?", answer: "7", point: 20),
    GameBingoContent(question: "Question 8?", answer: "8", point: 10),
    GameBingoContent(question: "Question 9?", answer: "9", point: 15),
  ];

  void goToNextQuestion() {
    // setState(() {
    //   // selectedAnswerIndex = null;
    //   hasCheckedAnswer = false;
    // });
    widget.onNext(score);
  }

  dynamic getNextButtonColor() {
    //  isBingoWin ?  : Colors.red
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
      'wrong': bingoList.length - _score,
      'time': '00:00',
    });
  }

  void _checkAnswer(int index) {
    setState(() {
      if (isAnswerCorrect[index] == true) {
        score += bingoList[index].point;
      }
    });
  }

  bool _areAllQuestionsAnswered() {
    return isAnswerChecked.length == bingoList.length;
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
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF092866),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[900]!),
                ),
                child: Text(
                  "${bingoList[index].point} Points",
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
                    bingoList[index].question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _answerController,
                    decoration: const InputDecoration(
                      hintText: "Answer",
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
                          onPressed: () {
                            setDialogState(() {
                              isAnswerCorrect[index] =
                                  _answerController.text.trim() ==
                                      bingoList[index].answer;
                              isAnswerChecked[index] = true;
                            });

                            Navigator.of(context).pop();
                            setState(() {
                              _showBottomSlider = true;
                            });

                            if (isAnswerCorrect[index] == true) {
                              _checkAnswer(index);
                              _checkBingoWin();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: const Color(0xFF092866),
                          ),
                          child: const Text(
                            "Submit",
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
    return SafeArea(
      child: Stack(
        children: [
          Column(
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
                              "เล่นบิงโก",
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Color.fromARGB(255, 13, 15, 53),
                              ),
                            ),
                          ),
                          Container(
                            width: 340,
                            child: Text(
                              "คุณมี $score คะแนน",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF1A1F71),
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
                            itemCount: 9,
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
                                                ? Colors.green[600]
                                                : isAnswerChecked[index] == true
                                                    ? Colors.red[600]
                                                    : Colors.blue[900],
                                            borderRadius: BorderRadius.circular(
                                                itemSize * 0.1),
                                          ),
                                          child: isAnswerChecked[index] != true
                                              ? Text(
                                                  "${bingoList[index].point}",
                                                  style: TextStyle(
                                                    fontSize: fontSize,
                                                    fontWeight: FontWeight.bold,
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
                                "เพื่อผ่านเกมนี้ คุณต้องบิงโกหรือสะสมคะแนนให้ครบ 75 คะแนนขึ้นไป",
                                maxLines: 2,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFF1A1F71),
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
          if (_currentQuestionIndex != -1)
            BottomSlider(
              isVisible: isBingoWin || _areAllQuestionsAnswered(),
              isTransitioning: widget.isTransitioning,
              data: {
                "gameType": "bingo",
                "question": "Game Completed!",
                "correctAnswer": "",
                "selectedAnswer": "",
                "isCorrect": isBingoWin || score >= 75,
                "points": score,
                "message": isBingoWin
                    ? "Congratulations! You got BINGO!"
                    : score >= 75
                        ? "Congratulations! You scored over 75 points!"
                        : "Sorry, you didn't achieve BINGO or reach 75 points!",
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
                'Next',
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
