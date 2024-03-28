import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum ThemeModeType { dark, light }

class ThemeProvider with ChangeNotifier {
  ThemeData lightTheme = ThemeData(
    primaryColor: lightThemeColor,
  );

  ThemeData darkTheme = ThemeData(
    primaryColor: darkThemeColor,
  );

  ThemeData _themeData = ThemeData.light(); // Default to light theme
  ThemeModeType _currentTheme = ThemeModeType.light;

  ThemeModeType get currentTheme => _currentTheme;
  ThemeData get themeData => _themeData;

  void toggleTheme() {
    _currentTheme = _currentTheme == ThemeModeType.light
        ? ThemeModeType.dark
        : ThemeModeType.light;
    _themeData = _currentTheme == ThemeModeType.light
        ? ThemeData.light()
        : ThemeData.dark();
    notifyListeners();
  }

  bool isLightTheme() {
    return _currentTheme == ThemeModeType.light;
  }
}
