import 'package:flutter/material.dart';
import 'package:focus/features/settings/services/settings_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final SettingsService _service = SettingsService();
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  // Chamado ao iniciar o app 
  Future<void> loadSettings() async {
    _isDarkMode = await _service.loadTheme();
    notifyListeners();
  }

  // Alterna o tema e salva imediatamente 
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _service.saveTheme(_isDarkMode);
    notifyListeners(); // Notifica o app inteiro para mudar a cor
  }
}