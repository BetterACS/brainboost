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



class UploadFileScreen extends StatefulWidget {
  const UploadFileScreen({super.key});

  @override
  State<UploadFileScreen> createState() => _UploadFileScreenState();
}

class _UploadFileScreenState extends State<UploadFileScreen> {
  String? fileName; // เก็บชื่อไฟล์
  bool isUploading = false; // เช็คสถานะการอัพโหลด
  bool uploadSuccess = false; // เช็คว่าการอัพโหลดสำเร็จไหม

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        fileName = result.files.single.name; // ได้ชื่อไฟล์ที่เลือก
        isUploading = true; // เริ่มอัพโหลด
      });

      // จำลองการอัพโหลดไฟล์ (ใช้ Future.delayed แทน API จริง)
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        isUploading = false;
        uploadSuccess = true; // อัพโหลดสำเร็จ
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF5FF),
      appBar: AppBar(
        backgroundColor:  AppColors.appBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.containerBackground),
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
                  'File: $fileName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                isUploading
                    ? const LinearProgressIndicator(
                        backgroundColor: Colors.white30,
                        color: Colors.green,
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
                  onPressed: uploadSuccess ? () {} : null, // ปุ่มกดได้เมื่ออัพโหลดเสร็จ
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        uploadSuccess ? Colors.blue.shade900 : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
}
