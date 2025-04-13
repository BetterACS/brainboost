import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:watch_it/watch_it.dart';

class LanguageNotifier extends ChangeNotifier {
  Locale _locale = const Locale('th');
  Locale get locale => _locale;

  LanguageNotifier() {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    try {
      final prefs = await GetIt.instance.getAsync<SharedPreferences>();
      final languageCode = prefs.getString('languageCode') ?? 'th';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      print('Error loading saved language: $e');
    }
  }

  set setLocale(Locale locale) {
    GetIt.instance.getAsync<SharedPreferences>().then((prefs) {
      prefs.setString('languageCode', locale.languageCode);
      _locale = locale;
      notifyListeners();
    });
  }
}
