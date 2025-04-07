import 'package:brainboost/screens/mygames.dart';
import 'package:brainboost/services/history.dart';
import 'package:brainboost/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:brainboost/component/colors.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:brainboost/services/games.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Add at the top of the file
enum CreationStage { extracting, personalizing, crafting, completed }

ValueNotifier<String> dialogMessage = ValueNotifier<String>("");
ValueNotifier<double> creationProgress = ValueNotifier<double>(0.0);
ValueNotifier<CreationStage> currentStage =
    ValueNotifier<CreationStage>(CreationStage.extracting);

// หน้าสร้างเกมใหม่
class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF5FF), 
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        toolbarHeight: 60,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const ProfileSection(), // แสดงโปรไฟล์ผู้ใช้
          const SizedBox(height: 30),
          const MainContent(), // แสดงส่วนสร้างเกมใหม่
        ],
      ),
    );
  }
}

// แสดงโปรไฟล์ผู้ใช้
class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(50), // ทำให้กรอบมีมุมมน
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min, // ให้ความกว้างพอดีกับเนื้อหา
          children: [
            // รูปโปรไฟล์แบบวงกลมซ้อนกัน
            CircleAvatar(
              radius: 25,
              backgroundColor: AppColors.white, // สีขอบนอก
              child: CircleAvatar(
                radius: 22,
                backgroundImage: AssetImage('assets/images/profile.jpg'),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Mon Chinawat",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ส่วนเนื้อหาสร้างเกมใหม่
class MainContent extends StatelessWidget {
  const MainContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const Text(
            "Create New Game",
            style: TextStyle(
              color: AppColors.primaryBackground,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          const UploadCircleButton(), // ปุ่มวงกลมสำหรับอัพโหลด
          const SizedBox(height: 20),
          const Text(
            "Learn more about Lecture?",
            style: TextStyle(
              color: AppColors.primaryBackground,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          // ปุ่มสร้าง Summary พร้อมไอคอน
          ElevatedButton(
            onPressed: () {
              // นำทางไปยังหน้า UploadFileScreen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UploadFileScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBackground,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ไอคอนเกม
                SvgPicture.asset(
                  'assets/images/game.svg',
                  width: 24,
                  height: 24,
                  color: AppColors.white,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Create Summary',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ปุ่มวงกลมสำหรับอัพโหลดพร้อมเครื่องหมายบวก
class UploadCircleButton extends StatelessWidget {
  const UploadCircleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // เมื่อกดจะนำทางไปยังหน้า UploadFileScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UploadFileScreen(),
          ),
        );
      },
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryBackground,
            width: 3,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            size: 50,
            color: AppColors.primaryBackground,
          ),
        ),
      ),
    );
  }
}

//ส่วนอัพไฟล์
class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  late TextEditingController _gameNameTextController;

  PlatformFile? pickedFile; // ไฟล์ที่เลือก
  String? fileName; // ชื่อไฟล์
  String? uploadLink;

  double progress = 0.0;

  bool isUploading = false; // เช็คสถานะอัพโหลด
  bool uploadSuccess = false; // เช็คอัพโหลดสำเร็จ

  @override
  void initState() {
    super.initState();
    _gameNameTextController = TextEditingController();
  }

  @override
  void dispose() {
    _gameNameTextController.dispose();
    super.dispose();
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result == null) {
      return;
    }

    setState(() {
      fileName = result.files.single.name; // ชื่อไฟล์
      pickedFile = result.files.first; // ไฟล์ที่เลือก
      uploadSuccess = false; // อัพโหลดไม่สำเร็จ
      isUploading = true; // เริ่มอัพโหลด
      uploadLink = null; // ลิ้งค์อัพโหลด
      progress = 0.0; // ความคืบหน้า
      // uploadSuccess = true;
    });

    await uploadFile();

    // // จำลองอัพไฟล์
    // await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isUploading = false;
      uploadSuccess = true; // อัพโหลดเสร็จ
    });
  }

  Future uploadFile() async {
    final path = 'files/${pickedFile!.name}';

    try {
      final ref = FirebaseStorage.instance.ref().child(path);

      // Progress
      final uploadTask = ref.putData(pickedFile!.bytes!);
      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          progress = event.bytesTransferred / event.totalBytes;
        });
        print("Upload Progress: $progress");
      });

      // Wait for the upload task to complete
      await uploadTask;
      final urlDownload = await uploadTask.snapshot.ref.getDownloadURL();
      // final urlDownload = await uploadTask.snapshot.ref.getDownloadURL();
      print("Download-Link: $urlDownload");
      setState(() {
        uploadLink = urlDownload;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.backgroundDarkmode : const Color(0xFFECF5FF),
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey[900] : AppColors.appBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : AppColors.containerBackground,
          ),
          onPressed: () => Navigator.pop(context), // ปุ่มกลับ
        ),
        title: Text(
          'Create game',
          style: TextStyle(
            color: isDarkMode ? Colors.white : AppColors.containerBackground,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.accentDarkmode2 : AppColors.containerBackground,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Upload your files',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: Text(
                  'File should be .pdf',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Game name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _gameNameTextController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                  hintText: 'Enter your game name',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  color: isDarkMode ? Colors.grey[800] : Colors.transparent,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.white,
                      size: 88,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: pickFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.grey[700] : Colors.white,
                        foregroundColor: isDarkMode ? Colors.white : Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Browse files',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (fileName != null) ...[
                Text(
                  '$fileName',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                isUploading
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          backgroundColor: isDarkMode ? Colors.grey[700] : const Color(0xFFE9E9E9),
                          color: Colors.green,
                          minHeight: 10,
                          value: progress,
                        ),
                      )
                    : uploadSuccess
                        ? Row(
                            children: [
                              Text(
                                "Upload complete!",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Icon(Icons.check_circle, color: Colors.green),
                            ],
                          )
                        : Container(),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: uploadSuccess ? () => createGame(context) : null,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (uploadSuccess) {
                          return isDarkMode ? Colors.green : Colors.white;
                        }
                        return isDarkMode ? Colors.grey[700]! : const Color(0xFFE5E5E5);
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (uploadSuccess) {
                          return isDarkMode ? Colors.white : AppColors.primaryBackground;
                        }
                        return isDarkMode ? Colors.white70 : const Color(0xFFABABAB);
                      },
                    ),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16),
                    ),
                    shape: MaterialStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void createGame(BuildContext context) async {
    dialogMessage.value = "";
    creationProgress.value = 0.0;
    currentStage.value = CreationStage.extracting;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreatingDialog(),
    );

    var httpClient = http.Client();
    dialogMessage.value = "Extract valuable information from the file";
    creationProgress.value = 0.25;

    var extractResponse = await httpClient
        .get(Uri.https('monsh.xyz', '/extract', {'pdf_path': uploadLink}));

    currentStage.value = CreationStage.personalizing;
    dialogMessage.value = "Get your personalize";
    creationProgress.value = 0.32;

    String? email = FirebaseAuth.instance.currentUser!.email;
    if (email == null) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(),
      );
      return;
    }

    String personalize = await UserServices().getPersonalize(email: email);

    // Assuming you have already decoded the response bytes as a string:
    var decodedResponse = utf8.decode(extractResponse.bodyBytes);
    print(decodedResponse);
    // Convert the JSON string into a Dart map (dictionary)
    Map<String, dynamic> jsonDict = jsonDecode(decodedResponse);

    currentStage.value = CreationStage.crafting;
    dialogMessage.value = "Crafting your game";
    Map<String, String> params = {
      "game_type": 'quiz',
      "context": jsonDict['data'],
      "personalize": personalize,
      "language": "Thai and English upon to context.",
      "num_games": "3",
    };

    var createGameResponse = await httpClient.post(
      Uri.https('monsh.xyz', '/create_game'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(params),
    );

    creationProgress.value = 0.80;
    print("Create Game!");

    // Convert the JSON string into a Dart map (dictionary)
    var gameDict = jsonDecode(utf8.decode(createGameResponse.bodyBytes));

    GameServices gamesServices = await GameServices();

    final DocumentReference<Object?>? gameID = await gamesServices.createGame(
        name: _gameNameTextController.text,
        email: FirebaseAuth.instance.currentUser!.email!,
        gameData: gameDict['data'] as List<dynamic>,
        media: uploadLink!);

    if (gameID == null) {
      showDialog(
        context: context,
        builder: (context) => const ErrorDialog(),
      );
      return;
    }
    await gamesServices.addGameToUser(
        email: FirebaseAuth.instance.currentUser!.email!, docPath: gameID);

    GameHistoryService gameHistoryService = GameHistoryService();
    await gameHistoryService.addGameHistory(
        email: email, gameId: gameID, gameName: _gameNameTextController.text);

    // await uploadFile();
    // จำลองโหลด
    // await Future.delayed(const Duration(seconds: 3));

    // เปลี่ยน True / false เอาไว้เทสว่าสำเร็จมั้ย
    // bool isSuccess = false;
    bool isSuccess = true;

    currentStage.value = CreationStage.completed;
    creationProgress.value = 1.0;

    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => isSuccess ? SuccessDialog() : ErrorDialog(),
    );

    setState(() {
      uploadLink = null;
    });
  }
}

// Pop-up creating
class CreatingDialog extends StatefulWidget {
  const CreatingDialog({super.key});

  @override
  _CreatingDialogState createState() => _CreatingDialogState();
}

class _CreatingDialogState extends State<CreatingDialog> {
  @override
  void initState() {
    super.initState();
    dialogMessage.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild dialog when message changes
      }
    });
    creationProgress.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    dialogMessage.removeListener(() {}); // Avoid memory leaks
    creationProgress.removeListener(() {});
    super.dispose();
  }

  double getProgressForStage(CreationStage stage) {
    switch (stage) {
      case CreationStage.extracting:
        return 0.33;
      case CreationStage.personalizing:
        return 0.66;
      case CreationStage.crafting:
        return 0.99;
      case CreationStage.completed:
        return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      bottom: -15,
                      child: Container(
                        width: 200,
                        height: 160,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E9E9),
                          borderRadius: BorderRadius.circular(80),
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/images/file.png',
                        width: 200,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Text(
                  dialogMessage.value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFE9E9E9),
                    color: Colors.blue.shade800,
                    minHeight: 10,
                    value: creationProgress.value,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF838383)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadFileScreen()),
                );
              },
              tooltip: 'Close',
            ),
          ),
        ],
      ),
    );
  }
}

// Pop-up success

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // วงกลมใหญ่สุด
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFF20BF4D).withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // วงกลมกลาง
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFF20BF4D).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // วงกลมเล็กสุด
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFF20BF4D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 48),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Success!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Your game has been created successfully",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 28),
                // ปุ่ม Start Playing
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyGames()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF20BF4D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Start Playing",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // ปุ่ม View My Games
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyGames()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF20BF4D),
                      side: const BorderSide(color: Color(0xFF20BF4D)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "View My Games",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ปุ่มปิด
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF838383)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadFileScreen()),
                );
              },
              tooltip: 'Close',
            ),
          ),
        ],
      ),
    );
  }
}

// Pop-up error

class ErrorDialog extends StatelessWidget {
  const ErrorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // วงกลมใหญ่สุด
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE04545).withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // วงกลมกลาง
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE04545).withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // วงกลมเล็กสุด
                    Container(
                      width: 90,
                      height: 90,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE04545),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 48),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Text(
                  "Oops!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  "Something went wrong\nPlease try again or upload a new file.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const CreatingDialog(),
                      );

                      Future.delayed(const Duration(seconds: 3), () {
                        Navigator.pop(context);
                        showDialog(
                          context: context,
                          builder: (context) => SuccessDialog(),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Try Again",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UploadFileScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text("Edit File",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
          // ปุ่มปิด
          Positioned(
            top: 8,
            right: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Color(0xFF838383)),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UploadFileScreen()),
                );
              },
              tooltip: 'Close',
            ),
          ),
        ],
      ),
    );
  }
}
