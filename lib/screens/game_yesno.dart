import 'package:flutter/material.dart';
import 'package:tcard/tcard.dart';
import 'package:brainboost/models/games.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';

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

class _YesNoGameScreenState extends State<YesNoGameScreen>
    with SingleTickerProviderStateMixin {
  final TCardController _controller = TCardController();
  bool _showAnswer = false;
  bool _isCorrect = false;
  int _score = 0;
  int _currentQuestionIndex = 0;

  void _handleSwipe(SwipInfo info) {
    setState(() {
      _showAnswer = true;
      _isCorrect = (info.direction == SwipDirection.Right && widget.content[_currentQuestionIndex].correct_ans) ||
                   (info.direction == SwipDirection.Left && !widget.content[_currentQuestionIndex].correct_ans);
      if (_isCorrect) {
        _score++;
      }
    });
    Future.delayed(Duration(seconds: 3), () {
      widget.onNext(_isCorrect ? 1 : 0);
      setState(() {
        _showAnswer = false;
      });
      _nextQuestion();
    });
  }

  void _submitAnswer(bool answer) {
    setState(() {
      _showAnswer = true;
      _isCorrect = (answer == widget.content[_currentQuestionIndex].correct_ans);
      if (_isCorrect) {
        _score++;
      }
    });
    Future.delayed(Duration(seconds: 2), () {
      widget.onNext(_isCorrect ? 1 : 0);
      setState(() {
        _showAnswer = false;
      });
      _nextQuestion();
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.content.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _controller.forward();
      });
    } else {
      _navigateToResults();
    }
  }

  void _navigateToResults() {
    context.go(Routes.resultPage, extra: {
      'correct': _score,
      'wrong': widget.content.length - _score,
      'time': '00:00', // Update this with the actual time if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                    color: Color.fromARGB(255, 13, 15, 53),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: TCard(
                    controller: _controller,
                    size: Size(
                      MediaQuery.of(context).size.width * 0.9,
                      MediaQuery.of(context).size.height * 0.6,
                    ),
                    cards: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Text(
                              widget.content[_currentQuestionIndex].question,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                    onEnd: () {
                      widget.onNext(1); 
                    },
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
                  ElevatedButton(
                    onPressed: () => _submitAnswer(false),
                    child: Text("No", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton(
                    onPressed: () => _submitAnswer(true),
                    child: Text("Yes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}