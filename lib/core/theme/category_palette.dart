import 'package:flutter/material.dart';
import 'package:focus/core/theme/app_colors.dart';

/// Paleta fixa para seleção e renderização das categorias.
class CategoryPalette {
  /// Cor usada quando uma categoria não tem cor válida.
  static const fallback = '#6366F1';

  /// Cores disponíveis no seletor de categoria.
  static const colors = [
    fallback,
    '#059669',
    '#D97706',
    '#DC2626',
    '#DB2777',
    '#0891B2',
  ];

  /// Converte uma cor hexadecimal salva no banco para [Color].
  static Color parse(String value) {
    final hex = int.tryParse(value.replaceFirst('#', ''), radix: 16);
    return Color(hex == null ? AppColors.info.toARGB32() : 0xFF000000 | hex);
  }
}
