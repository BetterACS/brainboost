import 'package:brainboost/screens/mygames.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:brainboost/component/colors.dart';

import 'package:file_picker/file_picker.dart';
import 'dart:async';

// หน้าสร้างเกมใหม่
class CreateGameScreen extends StatelessWidget {
  const CreateGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF5FF), // สีพื้นหลังหลักของแอป
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
  String? fileName; // ชื่อไฟล์
  bool isUploading = false; // เช็คสถานะอัพโหลด
  bool uploadSuccess = false; // เช็คอัพโหลดสำเร็จ

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name; // ชื่อไฟล์
        isUploading = true; // เริ่มอัพโหลด
      });

      // จำลองอัพไฟล์
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        isUploading = false;
        uploadSuccess = true; // อัพโหลดเสร็จ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF5FF),
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: AppColors.containerBackground),
          onPressed: () => Navigator.pop(context), // ปุ่มกลับ
        ),
        title: const Text(
          'Create game',
          style: TextStyle(color: AppColors.containerBackground),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: AppColors.containerBackground,
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
              const Center(
                child: Text(
                  'Upload your files',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Center(
                child: Text(
                  'File should be .pdf',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Game name',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Enter your game name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white70,
                    width: 2,
                  ),
                  color: Colors.transparent,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.white,
                      size: 88,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: pickFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Browse files',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                isUploading
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: const LinearProgressIndicator(
                          backgroundColor: Color(0xFFE9E9E9),
                          color: Colors.green,
                          minHeight: 10,
                        ),
                      )
                    : uploadSuccess
                        ? Row(
                            children: const [
                              Text(
                                "Upload complete!",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(Icons.check_circle, color: Colors.green),
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
                          return Colors.white;
                        }
                        return const Color(0xFFE5E5E5);
                      },
                    ),
                    foregroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (uploadSuccess) {
                          return AppColors.primaryBackground;
                        }
                        return const Color(0xFFABABAB);
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreatingDialog(),
    );

    // จำลองโหลด
    await Future.delayed(const Duration(seconds: 3));

    // เปลี่ยน True / false เอาไว้เทสว่าสำเร็จมั้ย
    // bool isSuccess = false;
    bool isSuccess = true;

    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (context) => isSuccess ? SuccessDialog() : ErrorDialog(),
    );
  }
}

// Pop-up creating
class CreatingDialog extends StatelessWidget {
  const CreatingDialog({super.key});

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
                const Text(
                  "Creating",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Please wait while we",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const Text(
                  "generate game for you!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xFFE9E9E9),
                    color: Colors.blue.shade800,
                    minHeight: 10,
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