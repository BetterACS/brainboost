import 'package:brainboost/component/colors.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accentBackground, // Added background color
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(color: AppColors.textPrimary), // Added text color
        ),
        backgroundColor: AppColors.appBarBackground, // Added appBar background color
        leading: const BackButton(
          color: AppColors.textPrimary, // Added back button color
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is Settings Page', 
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary, // Added text color
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}