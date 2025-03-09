import 'package:flutter/material.dart';

class GameBingoPage extends StatefulWidget {
  const GameBingoPage({Key? key}) : super(key: key);

  @override
  _GameBingoPageState createState() => _GameBingoPageState();
}

class _GameBingoPageState extends State<GameBingoPage> {
  List<int> numbers = [10, 25, 30, 15, 15, 25, 20, 10, 15];
  final TextEditingController _answerController = TextEditingController();
  bool _isAnswerCorrect = false;
  bool _isAnswerChecked = false;

  void _showQuestionDialog(int number) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor:
              Colors.white, // Set background color of the entire dialog
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(
                  0xFF092866), // Set background of the title to blue
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    Colors.blue[900]!, // Optional border for the title section
              ),
            ),
            child: Text(
              "$number Points",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set the text color to white for contrast
              ),
              textAlign: TextAlign.center,
            ),
          ),

          content: Container(
            color: Colors.white, // Set background color of the content to white
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "ภายหลังสงครามโลกครั้งที่ 2 ผู้นำฝ่ายโลกคอมมิวนิสต์ขยายอิทธิพลและการแทรกแซงการปกครองในดินแดนส่วนต่างๆ ของโลกหลายแห่งข้อนี้ข้อใด",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _answerController,
                  decoration: InputDecoration(
                    hintText: "Answer",
                    hintStyle: TextStyle(color: Color(0xFFC2C2C2)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF092866)),
                    ),
                    fillColor: _isAnswerChecked
                        ? (_isAnswerCorrect
                            ? Colors
                                .green[100] // Correct answer, green background
                            : Colors
                                .red[100]) // Incorrect answer, red background
                        : Colors
                            .white, // Default background when the answer is not checked
                    filled: true,
                    errorText: _isAnswerChecked && !_isAnswerCorrect
                        ? 'Incorrect Answer'
                        : null,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("Back"),
                ),
                const SizedBox(width: 16),
                Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF092866), Color(0xFF205ED8)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        // Replace with the actual correct answer
                        _isAnswerCorrect =
                            _answerController.text.trim() == 'correct_answer';
                        _isAnswerChecked = true;
                      });
                    },
                    child: Text(
                      _isAnswerChecked
                          ? _isAnswerCorrect
                              ? 'Correct'
                              : 'Try Again'
                          : 'Submit',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("สงครามโลกครั้งที่ล้าน"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(
            top: 32.0, left: 16.0, right: 16.0, bottom: 16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.blueAccent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            const Text(
              "0",
              style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const Text(
              "Points",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
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
                      child: Text(
                        "Bingo Quiz",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
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
                            childAspectRatio: 1),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showQuestionDialog(numbers[index]),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue[900],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "${numbers[index]}",
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
              "Players must answer questions correctly to complete one row \n(vertical, horizontal, or diagonal) to win!",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF003366)),
            ),
          ],
        ),
      ),
    );
  }
}
