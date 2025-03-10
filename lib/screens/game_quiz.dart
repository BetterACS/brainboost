import 'package:flutter/material.dart';
import 'package:brainboost/component/buttons/quiz_buttons.dart';
import 'package:brainboost/models/games.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:brainboost/component/bottom_slider.dart';

class QuizScreen extends StatefulWidget {
  final GameQuizContent content;
  final Function onNext;
  final bool isTransitioning;

  const QuizScreen({
    super.key,
    required this.content,
    required this.onNext,
    required this.isTransitioning,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  int? selectedAnswerIndex;
  bool hasCheckedAnswer = false;
  int score = 0;

  final player = AudioPlayer();
// await player.play(UrlSource('https://example.com/my-audio.wav'));

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void pickAnswer(int value) {
    if (!hasCheckedAnswer) {
      setState(() {
        selectedAnswerIndex = value;
      });
    }
  }

  void checkAnswer() async {
    if (selectedAnswerIndex == widget.content.correctAnswerIndex) {
      score++;
      await player.play(
          AssetSource('sounds/level-up-2-universfield-pixabay.mp3'),
          position: const Duration(milliseconds: 10));
    } else {
      await player.play(AssetSource('sounds/error-8-universfield-pixabay.mp3'),
          position: const Duration(milliseconds: 60));
    }

    setState(() {
      hasCheckedAnswer = true;
    });
  }

  void goToNextQuestion() {
    setState(() {
      selectedAnswerIndex = null;
      hasCheckedAnswer = false;
    });
    widget.onNext(score);
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

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

                    // Content of the quiz screen.
                    children: [
                      SizedBox(height: 10),
                      Column(
                          // Space between the question and the options.
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 340,
                              height: 48,
                              child: Text(
                                "ตอบคำถาม",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color.fromARGB(255, 13, 15, 53),
                                ),
                              ),
                            ),
                            Container(
                              width: 340,
                              // constraints: BoxConstraints(minHeight:96),
                              child: Text(
                                widget.content.question,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1F71),
                                ),
                              ),
                            ),
                            SizedBox(height: 26),

                            // [choices] is a list of options for the quiz.
                            // use [QuizOption] to display each option.
                            Center(
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 2),
                                itemCount: widget.content.options.length,
                                itemBuilder: (context, index) {
                                  return QuizOption(
                                    text: widget.content.options[index],
                                    hasCheckedAnswer: hasCheckedAnswer,
                                    onTap: () => pickAnswer(index),
                                    index: index,
                                    selectedIndex: selectedAnswerIndex,
                                    correctIndex:
                                        widget.content.correctAnswerIndex,
                                  );
                                },
                              ),
                            ),
                          ]),
                    ],
                  ),
                ),
              ),
              // SizedBox(height: screenHeight * 0.05), // Space for overlay
            ],
          ),

          BottomSlider(
            isVisible: hasCheckedAnswer,
            isTransitioning: widget.isTransitioning,
            data: {
              "gameType": "quiz",
              "correctAnswer":
                  widget.content.options[widget.content.correctAnswerIndex],
              "selectedAnswer": selectedAnswerIndex != null,
              "isCorrect":
                  selectedAnswerIndex == widget.content.correctAnswerIndex,
            },
          ),

          // Place QuizActionButton on top
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: QuizActionButton(
                hasCheckedAnswer: hasCheckedAnswer,
                selectedAnswerIndex: selectedAnswerIndex,
                onCheck: checkAnswer,
                onNext: goToNextQuestion,
                isCorrect: selectedAnswerIndex == widget.content.correctAnswerIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
