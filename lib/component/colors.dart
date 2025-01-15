import 'package:flutter/material.dart';

class AppColors {
  // Original colors
  static const Color primaryBackground = Color(0xFF1746A2);
  static const Color accentBackground = Color(0xFFECF5FF);
  static const Color neutralBackground = Color(0xFF205ED8);
  static const Color appBarBackground = Colors.transparent;
  static const Color containerBackground = Color(0xFF002654);
  static const Color white = Colors.white;
  static const Color buttonBackground = Colors.white;
  static const Color buttonForeground = Color(0xFF1F6DAC);
  static const Color buttonBorder = Color(0xFF0C375A);
  static const Color textPrimary = Colors.white;
  static const Color cardBackground = Color(0xFF003366);
  static const Color buttonText = Color(0xFF003366);
  static const Color activeColor = Color.fromARGB(255, 18, 112, 194);
  static const Color inactiveColor = Color.fromARGB(255, 14, 53, 87);
  static const Color errorIcon = Colors.red;
  static const Color unselectedTab = Color(0xFFB0B8C5);
  static const Color gradient1 = Color(0xFF092866);
  static const Color gradient2 = Color(0xFF205ED8);
  static const Color gray = Color(0xFFD9D9D9);
  static const Color gray2 = Color(0xFFAAAAAA);
  static const Color gray3 = Color(0xFFC2C2C2);
  static const Color backgroundDarkmode = Color(0xFF262626);
  static const Color accentDarkmode = Color(0xFF1F1F21);

  static const LinearGradient circleGradient = LinearGradient(
    colors: [
      gradient1,
      gradient2,
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [
      gradient1,
      gradient2,
    ],
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
  );
  // Additional colors from the CreateGameScreen
  static const Color screenBackground = Color(0xFFECF5FF);
  static const Color createButtonBackground = Color(0xFFABABAB);
  static const Color createButtonForeground = Color(0xFFE5E5E5);
}
