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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.hasCheckedAnswer ? null : _handleTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            height: 78, // Fixed outer height
            width: double.infinity,
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
                      width: double.infinity,
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: _getBorderColor(),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _getBorderColor(),
                          width: 1, // Reduced the border width
                        ),
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        margin: EdgeInsets.only(bottom: _isClicked ? 1 : 5),
                        constraints: BoxConstraints(
                          minHeight: 64.0,
                        ),
                        padding: const EdgeInsets.all(4),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _getBackgroundColor(),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            widget.text,
                            textAlign:
                                TextAlign.center, // จัดให้ข้อความอยู่ตรงกลาง
                            softWrap: true, // ให้ตัดบรรทัดอัตโนมัติ
                            maxLines: 2, // จำกัดจำนวนบรรทัด
                            overflow: TextOverflow
                                .ellipsis, // แสดง ... หากข้อความยาวเกินไป
                            style: TextStyle(
                              fontSize: 18,
                              color: _getTextColor(),
                              height:
                                  1.2, // ปรับระยะห่างระหว่างบรรทัดให้เหมาะสม
                            ),
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
                AppLocalizations.of(context)!.tryAgain,
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
                AppLocalizations.of(context)!.continueText,
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
