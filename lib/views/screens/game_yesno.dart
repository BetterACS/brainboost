import 'package:brainboost/views/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:tcard/tcard.dart';
import 'package:brainboost/models/games.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';
import 'package:brainboost/views/widgets/bottom_slider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1A1F71);
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final borderColor = isDarkMode ? Colors.grey[600]! : Colors.grey;
    final correctColor = isDarkMode ? Colors.blue[400]! : Colors.blue;
    final incorrectColor = isDarkMode ? Colors.red[400]! : Colors.red;

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: backgroundColor,
          child: Stack(
            children: [
              Column(
                children: [
                  const Padding(padding: EdgeInsets.all(8.0)),
                  Container(
                    width: 340,
                    height: 48,
                    child: Text(
                      AppLocalizations.of(context)!.titleyesno,
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
                      AppLocalizations.of(context)!.expianedyesno,
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
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
                              side: BorderSide(color: borderColor, width: 2),
                            ),
                            color: cardColor,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  content.question,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
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
                        color: _isCorrect ? correctColor : incorrectColor,
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () => _submitAnswerWithButton(false),
                        child: Text(
                            AppLocalizations.of(context)!.no,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _submitAnswerWithButton(true),
                        child: Text(
                          AppLocalizations.of(context)!.yes,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
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
                              _isCorrect ? correctColor : incorrectColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:  Text(
                          AppLocalizations.of(context)!.next,
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
