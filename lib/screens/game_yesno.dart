import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';
import 'package:tcard/tcard.dart';
import 'package:brainboost/models/games.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/component/bottom_slider.dart';

class YesNoGameScreen extends StatefulWidget {
  final List<GameYesNoContent> content;
  final Function onNext;
  final bool isTransitioning;

  const YesNoGameScreen({
    super.key,
    required this.content,
    required this.onNext,
    required this.isTransitioning,
  });

  @override
  State<YesNoGameScreen> createState() => _YesNoGameScreenState();
}

class _YesNoGameScreenState extends State<YesNoGameScreen> {
  final TCardController _controller = TCardController();
  bool _showAnswer = false;
  bool _isCorrect = false;
  int _score = 0;
  int _currentQuestionIndex = 0;

  void _handleSwipe(SwipInfo info) {
    setState(() {
      _showAnswer = true;
      _isCorrect = (info.direction == SwipDirection.Right &&
              widget.content[_currentQuestionIndex].correct_ans) ||
          (info.direction == SwipDirection.Left &&
              !widget.content[_currentQuestionIndex].correct_ans);
      if (_isCorrect) {
        _score++;
      }
    });

    Future.delayed(Duration(seconds: 3), () {
      print('onNext called with: ${_isCorrect ? 1 : 0}');
      widget.onNext(_isCorrect ? 1 : 0);
      setState(() {
        _showAnswer = false;
      });
      _nextQuestion();
    });
  }

  void _submitAnswerWithButton(bool answer) {
    setState(() {
      _showAnswer = true;
      _isCorrect =
          (answer == widget.content[_currentQuestionIndex].correct_ans);
      if (_isCorrect) {
        _score++;
      }
    });

    Future.delayed(Duration(seconds: 2), () {
      print('onNext called with: ${_isCorrect ? 1 : 0}');
      widget.onNext(_isCorrect ? 1 : 0);
      setState(() {
        _showAnswer = false;
      });
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    print('Current Question Index: $_currentQuestionIndex');
    if (_currentQuestionIndex < widget.content.length + 1) {
      setState(() {
        _currentQuestionIndex++;
        _controller.forward();
      });
      print('Next Question Index: $_currentQuestionIndex');
    } else {
      print('Navigating to Results');
      _navigateToResults();
    }
  }

  void _navigateToResults() {
    print('Score: $_score');
    context.go(Routes.resultPage, extra: {
      'correct': _score,
      'wrong': widget.content.length - _score,
      'time': '00:00', // Update this with the actual time if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: AppColors.mainColor,
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                  ),
                  Container(
                    width: 340,
                    height: 48,
                    child: Text(
                      "Yes or No",
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1F71),
                      ),
                    ),
                  ),
                  Container(
                    width: 340,
                    child: Text(
                      "Slide to left for No, right for Yes.",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1F71),
                      ),
                    ),
                    
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: Center(
                      child: TCard(
                        controller: _controller,
                        size: Size(
                          MediaQuery.of(context).size.width * 0.8,
                          MediaQuery.of(context).size.height * 0.5,
                        ),
                        cards: widget.content.map<Widget>((content) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: Colors.grey, width:2),
                            ),
                            color: Colors.white,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  content.question,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1F71),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onForward: (index, info) {
                          _handleSwipe(info);
                        },
                      ),
                    ),
                  ),
                  if (_showAnswer)
                    Text(
                      _isCorrect ? "Correct!" : "Incorrect!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect ? Colors.green : Colors.red,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () => _submitAnswerWithButton(false),
                        child: Text(
                          "No",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F71), // สีน้ำเงิน
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _submitAnswerWithButton(true),
                        child: Text(
                          "Yes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F71), // สีน้ำเงิน
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                ],
              ),
                        // ),
              BottomSlider(
                isVisible: _showAnswer,
                isTransitioning: widget.isTransitioning,

                data: {
                  "gameType": "yesno",
                  "question": widget.content.map((e) => e.question).toList()[0],
                  "selectedAnswer": true, //selectedAnswerIndex != null,
                  "correctAnswer": "Yes", //widget.content.correct_ans ? "Yes" : "No",
                  "isCorrect": _isCorrect,
                },
              ),


            ],
          ),
        ),
      ),
    );
  }
}
