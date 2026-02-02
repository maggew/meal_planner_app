import 'package:meal_planner/core/constants/local_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  const LocalStorageService();

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
}
