import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.lightSurface,
        inverseSurface: AppColors.darkSurface,
      ),

      scaffoldBackgroundColor: AppColors.lightBackground,
      cardTheme: _cardTheme(AppColors.lightSurface),
      inputDecorationTheme: _inputDecorationTheme(AppColors.primary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: AppColors.primary,
        ), // Segue o token principal
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        secondary: AppColors.secondary,
        surface: AppColors.darkSurface,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: _cardTheme(AppColors.darkSurface),
      inputDecorationTheme: _inputDecorationTheme(AppColors.darkPrimary),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.onPrimary),
      ),
    );
  }

  static CardThemeData _cardTheme(Color color) {
    return CardThemeData(
      color: color,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Color primary) {
    final borderRadius = BorderRadius.circular(16);
    return InputDecorationTheme(
      filled: true,
      fillColor: primary.withValues(alpha: 0.05),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      floatingLabelStyle: TextStyle(
        color: primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
