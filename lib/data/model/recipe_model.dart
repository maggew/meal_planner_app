import 'package:meal_planner/data/model/ingredient_model.dart';
import 'package:meal_planner/domain/entities/recipe.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';

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
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? '',
      portions: data['portions'] as int? ?? 4,
      ingredients: (data['ingredients'] as List<dynamic>?)
              ?.map((i) =>
                  IngredientModel.fromFirestore(i as Map<String, dynamic>))
              .cast<Ingredient>()
              .toList() ??
          [],
      instructions: data['instructions'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'portions': portions,
      'ingredients': ingredients
          .map((i) => IngredientModel.fromEntity(i).toFirestore())
          .toList(),
      'instructions': instructions,
      'recipe_pic': imageUrl,
      'createdAt': createdAt,
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
