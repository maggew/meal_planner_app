import 'package:meal_planner/domain/enums/tab_position.dart';

enum ThemeOption { light, dark, system }

class UserSettings {
  final TabPosition tabPosition;
  final ThemeOption themeOption;

  const UserSettings({
    this.tabPosition = TabPosition.left,
    this.themeOption = ThemeOption.system,
  });

  static const defaultSettings = UserSettings();

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      tabPosition: TabPosition.values.byName(
        json['tab_position'] as String? ?? 'left',
      ),
      themeOption: ThemeOption.values.byName(
        json['theme_option'] as String? ?? 'system',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'tab_position': tabPosition.name,
        'theme_option': themeOption.name,
      };

  UserSettings copyWith({
    TabPosition? tabPosition,
    ThemeOption? themeOption,
  }) {
    return UserSettings(
      tabPosition: tabPosition ?? this.tabPosition,
      themeOption: themeOption ?? this.themeOption,
    );
  }
}
