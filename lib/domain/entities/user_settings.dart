import 'package:meal_planner/domain/enums/tab_position.dart';

class UserSettings {
  final TabPosition tabPosition;

  const UserSettings({
    this.tabPosition = TabPosition.left,
  });

  static const defaultSettings = UserSettings();

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      tabPosition: TabPosition.values.byName(
        json['tab_position'] as String? ?? 'left',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'tab_position': tabPosition.name,
      };

  UserSettings copyWith({TabPosition? tabPosition}) {
    return UserSettings(
      tabPosition: tabPosition ?? this.tabPosition,
    );
  }
}
