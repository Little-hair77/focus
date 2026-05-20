import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  // Chaves constantes para evitar erros de digitação 
  static const String _themeKey = 'isDarkMode';
  static const String _sortKey = 'sortOrder';

  // Salvar o tema (booleano) 
  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  // Ler o tema 
  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // Retorna false (Light) por padrão 
  }

  // Salvar ordenação (String) 
  Future<void> saveSortOrder(String order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortKey, order);
  }

  // Ler ordenação 
  Future<String> loadSortOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sortKey) ?? 'dueDate'; 
  }
}