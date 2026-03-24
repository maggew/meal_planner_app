import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/enums/week_start_day.dart';

class GroupSettings {
  final WeekStartDay weekStartDay;
  final List<MealType> defaultMealSlots;
  /// Suggestion algorithm weight for recipe rotation (0=off … 3=high).
  final int rotationWeight;
  /// Suggestion algorithm weight for carb-tag variety (0=off … 3=high).
  /// Also controls whether the carb-tag selector is shown in recipe forms.
  final int carbVarietyWeight;

  const GroupSettings({
    this.weekStartDay = WeekStartDay.monday,
    List<MealType>? defaultMealSlots,
    this.rotationWeight = 3,
    this.carbVarietyWeight = 2,
  }) : defaultMealSlots = defaultMealSlots ?? MealType.values;

  static const defaultSettings = GroupSettings();

  bool get showCarbTags => carbVarietyWeight > 0;

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

    // Always sort by enum declaration order (breakfast → lunch → dinner)
    parsedSlots.sort((a, b) => a.index.compareTo(b.index));

    return GroupSettings(
      weekStartDay: WeekStartDay.values.byName(
        json['week_start_day'] as String? ?? 'monday',
      ),
      defaultMealSlots:
          parsedSlots.isNotEmpty ? parsedSlots : MealType.values.toList(),
      rotationWeight: json['rotation_weight'] as int? ?? 3,
      carbVarietyWeight: json['carb_variety_weight'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toJson() => {
        'week_start_day': weekStartDay.name,
        'default_meal_slots': defaultMealSlots.map((m) => m.value).toList(),
        'rotation_weight': rotationWeight,
        'carb_variety_weight': carbVarietyWeight,
      };

  GroupSettings copyWith({
    WeekStartDay? weekStartDay,
    List<MealType>? defaultMealSlots,
    int? rotationWeight,
    int? carbVarietyWeight,
  }) {
    return GroupSettings(
      weekStartDay: weekStartDay ?? this.weekStartDay,
      defaultMealSlots: defaultMealSlots ?? this.defaultMealSlots,
      rotationWeight: rotationWeight ?? this.rotationWeight,
      carbVarietyWeight: carbVarietyWeight ?? this.carbVarietyWeight,
    );
  }
}
