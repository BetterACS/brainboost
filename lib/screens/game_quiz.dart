import 'package:flutter/material.dart';
import 'package:brainboost/component/buttons/quiz_buttons.dart';
import 'package:brainboost/models/games.dart';

class QuizScreen extends StatefulWidget {
  final GameQuizContent content;
  final Function onNext;

  const QuizScreen({
    super.key,
    required this.content,
    required this.onNext,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedAnswerIndex;
  bool hasCheckedAnswer = false;
  int score = 0;

  void pickAnswer(int value) {
    if (!hasCheckedAnswer) {
      setState(() {
        selectedAnswerIndex = value;
      });
    }
  }

  void checkAnswer() {
    if (selectedAnswerIndex == widget.content.correctAnswerIndex) {
      score++;
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
    return SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  
                  // Content of the quiz screen.
                  children: [
                    Text(
                      widget.content.question,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F71),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose the answer that you think is correct.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // [choices] is a list of options for the quiz.
                    // use [QuizOption] to display each option.
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: widget.content.options.length,
                      itemBuilder: (context, index) {
                        return QuizOption(
                          text: widget.content.options[index],
                          hasCheckedAnswer: hasCheckedAnswer,
                          onTap: () => pickAnswer(index),
                          index: index,
                          selectedIndex: selectedAnswerIndex,
                          correctIndex: widget.content.correctAnswerIndex,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // [ElevatedButton] to check the answer or go to the next question.
            QuizActionButton(
              hasCheckedAnswer: hasCheckedAnswer,
              selectedAnswerIndex: selectedAnswerIndex,
              onCheck: checkAnswer,
              onNext: goToNextQuestion,
            )
          ],
        ),
      );
  }
}
