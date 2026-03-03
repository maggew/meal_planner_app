import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/enums/tab_position.dart';
import 'package:meal_planner/domain/enums/week_start_day.dart';

enum ThemeOption { light, dark, system }

enum RecipeSortOption { alphabetical, newest, oldest, mostCooked }

class UserSettings {
  final TabPosition tabPosition;
  final ThemeOption themeOption;
  final RecipeSortOption recipeSortOption;
  final WeekStartDay weekStartDay;
  final List<MealType> defaultMealSlots;

  const UserSettings({
    this.tabPosition = TabPosition.left,
    this.themeOption = ThemeOption.system,
    this.recipeSortOption = RecipeSortOption.alphabetical,
    this.weekStartDay = WeekStartDay.monday,
    List<MealType>? defaultMealSlots,
  }) : defaultMealSlots = defaultMealSlots ?? MealType.values;

  static const defaultSettings = UserSettings();

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['default_meal_slots'] as List<dynamic>?;
    final parsedSlots = rawSlots != null
        ? rawSlots
            .map((v) {
              try {
                return MealType.fromValue(v as String);
              } catch (_) {
                return null;
              }
            })
            .whereType<MealType>()
            .toList()
        : MealType.values.toList();

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
      weekStartDay: WeekStartDay.values.byName(
        json['week_start_day'] as String? ?? 'monday',
      ),
      defaultMealSlots: parsedSlots.isNotEmpty ? parsedSlots : MealType.values.toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'tab_position': tabPosition.name,
        'theme_option': themeOption.name,
        'recipe_sort_option': recipeSortOption.name,
        'week_start_day': weekStartDay.name,
        'default_meal_slots': defaultMealSlots.map((m) => m.value).toList(),
      };

  UserSettings copyWith({
    TabPosition? tabPosition,
    ThemeOption? themeOption,
    RecipeSortOption? recipeSortOption,
    WeekStartDay? weekStartDay,
    List<MealType>? defaultMealSlots,
  }) {
    return UserSettings(
      tabPosition: tabPosition ?? this.tabPosition,
      themeOption: themeOption ?? this.themeOption,
      recipeSortOption: recipeSortOption ?? this.recipeSortOption,
      weekStartDay: weekStartDay ?? this.weekStartDay,
      defaultMealSlots: defaultMealSlots ?? this.defaultMealSlots,
    );
  }
}
