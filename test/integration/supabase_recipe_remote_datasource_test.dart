import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/datasources/supabase_recipe_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'test_config.dart';

void main() {
  late SupabaseClient supabase;
  late SupabaseRecipeRemoteDatasource datasource;
  final uuid = const Uuid();

  setUpAll(() async {
    supabase = SupabaseClient(
      TestConfig.supabaseUrl,
      TestConfig.supabaseKey,
    );
    datasource = SupabaseRecipeRemoteDatasource(supabase);
  });

  group('deleteRecipeCategories', () {
    late String testRecipeId;
    late String testCategoryId1;
    late String testCategoryId2;
    late String testGroupId;
    late String testUserId;

    setUp(() async {
      // Neue UUIDs für jeden Test
      testRecipeId = uuid.v4();
      testCategoryId1 = uuid.v4();
      testCategoryId2 = uuid.v4();
      testGroupId = uuid.v4();
      testUserId = uuid.v4();

      // 1. Group anlegen (falls recipes eine group_id braucht)
      await supabase.from(SupabaseConstants.groupsTable).insert({
        SupabaseConstants.groupId: testGroupId,
        SupabaseConstants.groupName: 'Test Group',
      });

      // 2. User anlegen (falls recipes eine created_by braucht)
      await supabase.from(SupabaseConstants.usersTable).insert({
        SupabaseConstants.userId: testUserId,
        SupabaseConstants.userName: 'Test User',
      });

      // 3. Recipe anlegen
      await supabase.from(SupabaseConstants.recipesTable).insert({
        SupabaseConstants.recipeId: testRecipeId,
        SupabaseConstants.recipeTitle: 'Test Recipe',
        SupabaseConstants.recipeGroupId: testGroupId,
        SupabaseConstants.recipeCreatedBy: testUserId,
        SupabaseConstants.recipePortions: 4,
        SupabaseConstants.recipeInstructions: 'Test instructions',
      });

      // 4. Categories anlegen
      await supabase.from(SupabaseConstants.categoriesTable).insert([
        {
          SupabaseConstants.categoryId: testCategoryId1,
          SupabaseConstants.categoryName: 'test-category-1',
        },
        {
          SupabaseConstants.categoryId: testCategoryId2,
          SupabaseConstants.categoryName: 'test-category-2',
        },
      ]);
    });

    tearDown(() async {
      // Cleanup in umgekehrter Reihenfolge (wegen Foreign Keys)
      await supabase
          .from(SupabaseConstants.recipeCategoriesTable)
          .delete()
          .eq(SupabaseConstants.recipeCategoryRecipeId, testRecipeId);
      await supabase
          .from(SupabaseConstants.recipesTable)
          .delete()
          .eq(SupabaseConstants.recipeId, testRecipeId);
      await supabase.from(SupabaseConstants.categoriesTable).delete().inFilter(
          SupabaseConstants.categoryId, [testCategoryId1, testCategoryId2]);
      await supabase
          .from(SupabaseConstants.usersTable)
          .delete()
          .eq(SupabaseConstants.userId, testUserId);
      await supabase
          .from(SupabaseConstants.groupsTable)
          .delete()
          .eq(SupabaseConstants.groupId, testGroupId);
    });

    test('removes all category entries for a recipe', () async {
      // Arrange - Junction-Einträge erstellen
      await supabase.from(SupabaseConstants.recipeCategoriesTable).insert([
        {
          SupabaseConstants.recipeCategoryRecipeId: testRecipeId,
          SupabaseConstants.recipeCategoryCategoryId: testCategoryId1,
        },
        {
          SupabaseConstants.recipeCategoryRecipeId: testRecipeId,
          SupabaseConstants.recipeCategoryCategoryId: testCategoryId2,
        },
      ]);

      // Verify setup
      final before = await supabase
          .from(SupabaseConstants.recipeCategoriesTable)
          .select()
          .eq(SupabaseConstants.recipeCategoryRecipeId, testRecipeId);
      expect(before, hasLength(2));

      // Act
      await datasource.deleteRecipeCategories(testRecipeId);

      // Assert
      final after = await supabase
          .from(SupabaseConstants.recipeCategoriesTable)
          .select()
          .eq(SupabaseConstants.recipeCategoryRecipeId, testRecipeId);
      expect(after, isEmpty);
    });

    test('does not affect other recipes categories', () async {
      // Arrange - zweites Recipe
      final otherRecipeId = uuid.v4();
      await supabase.from(SupabaseConstants.recipesTable).insert({
        SupabaseConstants.recipeId: otherRecipeId,
        SupabaseConstants.recipeTitle: 'Other Recipe',
        SupabaseConstants.recipeGroupId: testGroupId,
        SupabaseConstants.recipeCreatedBy: testUserId,
        SupabaseConstants.recipePortions: 2,
        SupabaseConstants.recipeInstructions: 'Other instructions',
      });

      await supabase.from(SupabaseConstants.recipeCategoriesTable).insert([
        {
          SupabaseConstants.recipeCategoryRecipeId: testRecipeId,
          SupabaseConstants.recipeCategoryCategoryId: testCategoryId1,
        },
        {
          SupabaseConstants.recipeCategoryRecipeId: otherRecipeId,
          SupabaseConstants.recipeCategoryCategoryId: testCategoryId2,
        },
      ]);

      // Act
      await datasource.deleteRecipeCategories(testRecipeId);

      // Assert
      final otherRecipeCategories = await supabase
          .from(SupabaseConstants.recipeCategoriesTable)
          .select()
          .eq(SupabaseConstants.recipeCategoryRecipeId, otherRecipeId);
      expect(otherRecipeCategories, hasLength(1));

      // Cleanup
      await supabase
          .from(SupabaseConstants.recipeCategoriesTable)
          .delete()
          .eq(SupabaseConstants.recipeCategoryRecipeId, otherRecipeId);
      await supabase
          .from(SupabaseConstants.recipesTable)
          .delete()
          .eq(SupabaseConstants.recipeId, otherRecipeId);
    });

    test('handles recipe with no categories gracefully', () async {
      // Act & Assert - should not throw even if no categories exist
      await expectLater(
        datasource.deleteRecipeCategories(testRecipeId),
        completes,
      );
    });
  });
}
