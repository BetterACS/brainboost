import 'package:flutter/material.dart';
import 'package:tcard/tcard.dart';
import 'package:brainboost/component/bottom_slider.dart';
import 'package:brainboost/models/games.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YesNoGameScreen extends StatefulWidget {
  final GameYesNoContent content;
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

  void _handleSwipe(SwipInfo info) {
    print("handle ${widget.content.correct_ans}");
    setState(() {
      _showAnswer = true;
      _isCorrect = (info.direction == SwipDirection.Right && widget.content.correct_ans) ||
                   (info.direction == SwipDirection.Left && !widget.content.correct_ans);
    });
    Future.delayed(Duration(seconds: 10), () {
      widget.onNext(_isCorrect ? 1 : 0);
      setState(() {
        _showAnswer = false;
      });
    });
  }

  void _submitAnswer(bool answer) {
    setState(() {
      _showAnswer = true;
      _isCorrect = (answer == widget.content.correct_ans);
    });
    // Future.delayed(Duration(seconds: 2), () {
    //   widget.onNext(_isCorrect ? 1 : 0);
    //   setState(() {
    //     _showAnswer = false;
    //   });
    // });
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
                              widget.content.question,
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
          // BottomSlider(
          //   isVisible: false,
          //   isTransitioning: widget.isTransitioning,
          //   data: {},
          // ),
        ],
      ),
    );
  }
}
