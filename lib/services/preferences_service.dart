import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _madhabKey = 'madhab';

  static Future<String> getMadhab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_madhabKey) ?? 'hanafi';
  }

  static Future<void> setMadhab(String madhab) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_madhabKey, madhab);
  }
}