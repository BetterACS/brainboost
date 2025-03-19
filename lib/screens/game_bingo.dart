import 'package:flutter/material.dart';
import 'package:brainboost/models/games.dart';
import 'package:brainboost/screens/game_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:brainboost/router/routes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: BingoScreen(),
//     );
//   }
// }

class BingoScreen extends StatefulWidget {
  final BingoContent content;
  final Function onNext;
  final bool isTransitioning;

  const BingoScreen({
    super.key,
    required this.content,
    required this.onNext,
    required this.isTransitioning,
  });

  @override
  State<BingoScreen> createState() => _BingoScreenState();
}

class _BingoScreenState extends State<BingoScreen> {
  final TextEditingController _answerController = TextEditingController();
  Map<int, bool> isAnswerCorrect = {};
  Map<int, bool> isAnswerChecked = {};
  bool isBingoWin = false;
  int score = 0;

  // 🔹 เพิ่มรายการคำถามบิงโก 9 ข้อ
  final List<GameBingoContent> bingoList = [
    GameBingoContent(question: "Question 1?", answer: "1", point: 10),
    GameBingoContent(question: "Question 2?", answer: "2", point: 25),
    GameBingoContent(question: "Question 3?", answer: "3", point: 30),
    GameBingoContent(question: "Question 4?", answer: "4", point: 15),
    GameBingoContent(question: "Question 5?", answer: "5", point: 15),
    GameBingoContent(question: "Question 6?", answer: "6", point: 25),
    GameBingoContent(question: "Question 7?", answer: "7", point: 20),
    GameBingoContent(question: "Question 8?", answer: "8", point: 10),
    GameBingoContent(question: "Question 9?", answer: "9", point: 15),
  ];

  void _navigateToResults() {
    int _score = isAnswerCorrect.values.where((correct) => correct).length;

    context.go(Routes.resultPage, extra: {
      'correct': _score,
      'wrong': bingoList.length - _score,
      'time': '00:00',
    });
  }

  void _checkAnswer(int index) {
    setState(() {
      if (isAnswerCorrect[index] == true) {
        score += bingoList[index].point;
      }
    });
  }

  void _checkBingoWin() {
    for (int row = 0; row < 3; row++) {
      if (isAnswerCorrect[row * 3] == true &&
          isAnswerCorrect[row * 3 + 1] == true &&
          isAnswerCorrect[row * 3 + 2] == true) {
        setState(() {
          isBingoWin = true;
        });
        return;
      }
    }

    for (int col = 0; col < 3; col++) {
      if (isAnswerCorrect[col] == true &&
          isAnswerCorrect[col + 3] == true &&
          isAnswerCorrect[col + 6] == true) {
        setState(() {
          isBingoWin = true;
        });
        return;
      }
    }

    if ((isAnswerCorrect[0] == true &&
            isAnswerCorrect[4] == true &&
            isAnswerCorrect[8] == true) ||
        (isAnswerCorrect[2] == true &&
            isAnswerCorrect[4] == true &&
            isAnswerCorrect[6] == true)) {
      setState(() {
        isBingoWin = true;
      });
    }
  }

  void _showQuestionDialog(int index) {
    _answerController.clear();
    setState(() {
      isAnswerChecked[index] = false;
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF092866),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[900]!),
                ),
                child: Text(
                  "${bingoList[index].point} Points",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    bingoList[index].question,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 32,
                    width: 32,
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          hintText: "Answer",
                          hintStyle: const TextStyle(color: Color(0xFFC2C2C2)),
                          border: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Color(0xFF092866)),
                          ),
                          filled: true,
                          fillColor: isAnswerChecked[index] == true
                              ? (isAnswerCorrect[index] == true
                                  ? Colors.green[100]
                                  : Colors.red[100])
                              : Colors.white,
                          errorText: isAnswerChecked[index] == true &&
                                  isAnswerCorrect[index] == false
                              ? 'Incorrect Answer'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text("Back"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF092866),
                                    Color(0xFF205ED8),
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                onPressed: () {
                                  setDialogState(() {
                                    isAnswerCorrect[index] =
                                        _answerController.text.trim() ==
                                            bingoList[index].answer;
                                    isAnswerChecked[index] = true;
                                  });

                                  if (isAnswerCorrect[index] == true) {
                                    Navigator.of(context).pop();
                                    setState(() {});
                                    _checkBingoWin();
                                  }
                                },
                                child: const Text(
                                  "Submit",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: const [
              Text(
                "Bingo Game",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003366),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 14.0),
                child: Text(
                  "0 Point",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003366),
                  ),
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 5))
                  ],
                ),
                child: Column(
                  children: [
                    // Title "Bingo Game"
                    Container(
                      height: 60,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFF003366),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text("Bingo Quiz",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                        mainAxisExtent: 60,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: isAnswerCorrect[index] == true
                              ? null
                              : () {
                                  _showQuestionDialog(index);
                                  _checkAnswer(index);
                                },
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isAnswerCorrect[index] == true
                                      ? Colors.green[600]
                                      : Colors.blue[900],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: isAnswerCorrect[index] == true
                                    ? const SizedBox()
                                    : Text(
                                        "${bingoList[index].point}",
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                              if (isAnswerCorrect[index] == true)
                                Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Players must answer questions correctly to complete a row (vertical, horizontal, or diagonal) to win!",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isBingoWin
                    ? () {
                        _navigateToResults();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 205, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:
                      isBingoWin ? const Color(0xFFFFC107) : Colors.grey,
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF003366),
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
