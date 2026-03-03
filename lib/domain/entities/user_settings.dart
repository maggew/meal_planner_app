import 'package:meal_planner/domain/enums/tab_position.dart';

enum ThemeOption { light, dark, system }

enum RecipeSortOption { alphabetical, newest, oldest, mostCooked }

class UserSettings {
  final TabPosition tabPosition;
  final ThemeOption themeOption;
  final RecipeSortOption recipeSortOption;

  const UserSettings({
    this.tabPosition = TabPosition.left,
    this.themeOption = ThemeOption.system,
    this.recipeSortOption = RecipeSortOption.alphabetical,
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
      recipeSortOption: RecipeSortOption.values.byName(
        json['recipe_sort_option'] as String? ?? 'alphabetical',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'tab_position': tabPosition.name,
        'theme_option': themeOption.name,
        'recipe_sort_option': recipeSortOption.name,
      };

  UserSettings copyWith({
    TabPosition? tabPosition,
    ThemeOption? themeOption,
    RecipeSortOption? recipeSortOption,
  }) {
    return UserSettings(
      tabPosition: tabPosition ?? this.tabPosition,
      themeOption: themeOption ?? this.themeOption,
      recipeSortOption: recipeSortOption ?? this.recipeSortOption,
    );
  }
}
