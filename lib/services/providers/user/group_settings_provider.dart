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

  void _save() {
    final prefs = ref.read(sharedPreferencesProvider);
    final groupId = ref.read(sessionProvider).groupId;
    if (groupId == null) return;
    prefs.setString('group_settings_$groupId', jsonEncode(state.toJson()));
  }

  void update(GroupSettings newSettings) {
    state = newSettings;
    _save();
  }
}

final groupSettingsProvider =
    NotifierProvider<GroupSettingsNotifier, GroupSettings>(
  GroupSettingsNotifier.new,
);
