import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';

class GroupSettingsNotifier extends Notifier<GroupSettings> {
  @override
  GroupSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final groupId = ref.watch(sessionProvider).groupId;
    if (groupId == null) return GroupSettings.defaultSettings;
    final json = prefs.getString('group_settings_$groupId');
    if (json == null) return GroupSettings.defaultSettings;
    try {
      return GroupSettings.fromJson(jsonDecode(json));
    } catch (_) {
      return GroupSettings.defaultSettings;
    }
  }

  Future<void> _save() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final groupId = ref.read(sessionProvider).groupId;
    if (groupId == null) return;
    await prefs.setString('group_settings_$groupId', jsonEncode(state.toJson()));
  }

  Future<void> update(GroupSettings newSettings) async {
    state = newSettings;
    await _save();
  }
}

final groupSettingsProvider =
    NotifierProvider<GroupSettingsNotifier, GroupSettings>(
  GroupSettingsNotifier.new,
);
