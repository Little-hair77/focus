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
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary), // Segue o token principal
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
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.onPrimary),
      ),
    );
  }
}