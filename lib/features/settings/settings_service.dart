import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Chaves constantes para evitar erros de digitação [cite: 104]
  static const String _themeKey = 'isDarkMode';
  static const String _sortKey = 'sortOrder';

  // Salvar o tema (booleano) [cite: 104]
  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // Ler o tema [cite: 104, 105]
  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Retorna false (Light) por padrão [cite: 104]
  }

  // Salvar ordenação (String) [cite: 104]
  Future<void> saveSortOrder(String order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortKey, order);
  }

  // Ler ordenação [cite: 104]
  Future<String> loadSortOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sortKey) ?? 'dueDate'; // Padrão definido no seu Sprint 1 [cite: 104]
  }
}