import 'package:brainboost/views/widgets/colors.dart';
import 'package:flutter/material.dart';
import 'package:brainboost/views/widgets/buttons/quiz_buttons.dart';
import 'package:brainboost/models/games.dart';
// import 'package:audioplayers/audioplayers.dart';
import 'package:brainboost/views/widgets/bottom_slider.dart';

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

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  int? selectedAnswerIndex;
  bool hasCheckedAnswer = false;
  int score = 0;

    // final player = AudioPlayer();
// await player.play(UrlSource('https://example.com/my-audio.wav'));
  
  // ความสูงของปุ่มและ padding รอบๆ 
  final double buttonAreaHeight = 80.0;

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
      // await player.play(
      //     AssetSource('sounds/level-up-2-universfield-pixabay.mp3'),
      //     position: const Duration(milliseconds: 10));
    }
    // else {
    //   await player.play(AssetSource('sounds/error-8-universfield-pixabay.mp3'),
    //       position: const Duration(milliseconds: 60));
    // }

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? AppColors.backgroundDarkmode : AppColors.mainColor;
    final textColor =
        isDarkMode ? Colors.white : const Color.fromARGB(255, 13, 15, 53);
    final questionColor =
        isDarkMode ? Colors.grey[300] : const Color(0xFF1A1F71);

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
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: textColor,
                                ),
                              ),
                            ),
                            Container(
                              width: 340,
                              // constraints: BoxConstraints(minHeight:96),
                              child: Text(
                                widget.content.question,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: questionColor,
                                ),
                              ),
                            ),
                            SizedBox(height: 26),

                            // [choices] is a list of options for the quiz.
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
                            
                            // เพิ่ม padding ด้านล่างให้พอดีกับความสูงของปุ่มจะได้ไม่ซ้อนทับกัน
                            SizedBox(height: buttonAreaHeight),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          BottomSlider(
            isVisible: hasCheckedAnswer,
            isTransitioning: widget.isTransitioning,
            data: {
              "gameType": "quiz",
              "question": widget.content.question,
              "correctAnswer":
                  widget.content.options[widget.content.correctAnswerIndex],
              "selectedAnswer": selectedAnswerIndex != null,
              "isCorrect":
                  selectedAnswerIndex == widget.content.correctAnswerIndex,
            },
          ),
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
                isCorrect:
                    selectedAnswerIndex == widget.content.correctAnswerIndex,
              ),
            ),
          ),
        ],
      ),
    );
  }
}