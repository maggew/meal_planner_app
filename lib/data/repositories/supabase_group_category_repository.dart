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
        .order(SupabaseConstants.categorySortOrder, ascending: true);

    return (response as List)
        .map((data) => GroupCategoryModel.fromSupabase(data).toEntity())
        .toList();
  }

  @override
  Future<GroupCategory> addCategory(String groupId, String name,
      {String? iconName}) async {
    // sort_order = aktuelle Anzahl Kategorien → neue Kategorie ans Ende
    final existing = await _supabase
        .from(SupabaseConstants.categoriesTable)
        .select(SupabaseConstants.categoryId)
        .eq(SupabaseConstants.categoryGroupId, groupId);
    final nextSortOrder = (existing as List).length;

    final id = generateUuid();
    final model = GroupCategoryModel(
      id: id,
      groupId: groupId,
      name: name,
      sortOrder: nextSortOrder,
      iconName: iconName,
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
    String? iconName,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data[SupabaseConstants.categoryName] = name;
    if (sortOrder != null) data[SupabaseConstants.categorySortOrder] = sortOrder;
    if (iconName != null) data[SupabaseConstants.categoryIconName] = iconName;
    if (data.isEmpty) return;

    final response = await _supabase
        .from(SupabaseConstants.categoriesTable)
        .update(data)
        .eq(SupabaseConstants.categoryId, categoryId)
        .select();

    if ((response as List).isEmpty) {
      throw Exception(
        'updateCategory: keine Zeile aktualisiert für id=$categoryId — RLS-Policy blockiert?',
      );
    }
  }

  Future<void> updateSortOrders(List<GroupCategory> categories) async {
    final data = categories
        .map((c) => {
              'id': c.id,
              'group_id': c.groupId,
              'sort_order': c.sortOrder,
            })
        .toList();

    await _supabase.from(SupabaseConstants.categoriesTable).upsert(
          data,
          onConflict: 'id',
        );
  }

  @override
  Future<void> syncCategories(
    String groupId,
    List<GroupCategory> categories,
    List<String> deletedIds,
  ) async {
    if (deletedIds.isNotEmpty) {
      // Check each for in-use before deleting (preserves CategoryInUseException)
      for (final id in deletedIds) {
        await deleteCategory(id);
      }
    }
    if (categories.isNotEmpty) {
      final data = categories
          .map((c) => GroupCategoryModel(
                id: c.id,
                groupId: groupId,
                name: c.name,
                sortOrder: c.sortOrder,
                iconName: c.iconName,
              ).toSupabaseInsert())
          .toList();
      await _supabase
          .from(SupabaseConstants.categoriesTable)
          .upsert(data, onConflict: 'id');
    }
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
