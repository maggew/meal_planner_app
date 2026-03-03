import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/utils/uuid_generator.dart';
import 'package:meal_planner/data/model/group_category_model.dart';
import 'package:meal_planner/domain/entities/group_category.dart';
import 'package:meal_planner/domain/repositories/group_category_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CategoryInUseException implements Exception {
  final int recipeCount;
  CategoryInUseException(this.recipeCount);

  @override
  String toString() => '$recipeCount Rezepte verwenden diese Kategorie';
}

class SupabaseGroupCategoryRepository implements GroupCategoryRepository {
  final SupabaseClient _supabase;

  SupabaseGroupCategoryRepository({required SupabaseClient supabase})
      : _supabase = supabase;

  @override
  Future<List<GroupCategory>> getCategories(String groupId) async {
    final response = await _supabase
        .from(SupabaseConstants.categoriesTable)
        .select()
        .eq(SupabaseConstants.categoryGroupId, groupId)
        .order(SupabaseConstants.categorySortOrder);

    return (response as List)
        .map((data) => GroupCategoryModel.fromSupabase(data).toEntity())
        .toList();
  }

  @override
  Future<GroupCategory> addCategory(String groupId, String name) async {
    final id = generateUuid();
    final model = GroupCategoryModel(
      id: id,
      groupId: groupId,
      name: name.toLowerCase(),
      sortOrder: 0,
    );

    final response = await _supabase
        .from(SupabaseConstants.categoriesTable)
        .insert(model.toSupabaseInsert())
        .select()
        .single();

    return GroupCategoryModel.fromSupabase(response).toEntity();
  }

  @override
  Future<void> updateCategory(
    String categoryId, {
    String? name,
    int? sortOrder,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data[SupabaseConstants.categoryName] = name;
    if (sortOrder != null)
      data[SupabaseConstants.categorySortOrder] = sortOrder;
    if (data.isEmpty) return;

    await _supabase
        .from(SupabaseConstants.categoriesTable)
        .update(data)
        .eq(SupabaseConstants.categoryId, categoryId);
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    // Prüfen ob Rezepte diese Kategorie verwenden
    final usages = await _supabase
        .from(SupabaseConstants.recipeCategoriesTable)
        .select(SupabaseConstants.recipeCategoryRecipeId)
        .eq(SupabaseConstants.recipeCategoryCategoryId, categoryId);

    final count = (usages as List).length;
    if (count > 0) {
      throw CategoryInUseException(count);
    }

    await _supabase
        .from(SupabaseConstants.categoriesTable)
        .delete()
        .eq(SupabaseConstants.categoryId, categoryId);
  }
}
