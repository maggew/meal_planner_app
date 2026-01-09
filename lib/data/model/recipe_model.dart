import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  RecipeModel({
    super.id,
    required super.name,
    required super.categories,
    required super.portions,
    required super.ingredients,
    required super.instructions,
    super.imageUrl,
    super.createdAt,
  });

  Map<String, dynamic> toSupabase({
    required String recipeId,
    required String groupId,
    required String userId,
    String? imageUrl,
  }) {
    return {
      SupabaseConstants.recipeId: recipeId,
      SupabaseConstants.recipeGroupId: groupId,
      SupabaseConstants.recipeTitle: name,
      SupabaseConstants.recipePortions: portions,
      SupabaseConstants.recipeInstructions: instructions,
      SupabaseConstants.recipeCreatedBy: userId,
      SupabaseConstants.recipeImageUrl: imageUrl ?? this.imageUrl,
      SupabaseConstants.recipeCreatedAt: createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseUpdate() {
    return {
      SupabaseConstants.recipeTitle: name,
      SupabaseConstants.recipePortions: portions,
      SupabaseConstants.recipeInstructions: instructions,
      SupabaseConstants.recipeImageUrl: imageUrl,
    };
  }

  factory RecipeModel.fromSupabase(
    Map<String, dynamic> data, {
    required List<Ingredient> ingredients,
    required List<String> categories,
  }) {
    return RecipeModel(
      id: data[SupabaseConstants.recipeId] as String,
      name: data[SupabaseConstants.recipeTitle] as String? ?? '',
      categories: categories,
      portions: data[SupabaseConstants.recipePortions] as int? ?? 4,
      ingredients: ingredients,
      instructions: data[SupabaseConstants.recipeInstructions] as String? ?? '',
      imageUrl: data[SupabaseConstants.recipeImageUrl] as String?,
      createdAt: data[SupabaseConstants.recipeCreatedAt] != null
          ? DateTime.parse(data[SupabaseConstants.recipeCreatedAt])
          : DateTime.now(),
    );
  }

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      categories: recipe.categories,
      portions: recipe.portions,
      ingredients: recipe.ingredients,
      instructions: recipe.instructions,
      imageUrl: recipe.imageUrl,
      createdAt: recipe.createdAt,
    );
  }

  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      categories: categories,
      portions: portions,
      ingredients: ingredients,
      instructions: instructions,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }
}
