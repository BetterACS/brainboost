import 'package:flutter/material.dart';

class GameBingoPage extends StatefulWidget {
  const GameBingoPage({Key? key}) : super(key: key);

  @override
  _GameBingoPageState createState() => _GameBingoPageState();
}

class _GameBingoPageState extends State<GameBingoPage> {
  List<int> numbers = [10, 25, 30, 15, 15, 25, 20, 10, 15];

  final TextEditingController _answerController = TextEditingController();

  // สร้าง Map เพื่อเก็บสถานะของแต่ละหมายเลข
  Map<int, bool> isAnswerCorrect = {};
  Map<int, bool> isAnswerChecked = {};

  void _showQuestionDialog(int number) {
    _answerController.clear(); // รีเซ็ตค่าตอบก่อนแสดงคำถาม
    setState(() {
      isAnswerChecked[number] = false; // รีเซ็ตการตรวจสอบคำตอบของช่องนี้
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
                  border: Border.all(
                    color: Colors.blue[900]!,
                  ),
                ),
                child: Text(
                  "$number Points",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "ภายหลังสงครามโลกครั้งที่ 2 ผู้นำฝ่ายโลกคอมมิวนิสต์ขยายอิทธิพลและการแทรกแซงการปกครองในดินแดนส่วนต่างๆ ของโลกหลายแห่งข้อนี้ข้อใด",
                    textAlign: TextAlign.center,
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
                          fillColor: isAnswerChecked[number] == true
                              ? (isAnswerCorrect[number] == true
                                  ? Colors.green[100] // สีเขียวถ้าถูก
                                  : Colors.red[100]) // สีแดงถ้าผิด
                              : Colors.white,
                          errorText: isAnswerChecked[number] == true &&
                                  isAnswerCorrect[number] == false
                              ? 'Incorrect Answer'
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const SizedBox(height: 24), // เพิ่มช่องว่างให้กว้างขึ้น
                      Padding(
                        padding:
                            const EdgeInsets.all(2.0), // ปรับให้เท่ากับช่องกรอก
                        child: Row(
                          children: [
                            Expanded(
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: Colors.grey[400]!, width: 2),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(
                                    "Back",
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF205ED8),
                                      Color(0xFF092866)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    setDialogState(() {
                                      isAnswerCorrect[number] =
                                          _answerController.text.trim() ==
                                              'correct_answer';
                                      isAnswerChecked[number] = true;
                                    });
                                  },
                                  child: Text(
                                    isAnswerChecked[number] == true
                                        ? (isAnswerCorrect[number] == true
                                            ? 'Correct'
                                            : 'Try Again')
                                        : 'Submit',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
            top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
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
                      childAspectRatio: 1, // ยังคงอัตราส่วนเป็น 1:1
                      mainAxisExtent: 60, // กำหนดความสูงให้ 89
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => _showQuestionDialog(numbers[index]),
                        child: SizedBox(
                          width: 60,
                          height: 60,
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
