import 'dart:convert';

import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'user_settings_provider.g.dart';

@Riverpod(keepAlive: true)
class UserSettingsNotifier extends _$UserSettingsNotifier {
  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);
  final String userSettingsString = 'user_settings';

  @override
  UserSettings build() {
    final json = _prefs.getString(userSettingsString);
    if (json == null) return UserSettings.defaultSettings;
    return UserSettings.fromJson(jsonDecode(json));
  }

  void _save() {
    _prefs.setString(userSettingsString, jsonEncode(state.toJson()));
  }

  void updateTheme(ThemeOption option) {
    state = state.copyWith(themeOption: option);
    _save();
  }

  void updateTabPosition(TabPosition position) {
    state = state.copyWith(tabPosition: position);
    _save();
  }

  void updateRecipeSort(RecipeSortOption option) {
    state = state.copyWith(recipeSortOption: option);
    _save();
  }

  void update(UserSettings newSettings) {
    state = newSettings;
    _save();
  }
}
