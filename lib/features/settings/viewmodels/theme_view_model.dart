import 'package:flutter/material.dart';
import 'package:focus/features/settings/services/settings_service.dart';

/// Controla o tema atual da aplicação.
class ThemeViewModel extends ChangeNotifier {
  /// Serviço usado para persistir preferências locais.
  final SettingsService _service = SettingsService();

  /// Estado atual do modo escuro.
  bool _isDarkMode = false;

  /// Indica se o modo escuro está ativo.
  bool get isDarkMode => _isDarkMode;

  /// Carrega as preferências salvas ao iniciar o app.
  Future<void> loadSettings() async {
    _isDarkMode = await _service.loadTheme();
    notifyListeners();
  }

  /// Alterna o tema e salva a preferência imediatamente.
  Future<void> toggleTheme() async {
    await setDarkMode(!_isDarkMode);
  }

  /// Define o tema escuro com o valor recebido e persiste a preferência.
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners(); // Atualiza o app imediatamente.
    await _service.saveTheme(_isDarkMode);
  }
}
