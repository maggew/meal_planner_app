import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/enums/week_start_day.dart';

class GroupSettings {
  final WeekStartDay weekStartDay;
  final List<MealType> defaultMealSlots;
  final bool showCarbTags;

  const GroupSettings({
    this.weekStartDay = WeekStartDay.monday,
    List<MealType>? defaultMealSlots,
    this.showCarbTags = true,
  }) : defaultMealSlots = defaultMealSlots ?? MealType.values;

  static const defaultSettings = GroupSettings();

  factory GroupSettings.fromJson(Map<String, dynamic> json) {
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

    return GroupSettings(
      weekStartDay: WeekStartDay.values.byName(
        json['week_start_day'] as String? ?? 'monday',
      ),
      defaultMealSlots:
          parsedSlots.isNotEmpty ? parsedSlots : MealType.values.toList(),
      showCarbTags: json['show_carb_tags'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'week_start_day': weekStartDay.name,
        'default_meal_slots': defaultMealSlots.map((m) => m.value).toList(),
        'show_carb_tags': showCarbTags,
      };

  GroupSettings copyWith({
    WeekStartDay? weekStartDay,
    List<MealType>? defaultMealSlots,
    bool? showCarbTags,
  }) {
    return GroupSettings(
      weekStartDay: weekStartDay ?? this.weekStartDay,
      defaultMealSlots: defaultMealSlots ?? this.defaultMealSlots,
      showCarbTags: showCarbTags ?? this.showCarbTags,
    );
  }
}
