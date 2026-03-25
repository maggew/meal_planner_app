import 'package:meal_planner/domain/enums/shopping_list_view_mode.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';

enum ThemeOption { light, dark, system }

enum RecipeSortOption { alphabetical, newest, oldest, mostCooked }

class UserSettings {
  final TabPosition tabPosition;
  final ThemeOption themeOption;
  final RecipeSortOption recipeSortOption;
  final ShoppingListViewMode shoppingListViewMode;

  const UserSettings({
    this.tabPosition = TabPosition.right,
    this.themeOption = ThemeOption.system,
    this.recipeSortOption = RecipeSortOption.alphabetical,
    this.shoppingListViewMode = ShoppingListViewMode.grid,
  });

  static const defaultSettings = UserSettings();

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      tabPosition: TabPosition.values.byName(
        json['tab_position'] as String? ?? 'right',
      ),
      themeOption: ThemeOption.values.byName(
        json['theme_option'] as String? ?? 'system',
      ),
      recipeSortOption: RecipeSortOption.values.byName(
        json['recipe_sort_option'] as String? ?? 'alphabetical',
      ),
      shoppingListViewMode: ShoppingListViewMode.values.byName(
        json['shopping_list_view_mode'] as String? ?? 'grid',
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'tab_position': tabPosition.name,
        'theme_option': themeOption.name,
        'recipe_sort_option': recipeSortOption.name,
        'shopping_list_view_mode': shoppingListViewMode.name,
      };

  UserSettings copyWith({
    TabPosition? tabPosition,
    ThemeOption? themeOption,
    RecipeSortOption? recipeSortOption,
    ShoppingListViewMode? shoppingListViewMode,
  }) {
    return UserSettings(
      tabPosition: tabPosition ?? this.tabPosition,
      themeOption: themeOption ?? this.themeOption,
      recipeSortOption: recipeSortOption ?? this.recipeSortOption,
      shoppingListViewMode:
          shoppingListViewMode ?? this.shoppingListViewMode,
    );
  }
}
