import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:brainboost/component/colors.dart';

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

// หน้าอัพโหลดไฟล์
class UploadFileScreen extends StatelessWidget {
  const UploadFileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECF5FF),
      appBar: AppBar(
        backgroundColor: AppColors.appBarBackground,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.containerBackground),
          onPressed: () => Navigator.pop(context), // ปุ่มกลับ
        ),
        title: Text(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ส่วนหัวข้อและคำอธิบาย
                Center(
                  child: Text(
                    'Upload your files',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'File should be .pdf',
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // ส่วนกรอกชื่อเกม
                Text(
                  'Game name',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Enter your game name',
                      hintStyle: TextStyle(
                        color: AppColors.containerBackground.withOpacity(0.5),
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
                  ),
                ),
                const SizedBox(height: 24),
                // พื้นที่สำหรับอัพโหลดไฟล์
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ไอคอนอัพโหลด
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.white.withOpacity(0.2),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            color: AppColors.white,
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // ปุ่มเลือกไฟล์
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.buttonBackground,
                            foregroundColor: AppColors.buttonForeground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
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
                ),
                const SizedBox(height: 24),
                // ปุ่มสร้างเกม
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFABABAB),
                      foregroundColor: const Color(0xFFE5E5E5),
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
      ),
      // bottomNavigationBar: const Navbar(),
    );
  }
}
