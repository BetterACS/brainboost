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

/// A widget that displays a quiz option with dynamic styling.
/// 
/// Changes appearance based on:
/// - Whether an answer has been checked
/// - If the option is selected
/// - If the option is correct/incorrect after checking

class QuizOption extends StatelessWidget {
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

  Color _getBorderColor() {
    if (!hasCheckedAnswer) {
      return selectedIndex == index ? AppColors.borderQuizSelectedOption : AppColors.borderQuizOption;
    }
    
    if (index == correctIndex) return AppColors.borderQuizCorrectOption;
    if (index == selectedIndex) return AppColors.borderQuizIncorrectOption;
    return AppColors.borderQuizNonSelectedOption;
  }

  Color _getBackgroundColor() {
    if (!hasCheckedAnswer) {
      return selectedIndex == index ? AppColors.backgroundQuizSelectedOption : AppColors.backgroundQuizOption;
    }
    
    if (index == correctIndex) return AppColors.backgroundQuizCorrectOption;
    if (index == selectedIndex) return AppColors.backgroundQuizIncorrectOption;
    return AppColors.backgroundQuizNonSelectedOption;
  }

  Color _getTextColor() {
    if (!hasCheckedAnswer) {
      return selectedIndex == index ? AppColors.textQuizSelectedOption : AppColors.textQuizOption;
    }
    
    if (index == correctIndex) return AppColors.textQuizCorrectOption;
    if (index == selectedIndex) return AppColors.textQuizIncorrectOption;
    return AppColors.textQuizNonSelectedOption;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !hasCheckedAnswer ? onTap : null,
      child: Container(
        width: double.infinity, 
        decoration: BoxDecoration(
          color: _getBorderColor(),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _getBorderColor(),
            width: 2,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: _getTextColor(),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
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

  const QuizActionButton({
    super.key,
    required this.hasCheckedAnswer,
    required this.selectedAnswerIndex,
    required this.onCheck,
    required this.onNext,
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
                  fontSize: 16,
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
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
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
