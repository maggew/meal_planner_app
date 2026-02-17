import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';

class RecipeTimerModel extends RecipeTimer {
  RecipeTimerModel({
    super.id,
    required super.recipeId,
    required super.stepIndex,
    required super.timerName,
    required super.durationSeconds,
  });

  Map<String, dynamic> toSupabase() {
    return {
      SupabaseConstants.recipeTimerRecipeId: recipeId,
      SupabaseConstants.recipeTimerStepIndex: stepIndex,
      SupabaseConstants.recipeTimerName: timerName,
      SupabaseConstants.recipeTimerDurationSeconds: durationSeconds,
    };
  }

  factory RecipeTimerModel.fromSupabase(Map<String, dynamic> data) {
    return RecipeTimerModel(
      id: data[SupabaseConstants.recipeTimerId] as String?,
      recipeId: data[SupabaseConstants.recipeTimerRecipeId] as String,
      stepIndex: data[SupabaseConstants.recipeTimerStepIndex] as int,
      timerName: data[SupabaseConstants.recipeTimerName] as String? ?? '',
      durationSeconds:
          data[SupabaseConstants.recipeTimerDurationSeconds] as int,
    );
  }

  factory RecipeTimerModel.fromEntity(RecipeTimer timer) {
    return RecipeTimerModel(
      id: timer.id,
      recipeId: timer.recipeId,
      stepIndex: timer.stepIndex,
      timerName: timer.timerName,
      durationSeconds: timer.durationSeconds,
    );
  }

  RecipeTimer toEntity() {
    return RecipeTimer(
      id: id,
      recipeId: recipeId,
      stepIndex: stepIndex,
      timerName: timerName,
      durationSeconds: durationSeconds,
    );
  }
}
