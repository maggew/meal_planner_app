import 'dart:convert';

import 'package:meal_planner/core/constants/local_keys.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  const LocalStorageService();

  // ------ Group ------
  Future<void> saveActiveGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LocalKeys.activeGroupId, groupId);
  }

  Future<String?> loadActiveGroup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(LocalKeys.activeGroupId);
  }

  Future<void> clearActiveGroup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalKeys.activeGroupId);
  }

  // ------ User Settings ------
  Future<void> saveUserSettings(UserSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        LocalKeys.userSettings, jsonEncode(settings.toJson()));
  }

  Future<UserSettings> loadUserSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(LocalKeys.userSettings);
    if (value == null) return UserSettings.defaultSettings;
    return UserSettings.fromJson(jsonDecode(value));
  }
}
