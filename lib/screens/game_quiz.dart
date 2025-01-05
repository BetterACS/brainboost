import 'package:flutter/material.dart';
import 'package:brainboost/models/question.dart';
import 'package:brainboost/router/routes.dart';
import 'package:go_router/go_router.dart';


const List<Question> questions = [
  Question(
    question: '1. What is the capital of France?',
    correctAnswerIndex: 1,
    options: [
      'a) Madrid',
      'b) Paris',
      'c) Berlin',
      'd) Rome',
    ],
  ),
  Question(
    question: '2. In what continent is Brazil located?',
    correctAnswerIndex: 3,
    options: [
      'a) Europe',
      'b) Asia',
      'c) North America',
      'd) South America',
    ],
  ),
];
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int? selectedAnswerIndex;
  int questionIndex = 0;
  int score = 0;
  bool hasCheckedAnswer = false;

  void pickAnswer(int value) {
    if (!hasCheckedAnswer) {
      setState(() {
        selectedAnswerIndex = value;
      });
    }
  }

  void checkAnswer() {
    final question = questions[questionIndex];
    if (selectedAnswerIndex == question.correctAnswerIndex) {
      score++;
    }
    setState(() {
      hasCheckedAnswer = true;
    });
  }

  void goToNextQuestion() {
    if (questionIndex < questions.length - 1) {
      setState(() {
        questionIndex++;
        selectedAnswerIndex = null;
        hasCheckedAnswer = false;
      });
    }
  }

  Color getAnswerColor(int index) {
    if (!hasCheckedAnswer) {
      return selectedAnswerIndex == index ? Colors.blue : Colors.grey.shade300;
    }

    if (index == questions[questionIndex].correctAnswerIndex) {
      return Colors.green;
    }
    
    if (index == selectedAnswerIndex) {
      return Colors.red;
    }

    return Colors.grey.shade300;
  }

  Color getAnswerBgColor(int index) {
    if (!hasCheckedAnswer) {
      return selectedAnswerIndex == index 
          ? Colors.blue.withOpacity(0.1) 
          : Colors.white;
    }

    if (index == questions[questionIndex].correctAnswerIndex) {
      return Colors.green.withOpacity(0.1);
    }
    
    if (index == selectedAnswerIndex) {
      return Colors.red.withOpacity(0.1);
    }

    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[questionIndex];
    bool isLastQuestion = questionIndex == questions.length - 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: questionIndex / questions.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 10,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1F71),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Choose the answer that you think is incorrect.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      separatorBuilder: (context, index) => 
                        const SizedBox(height: 12),
                      itemCount: question.options.length,
                      itemBuilder: (context, index) {
                        final borderColor = getAnswerColor(index);
                        final backgroundColor = getAnswerBgColor(index);
                        
                        return GestureDetector(
                          onTap: !hasCheckedAnswer ? () => pickAnswer(index) : null,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: borderColor,
                                width: 2,
                              ),
                              color: backgroundColor,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    question.options[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: hasCheckedAnswer 
                                          ? Colors.black87
                                          : (selectedAnswerIndex == index 
                                              ? Colors.blue 
                                              : Colors.black87),
                                    ),
                                  ),
                                ),
                                if (hasCheckedAnswer)
                                  Icon(
                                    index == question.correctAnswerIndex
                                        ? Icons.check_circle
                                        : (index == selectedAnswerIndex 
                                            ? Icons.cancel
                                            : null),
                                    color: index == question.correctAnswerIndex
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  if (!hasCheckedAnswer)
                    ElevatedButton(
                      onPressed: selectedAnswerIndex != null ? checkAnswer : null,
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
                      onPressed: isLastQuestion
                          ? () => context.push(Routes.resultPage, 
                              extra: {"score": score})
                          : goToNextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLastQuestion ? 'Finish' : 'Next',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),









                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
