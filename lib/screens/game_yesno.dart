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
  bool _disableSwipe = false;
  bool _isLocked = false;
  int _currentQuestionIndex = 0;

  void _handleSwipe(SwipInfo info) {
    if (_disableSwipe) return;

    setState(() {
      _showAnswer = true;
      _isCorrect = (info.direction == SwipDirection.Right &&
              widget.content[_currentQuestionIndex].correct_ans) ||
          (info.direction == SwipDirection.Left &&
              !widget.content[_currentQuestionIndex].correct_ans);
      if (_isCorrect) {
        _score++;
      }
      _disableSwipe = true;
    });
  }

  void _submitAnswerWithButton(bool answer) {
    if (_disableSwipe) return;
     _isLocked = true;

    setState(() {
      _showAnswer = true;
      _isCorrect =
          (answer == widget.content[_currentQuestionIndex].correct_ans);
      if (_isCorrect) {
        _score++;
      }
      _disableSwipe = true;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.content.length) {
      setState(() {
        _currentQuestionIndex++;
        _showAnswer = false;
        _disableSwipe = false;
         _isLocked = false;
        widget.onNext(_isCorrect ? 1 : 0);
      });
    } else {
      _navigateToResults();
    }
  }

  void _navigateToResults() {
    context.go(Routes.resultPage, extra: {
      'correct': _score,
      'wrong': widget.content.length - _score,
      'time': '00:00',
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
                  const Padding(padding: EdgeInsets.all(8.0)),
                  Container(
                    width: 340,
                    height: 48,
                    child: const Text(
                      "Yes or No",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF1A1F71),
                      ),
                    ),
                  ),
                  Container(
                    width: 340,
                    child: const Text(
                      "Slide to left for No, right for Yes.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1A1F71),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Expanded(
                    child: Center(
                      child: TCard(
                        controller: _controller,
                        size: Size(
                          MediaQuery.of(context).size.width * 0.8,
                          MediaQuery.of(context).size.height * 0.5,
                        ),
                        lockYAxis: true,
                        slideSpeed: _isLocked ? 0 : 20,
                        onForward: _isLocked
                            ? null
                            : (index, info) => _handleSwipe(info),
                        cards: widget.content.map<Widget>((content) {
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: const BorderSide(
                                  color: Colors.grey, width: 2),
                            ),
                            color: Colors.white,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  content.question,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1F71),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
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
                        child: const Text(
                          "No",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F71),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _submitAnswerWithButton(true),
                        child: const Text(
                          "Yes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1F71),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
              BottomSlider(
                isVisible: _showAnswer,
                isTransitioning: widget.isTransitioning,
                data: _currentQuestionIndex < widget.content.length
                    ? {
                        "gameType": "yesno",
                        "question":
                            widget.content[_currentQuestionIndex].question,
                        "selectedAnswer": _isCorrect ? "Yes" : "No",
                        "correctAnswer":
                            widget.content[_currentQuestionIndex].correct_ans
                                ? "Yes"
                                : "No",
                        "isCorrect": _isCorrect,
                      }
                    : {},
              ),
              if (_showAnswer)
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.8,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _nextQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isCorrect ? Colors.blue : Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
