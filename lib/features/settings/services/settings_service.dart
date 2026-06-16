import 'package:shared_preferences/shared_preferences.dart';

/// Persiste preferências simples do usuário no armazenamento local.
class SettingsService {
  /// Chave usada para armazenar a preferência de tema.
  static const String _themeKey = 'isDarkMode';

  /// Chave usada para armazenar a ordenação preferida.
  static const String _sortKey = 'sortOrder';

  /// Salva a preferência de tema.
  Future<void> saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDarkMode);
  }

  /// Carrega a preferência de tema.
  Future<bool> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getBool(_themeKey) ??
        false; // Retorna false (Light) por padrão
  }

  /// Salva a ordenação preferida.
  Future<void> saveSortOrder(String order) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sortKey, order);
  }

  /// Carrega a ordenação preferida.
  Future<String> loadSortOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sortKey) ?? 'dueDate';
  }
}
