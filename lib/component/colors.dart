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
  static const Color cardBackground = Color.fromARGB(255, 17, 51, 121);
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
  static const Color mainColor = Color.fromRGBO(236, 245, 255, 1.0);
  static const Color gray4 = Color.fromRGBO(225, 228, 232, 1.0);
  static const Color gray5 = Color(0xFF888888);

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

  // Quiz button colors.
  static const Color borderQuizOption = Color.fromARGB(255, 201, 201, 201);
  static const Color borderQuizSelectedOption = Colors.blue;
  static const Color borderQuizCorrectOption = Colors.green;
  static const Color borderQuizIncorrectOption = Colors.red;
  static const Color borderQuizNonSelectedOption = Color.fromARGB(255, 201, 201, 201);

  static const Color backgroundQuizOption = Colors.white;
  static const Color backgroundQuizSelectedOption = Color(0xFFE4F4FF);
  static const Color backgroundQuizCorrectOption = Color(0xFFDCFFCF);
  static const Color backgroundQuizIncorrectOption = Color(0xFFFF9EA0);
  static const Color backgroundQuizNonSelectedOption = Colors.white;

  static const Color textQuizOption = Colors.black87;
  static const Color textQuizSelectedOption = Colors.blue;
  static const Color textQuizCorrectOption = Color(0xFF229749);
  static const Color textQuizIncorrectOption = Color(0xFFCF1717);
  static const Color textQuizNonSelectedOption = Colors.black87;

  // Games Screen components
  static const Color gameScreenBackground = Color(0xFFF0F7FF);
  static const Color progressBar = Color(0xFFE9E9E9);
}
