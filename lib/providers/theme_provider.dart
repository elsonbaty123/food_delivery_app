import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // You can add more theme-related methods here
  // For example, to save/load theme preference
  Future<void> loadThemePreference() async {
    // TODO: Load theme preference from shared preferences
    notifyListeners();
  }

  Future<void> saveThemePreference() async {
    // TODO: Save theme preference to shared preferences
  }
}
