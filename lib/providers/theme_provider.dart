
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class AppTheme {
  // Custom Colors - chosen for being easy on the eyes
  static const Color _lightPrimaryColor = Color(0xFF4A6572);
  static const Color _lightAccentColor = Color(0xFFF9AA33);
  static const Color _lightBackgroundColor = Color(0xFFF0F0F0);
  static const Color _lightTextColor = Color(0xFF344955);

  static const Color _darkPrimaryColor = Color(0xFF344955);
  static const Color _darkAccentColor = Color(0xFFF9AA33);
  static const Color _darkBackgroundColor = Color(0xFF232F34);
  static const Color _darkTextColor = Color(0xFFF0F0F0);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,
    textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme).apply(bodyColor: _lightTextColor),
    colorScheme: const ColorScheme.light(
      primary: _lightPrimaryColor,
      secondary: _lightAccentColor,
      background: _lightBackgroundColor,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightAccentColor,
      foregroundColor: _lightPrimaryColor,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme).apply(bodyColor: _darkTextColor),
    colorScheme: const ColorScheme.dark(
      primary: _darkPrimaryColor,
      secondary: _darkAccentColor,
      background: _darkBackgroundColor,
      onPrimary: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: Colors.white,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkAccentColor,
      foregroundColor: _darkPrimaryColor,
    ),
  );
}
