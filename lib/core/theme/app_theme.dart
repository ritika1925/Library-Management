import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2F4F3A);
  static const Color background = Color(0xFFF8F2E8);
  static const Color accent = Color(0xFFC8A15A);
  static const Color text = Color(0xFF3B3024);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ),
  );
}