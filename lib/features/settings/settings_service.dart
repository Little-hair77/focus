import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeKey = 'isDarkMode';
  static const String _sortKey = 'sortOrder';

  Future<void> saveTheme(bool isDarkMode) async  {
    final prefs = await SheredPreferences.getInstance();
    await 
  }
}