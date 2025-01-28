// lib/component/cards/profile.dart

import 'package:flutter/material.dart';
import 'package:brainboost/component/colors.dart';

// Widget หลัก
class ProfileContainer extends StatelessWidget {
  const ProfileContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(50),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 22,
              backgroundImage:
                  AssetImage('assets/images/profile.jpg'),
            ),
          ),
          SizedBox(width: 10),
          Text(
            "Mon Chinawat",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// เพิ่ม main function สำหรับทดสอบ
void main() {
  runApp(const MaterialApp(
    home: Scaffold(
      backgroundColor: Color(0xFF1A1A1A), // พื้นหลังสีเข้มเพื่อให้เห็น widget ชัดเจน
      body: Center(
        child: ProfileContainer(),
      ),
    ),
  ));
}