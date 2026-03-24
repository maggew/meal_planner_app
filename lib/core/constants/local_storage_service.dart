import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meal_planner/core/constants/local_keys.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  const LocalStorageService();

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ------ Group (secure) ------
  Future<void> saveActiveGroup(String groupId) async {
    await _secure.write(key: LocalKeys.activeGroupId, value: groupId);
  }

  Future<String?> loadActiveGroup() async {
    var value = await _secure.read(key: LocalKeys.activeGroupId);
    if (value == null) {
      // One-time migration from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      value = prefs.getString(LocalKeys.activeGroupId);
      if (value != null) {
        await _secure.write(key: LocalKeys.activeGroupId, value: value);
        await prefs.remove(LocalKeys.activeGroupId);
      }
    }
    return value;
  }

  Future<void> clearActiveGroup() async {
    await _secure.delete(key: LocalKeys.activeGroupId);
  }

  // ------ Supabase User ID (secure) ------
  Future<void> saveSupabaseUserId(String userId) async {
    await _secure.write(key: LocalKeys.supabaseUserId, value: userId);
  }

  Future<String?> loadSupabaseUserId() async {
    var value = await _secure.read(key: LocalKeys.supabaseUserId);
    if (value == null) {
      // One-time migration from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      value = prefs.getString(LocalKeys.supabaseUserId);
      if (value != null) {
        await _secure.write(key: LocalKeys.supabaseUserId, value: value);
        await prefs.remove(LocalKeys.supabaseUserId);
      }
    }
    return value;
  }

  // ------ Cached Group (per groupId) ------
  Future<void> saveGroup(Group group) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '${LocalKeys.cachedGroupPrefix}${group.id}',
      jsonEncode({
        'id': group.id,
        'name': group.name,
        'imageUrl': group.imageUrl,
        'settings': group.settings.toJson(),
      }),
    );
  }

  Future<Group?> loadGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('${LocalKeys.cachedGroupPrefix}$groupId');
    if (value == null) return null;
    try {
      final map = jsonDecode(value) as Map<String, dynamic>;
      GroupSettings? settings;
      final rawSettings = map['settings'];
      if (rawSettings is Map<String, dynamic>) {
        settings = GroupSettings.fromJson(rawSettings);
      }
      return Group(
        id: map['id'] as String,
        name: map['name'] as String,
        imageUrl: map['imageUrl'] as String,
        settings: settings,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> clearGroup(String groupId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${LocalKeys.cachedGroupPrefix}$groupId');
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
