import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF007BFF);
  static const Color secondary = Color(0xFF6C757D);
  static const Color success = Color(0xFF28A745);
  static const Color danger = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF17A2B8);
  static const Color light = Color(0xFFF8F9FA);
  static const Color dark = Color(0xFF343A40);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color _lightBackground = Color(0xFFF2F2F2);
  static const Color _darkBackground = Color(0xFF121212);

  static const Color _lightText = Color(0xFF343A40);
  static const Color _darkText = Color(0xFFF8F9FA);

  static const Color accent = primary;

  static Color background(Brightness brightness) =>
      brightness == Brightness.light ? _lightBackground : _darkBackground;

  static Color textColor(Brightness brightness) =>
      brightness == Brightness.light ? _lightText : _darkText;
}