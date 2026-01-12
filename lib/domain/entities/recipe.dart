import 'package:meal_planner/domain/entities/ingredient.dart';

class Recipe {
  final String? id;
  final String name;
  final String category;
  //final List<String> categories;
  final int portions;
  final List<Ingredient> ingredients;
  final String instructions;
  final String? imageUrl;
  final DateTime createdAt;

  Recipe({
    this.id,
    required this.name,
    required this.category,
    required this.portions,
    required this.ingredients,
    required this.instructions,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Recipe copyWith({
    String? id,
    String? name,
    String? category,
    //List<String>? categories,
    int? portions,
    List<Ingredient>? ingredients,
    String? instructions,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      //categories: categories ?? this.categories,
      portions: portions ?? this.portions,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
