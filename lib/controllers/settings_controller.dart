import 'package:flutter/material.dart';

class SettingsController extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale locale) {
    if (!['en', 'th'].contains(locale.languageCode)) return;
    _locale = locale;
    notifyListeners();
  }
}
