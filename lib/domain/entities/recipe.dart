import 'package:meal_planner/domain/entities/ingredient.dart';

class Recipe {
  final String? id;
  final String name;
  final List<String> categories;
  final int portions;
  final List<IngredientSection> ingredientSections;
  final String instructions;
  final String? imageUrl;
  final DateTime createdAt;

  Recipe({
    this.id,
    required this.name,
    required this.categories,
    required this.portions,
    required this.ingredientSections,
    required this.instructions,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Recipe copyWith({
    String? id,
    String? name,
    List<String>? categories,
    //List<String>? categories,
    int? portions,
    List<IngredientSection>? ingredientSections,
    String? instructions,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      categories: categories ?? this.categories,
      portions: portions ?? this.portions,
      ingredientSections: ingredientSections ?? this.ingredientSections,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
