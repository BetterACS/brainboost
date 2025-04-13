import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _theme = ThemeData.light();

  ThemeData get theme => _theme;
  bool get isDarkMode => _theme == ThemeData.dark();

  // Constructor to load saved theme
  ThemeProvider() {
    _loadSavedTheme();
  }

  // Load saved theme from SharedPreferences
  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? false;
    _theme = isDark ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }

  // Save theme preference
  Future<void> _saveThemePreference(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', isDark);
  }

  void toggleTheme() {
    final isDark = _theme == ThemeData.dark();
    if (isDark) {
      _theme = ThemeData.light();
    } else {
      _theme = ThemeData.dark();
    }
    _saveThemePreference(!isDark);
    notifyListeners();
  }
}
