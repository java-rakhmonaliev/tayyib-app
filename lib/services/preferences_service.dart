import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _madhabKey = 'madhab';
  static const String _themeModeKey = 'theme_mode';

  static Future<String> getMadhab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_madhabKey) ?? 'hanafi';
  }

  static Future<void> setMadhab(String madhab) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_madhabKey, madhab);
  }

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_themeModeKey);
    switch (val) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case ThemeMode.light:
        await prefs.setString(_themeModeKey, 'light');
        break;
      case ThemeMode.dark:
        await prefs.setString(_themeModeKey, 'dark');
        break;
      case ThemeMode.system:
        await prefs.setString(_themeModeKey, 'system');
        break;
    }
  }
}
