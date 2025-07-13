import 'package:flutter/material.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('ar', 'SA');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (_locale.languageCode != newLocale.languageCode) {
      _locale = newLocale;
      notifyListeners();
    }
  }

  // Toggle between Arabic and English
  void toggleLocale() {
    _locale = _locale.languageCode == 'ar' 
        ? const Locale('en', 'US')
        : const Locale('ar', 'SA');
    notifyListeners();
  }

  // Load saved locale preference
  Future<void> loadLocalePreference() async {
    // TODO: Load locale preference from shared preferences
    notifyListeners();
  }

  // Save locale preference
  Future<void> saveLocalePreference() async {
    // TODO: Save locale preference to shared preferences
  }
}
