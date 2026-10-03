import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsService {
  static const String _key = 'clock_settings';

  static Future<ClockSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null) return ClockSettings();
    try {
      final map = jsonDecode(jsonString) as Map<String, dynamic>;
      return ClockSettings.fromMap(map);
    } catch (_) {
      return ClockSettings();
    }
  }

  static Future<void> saveSettings(ClockSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toMap()));
  }
}
