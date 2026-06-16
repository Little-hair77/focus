import 'package:flutter/material.dart';

/// Centraliza as cores base usadas pelo tema e pelos componentes compartilhados.
class AppColors {
  /// Cor principal da marca no tema claro.
  static const Color primary = Color(0xFF6D28D9);

  /// Cor principal da marca no tema escuro.
  static const Color darkPrimary = Color(0xFF6D28D9);

  /// Cor secundária usada em gradientes e destaques.
  static const Color secondary = Color(0xFF8E24AA);

  /// Fundo padrão do tema claro.
  static const Color lightBackground = Color(0xFFF8F9FE);

  /// Fundo padrão do tema escuro.
  static const Color darkBackground = Color(0xFF121212);

  /// Superfície padrão do tema claro.
  static const Color lightSurface = Colors.white;

  /// Superfície padrão do tema escuro.
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Cor de texto e ícones sobre fundos primários.
  static const Color onPrimary = Colors.white;

  /// Texto de maior ênfase no tema claro.
  static const Color textHighEmphasis = Colors.black87;

  /// Texto de maior ênfase no tema escuro.
  static const Color darkTextHighEmphasis = Color(0xFFEDE7F6);

  /// Texto secundário no tema claro.
  static const Color textMediumEmphasis = Color(0xFF757575);

  /// Texto secundário no tema escuro.
  static const Color darkTextMediumEmphasis = Color(0xFFB8AEC9);

  /// Texto discreto usado em estados vazios e legendas.
  static const Color textMuted = Colors.grey;

  /// Cor informativa para indicadores e cards.
  static const Color info = Color(0xFF4F46E5);

  /// Variação informativa para tema escuro.
  static const Color darkInfo = Color(0xFF818CF8);

  /// Cor de sucesso para estados concluídos.
  static const Color success = Color(0xFF059669);

  /// Variação de sucesso para tema escuro.
  static const Color darkSuccess = Color(0xFF34D399);

  /// Cor de alerta para prioridade ou atenção.
  static const Color warning = Color(0xFFD97706);

  /// Variação de alerta para tema escuro.
  static const Color darkWarning = Color(0xFFFBBF24);

  /// Cor de perigo para erros ou atrasos.
  static const Color danger = Color(0xFFDC2626);

  /// Variação de perigo para tema escuro.
  static const Color darkDanger = Color(0xFFF87171);

  /// Cor base usada em sombras.
  static const Color shadow = Colors.black;

  /// Atalho semântico para transparência total.
  static const Color transparent = Colors.transparent;
}
