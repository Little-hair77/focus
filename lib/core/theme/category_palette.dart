import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';

class CategoryPalette {
  static const fallback = '#6366F1';

  static const colors = [
    fallback,
    '#059669',
    '#D97706',
    '#DC2626',
    '#DB2777',
    '#0891B2',
  ];

  static Color parse(String value) {
    final hex = int.tryParse(value.replaceFirst('#', ''), radix: 16);
    return Color(hex == null ? AppColors.info.toARGB32() : 0xFF000000 | hex);
  }
}
