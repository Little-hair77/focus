import 'package:flutter/material.dart';

class AppTheme {
  // Cor static do app
  static const Color primaryPurple = Colors.deepPurple;
  static const Color accentPurple =  Color(0xFF8E24AA);

  static ThemeData get lightTheme{
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorSchemeSeed: primaryPurple,
      scaffoldBackgroundColor: const Color(0xFFF8F9FE),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: primaryPurple),
      )
    );
  }

  static ThemeData get darkTheme{
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorSchemeSeed: primaryPurple,
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      )
    );
  }
}