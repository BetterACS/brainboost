import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:brainboost/models/games.dart';

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
                  const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text("Back"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                setDialogState(() {
                                  isAnswerCorrect[index] =
                                      _answerController.text.trim() ==
                                          bingoList[index].answer;
                                  isAnswerChecked[index] = true;
                                });

                                if (isAnswerCorrect[index] == true) {
                                  // ✅ ปิด Dialog ถ้าตอบถูก
                                  Navigator.of(context).pop();
                                  setState(() {});
                                }
                              },
                              child: const Text("Submit"),
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
        title: const Text("Bingo Game"),
        centerTitle: true,
      ),
      body: Center(
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
                        onTap: () => _showQuestionDialog(index),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${bingoList[index].point}",
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
                "Players must answer questions correctly to complete a row (vertical, horizontal, or diagonal) to win!"),
          ],
        ),
      ),
    );
  }
}
