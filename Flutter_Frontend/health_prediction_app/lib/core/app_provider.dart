import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  String _language = 'en'; // 'en' = English, 'np' = Nepali

  String get language => _language;

  void setLanguage(String lang) {
    if (lang == 'en' || lang == 'np') {
      _language = lang;
      notifyListeners(); // Update UI everywhere
    }
  }

  // Helper to get text in current language
  String getText(String english, String nepali) {
    return _language == 'np' ? nepali : english;
  }
}