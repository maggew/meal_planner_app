import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/data/model/ingredient_model.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/presentation/common/categories.dart';

class RecipeModel extends Recipe {
  RecipeModel({
    super.id,
    required super.name,
    required super.category,
    required super.portions,
    required super.ingredients,
    required super.instructions,
    super.imageUrl,
    super.createdAt,
  });

  factory RecipeModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return RecipeModel(
      id: docId,
      name: data[FirebaseConstants.recipeName] as String? ?? '',
      category: mapEnglishCategoryToGermanCategory[
              data[FirebaseConstants.recipeCategory]] ??
          '',
      portions: data[FirebaseConstants.recipePortions] as int? ?? 4,
      ingredients: (data[FirebaseConstants.recipeIngredients] as List<dynamic>?)
              ?.map((i) =>
                  IngredientModel.fromFirestore(i as Map<String, dynamic>))
              .cast<Ingredient>()
              .toList() ??
          [],
      instructions:
          (data[FirebaseConstants.recipeInstructions] as String? ?? '')
              .replaceAll('\\n', '\n'),
      imageUrl: data[FirebaseConstants.recipeImage] as String? ?? '',
      createdAt: data[FirebaseConstants.recipeCreatedAt] != null
          ? (data[FirebaseConstants.recipeCreatedAt] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      FirebaseConstants.recipeName: name,
      FirebaseConstants.recipeCategory:
          mapGermanCategoryToEnglishCategory[category],
      FirebaseConstants.recipePortions: portions,
      FirebaseConstants.recipeIngredients: ingredients
          .map((i) => IngredientModel.fromEntity(i).toFirestore())
          .toList(),
      FirebaseConstants.recipeInstructions: instructions,
      FirebaseConstants.recipeImage: imageUrl,
      FirebaseConstants.recipeCreatedAt: Timestamp.fromDate(createdAt),
    };
  }

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      category: recipe.category,
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
      category: category,
      portions: portions,
      ingredients: ingredients,
      instructions: instructions,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }
}
