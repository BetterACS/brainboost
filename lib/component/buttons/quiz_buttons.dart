// ignore: dangling_library_doc_comments
/// Quiz game components that handle the UI for quiz options and action buttons.
///
/// This file contains two main components:
/// - [QuizOption]: A widget that displays a single quiz answer option with dynamic
///   styling based on user interaction and answer correctness.
/// - [QuizActionButton]: A widget that handles the Check/Next button functionality
///   during quiz progression.

import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';
import 'package:lottie/lottie.dart';

/// A widget that displays a quiz option with dynamic styling.
///
/// Changes appearance based on:
/// - Whether an answer has been checked
/// - If the option is selected
/// - If the option is correct/incorrect after checking

class QuizOption extends StatefulWidget {
  final String text;
  final bool hasCheckedAnswer;
  final VoidCallback? onTap;
  final int index;
  final int? selectedIndex;
  final int correctIndex;

  const QuizOption({
    super.key,
    required this.text,
    required this.hasCheckedAnswer,
    required this.onTap,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
  });

  @override
  _QuizOptionState createState() => _QuizOptionState();
}

class _QuizOptionState extends State<QuizOption> {
  double width = 300;
  bool _isClicked = false;

  void _handleTap() {
    if (!widget.hasCheckedAnswer) {
      setState(() => _isClicked = true);
      widget.onTap?.call();
      Future.delayed(const Duration(milliseconds: 30), () {
        if (mounted) setState(() => _isClicked = false);
      });
    }
  }

  Color _getBorderColor() {
    if (!widget.hasCheckedAnswer) {
      return widget.selectedIndex == widget.index
          ? AppColors.borderQuizSelectedOption
          : AppColors.borderQuizOption;
    }

    if (widget.index == widget.correctIndex)
      return AppColors.borderQuizCorrectOption;
    if (widget.index == widget.selectedIndex)
      return AppColors.borderQuizIncorrectOption;
    return AppColors.borderQuizNonSelectedOption;
  }

  Color _getBackgroundColor() {
    if (!widget.hasCheckedAnswer) {
      return widget.selectedIndex == widget.index
          ? AppColors.backgroundQuizSelectedOption
          : AppColors.backgroundQuizOption;
    }

    if (widget.index == widget.correctIndex)
      return AppColors.backgroundQuizCorrectOption;
    if (widget.index == widget.selectedIndex)
      return AppColors.backgroundQuizIncorrectOption;
    return AppColors.backgroundQuizNonSelectedOption;
  }

  Color _getTextColor() {
    if (!widget.hasCheckedAnswer) {
      return widget.selectedIndex == widget.index
          ? AppColors.textQuizSelectedOption
          : AppColors.textQuizOption;
    }

    if (widget.index == widget.correctIndex)
      return AppColors.textQuizCorrectOption;
    if (widget.index == widget.selectedIndex)
      return AppColors.textQuizIncorrectOption;
    return AppColors.textQuizNonSelectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88, // Fixed outer height
      width: width,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 80),
            bottom: _isClicked ? -0.5 : 0, // Move down a little when clicked
            left: 2,
            right: 2,
            child: GestureDetector(
              onTap: _handleTap,
              child: Container(
                width: width,
                padding: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: _getBorderColor(),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _getBorderColor(),
                    width: 2,
                  ),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 80),
                  margin: EdgeInsets.only(bottom: _isClicked ? 1 : 5),
                  constraints: BoxConstraints(
                    minHeight: 64.0,
                  ),
                  padding: const EdgeInsets.all(4),
                  width: width,
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 18,
                        color: _getTextColor(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Lottie.asset("assets/animations/quiz_correct_answer.json",
          //     height: 48, width: 48, repeat: false),
        ],
      ),
    );
  }
}

/// A widget that displays either a Check or Next button based on quiz state.
///
/// Shows:
/// - Check button: When answer hasn't been checked
/// - Next button: After answer has been checked
class QuizActionButton extends StatelessWidget {
  final bool hasCheckedAnswer;
  final int? selectedAnswerIndex;
  final VoidCallback onCheck;
  final VoidCallback onNext;
  final bool isCorrect;

  const QuizActionButton({
    super.key,
    required this.hasCheckedAnswer,
    required this.selectedAnswerIndex,
    required this.onCheck,
    required this.onNext,
    required this.isCorrect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!hasCheckedAnswer)
            ElevatedButton(
              onPressed: selectedAnswerIndex != null ? onCheck : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedAnswerIndex != null
                    ? Colors.blue
                    : Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Check',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: selectedAnswerIndex != null
                      ? Colors.white
                      : Colors.grey.shade600,
                ),
              ),
            ),
          if (hasCheckedAnswer)
            ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCorrect ? Colors.blue : Colors.red,
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
        ],
      ),
    );
  }
}
