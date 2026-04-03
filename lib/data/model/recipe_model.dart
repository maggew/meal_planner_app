import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/utils/recipe_link_parser.dart';
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
    super.carbTags,
  });

  Map<String, dynamic> toSupabase({
    required String recipeId,
    required String groupId,
    required String createdBy,
    String? imageUrl,
  }) {
    return {
      SupabaseConstants.recipeId: recipeId,
      SupabaseConstants.recipeGroupId: groupId,
      SupabaseConstants.recipeTitle: name,
      SupabaseConstants.recipePortions: portions,
      SupabaseConstants.recipeInstructions: instructions,
      SupabaseConstants.recipeImageUrl: imageUrl ?? this.imageUrl,
      SupabaseConstants.recipeCreatedBy: createdBy,
      SupabaseConstants.recipeCreatedAt: createdAt.toIso8601String(),
      'carb_tags': carbTags,
    };
  }

  Map<String, dynamic> toSupabaseUpdate() {
    return {
      SupabaseConstants.recipeTitle: name,
      SupabaseConstants.recipePortions: portions,
      SupabaseConstants.recipeInstructions: instructions,
      SupabaseConstants.recipeImageUrl: imageUrl,
      'carb_tags': carbTags,
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
        .map((e) {
          final link = RecipeLinkParser.extractFirst(e.key);
          if (link != null) {
            return IngredientSection(
              title: link.displayName,
              ingredients: [],
              linkedRecipeId: link.recipeId,
            );
          }
          return IngredientSection(
            title: e.key,
            ingredients: e.value
              ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder)),
          );
        })
        .toList();

    final carbTagsRaw = data['carb_tags'] as List? ?? [];
    final carbTags = carbTagsRaw.whereType<String>().toList();

    return RecipeModel(
      id: data[SupabaseConstants.recipeId] as String?,
      name: data[SupabaseConstants.recipeTitle] as String? ?? '',
      instructions: data[SupabaseConstants.recipeInstructions] as String? ?? '',
      imageUrl: data[SupabaseConstants.recipeImageUrl] as String?,
      portions: data[SupabaseConstants.recipePortions] as int? ?? 4,
      categories: categories,
      ingredientSections: ingredientSections,
      carbTags: carbTags,
    );
  }

  factory RecipeModel.fromEntity(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      name: recipe.name,
      categories: recipe.categories,
      portions: recipe.portions,
      ingredientSections: recipe.ingredientSections,
      instructions: recipe.instructions,
      imageUrl: recipe.imageUrl,
      createdAt: recipe.createdAt,
      carbTags: recipe.carbTags,
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
      carbTags: carbTags,
    );
  }
}
