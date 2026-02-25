import 'dart:convert';

import 'package:meal_planner/core/constants/local_keys.dart';
import 'package:meal_planner/domain/entities/group.dart';
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

  // ------ Supabase User ID ------
  Future<void> saveSupabaseUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LocalKeys.supabaseUserId, userId);
  }

  Future<String?> loadSupabaseUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(LocalKeys.supabaseUserId);
  }

  // ------ Cached Group ------
  Future<void> saveGroup(Group group) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(LocalKeys.cachedGroup, jsonEncode({
      'id': group.id,
      'name': group.name,
      'imageUrl': group.imageUrl,
    }));
  }

  Future<Group?> loadGroup() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(LocalKeys.cachedGroup);
    if (value == null) return null;
    final map = jsonDecode(value) as Map<String, dynamic>;
    return Group(
      id: map['id'] as String,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
    );
  }

  Future<void> clearGroup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(LocalKeys.cachedGroup);
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
