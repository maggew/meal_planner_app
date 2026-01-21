import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/model/ingredient_model.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/recipe.dart';

class RecipeModel extends Recipe {
  RecipeModel({
    super.id,
    required super.name,
    required super.categories,
    required super.portions,
    required super.ingredientSections,
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

  factory RecipeModel.fromSupabaseWithRelations(Map<String, dynamic> data) {
    // Kategorien
    final categoriesData =
        data[SupabaseConstants.recipeCategoriesTable] as List? ?? [];
    final categories = categoriesData
        .map((recipeCategory) =>
            recipeCategory[SupabaseConstants.categoriesTable]
                ?[SupabaseConstants.categoryName] as String?)
        .whereType<String>()
        .toList();

    // Ingredients inkl. Section
    final ingredientsData =
        data[SupabaseConstants.recipeIngredientsTable] as List? ?? [];

    final Map<String, List<IngredientModel>> sectionMap = {};

    for (final raw in ingredientsData) {
      final ingredient = IngredientModel.fromSupabase(raw);
      final sectionTitle =
          raw[SupabaseConstants.recipeIngredientGroupName] as String? ??
              'Zutaten';

      sectionMap.putIfAbsent(sectionTitle, () => []);
      sectionMap[sectionTitle]!.add(ingredient);
    }

    final ingredientSections = sectionMap.entries
        .map(
          (e) => IngredientSection(
            title: e.key,
            items: e.value..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
          ),
        )
        .toList();

    return RecipeModel(
      id: data[SupabaseConstants.recipeId] as String?,
      name: data[SupabaseConstants.recipeTitle] as String? ?? '',
      instructions: data[SupabaseConstants.recipeInstructions] as String? ?? '',
      imageUrl: data[SupabaseConstants.recipeImageUrl] as String?,
      portions: data[SupabaseConstants.recipePortions] as int? ?? 4,
      categories: categories,
      ingredientSections: ingredientSections,
    );
  }

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      categories: recipe.categories,
      //categories: recipe.categories,
      portions: recipe.portions,
      ingredientSections: recipe.ingredientSections,
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
      ingredientSections: ingredientSections,
      instructions: instructions,
      imageUrl: imageUrl,
      createdAt: createdAt,
    );
  }
}
