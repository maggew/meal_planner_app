import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';

class MealPlanEntryModel {
  final String id;
  final String groupId;
  final String recipeId;
  final String date; // 'yyyy-MM-dd'
  final String mealType; // 'breakfast' | 'lunch' | 'dinner'

  const MealPlanEntryModel({
    required this.id,
    required this.groupId,
    required this.recipeId,
    required this.date,
    required this.mealType,
  });

  factory MealPlanEntryModel.fromSupabase(Map<String, dynamic> data) {
    return MealPlanEntryModel(
      id: data[SupabaseConstants.mealPlanEntryId] as String,
      groupId: data[SupabaseConstants.mealPlanEntryGroupId] as String,
      recipeId: data[SupabaseConstants.mealPlanEntryRecipeId] as String,
      date: data[SupabaseConstants.mealPlanEntryDate] as String,
      mealType: data[SupabaseConstants.mealPlanEntryMealType] as String,
    );
  }

  MealPlanEntry toEntity() {
    final parts = date.split('-');
    return MealPlanEntry(
      id: id,
      remoteId: id,
      groupId: groupId,
      recipeId: recipeId,
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
      mealType: MealType.fromValue(mealType),
    );
  }
}
