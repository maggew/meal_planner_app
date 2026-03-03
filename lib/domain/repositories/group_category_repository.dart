import 'package:meal_planner/domain/entities/group_category.dart';

abstract class GroupCategoryRepository {
  Future<List<GroupCategory>> getCategories(String groupId);
  Future<GroupCategory> addCategory(String groupId, String name);
  Future<void> updateCategory(String categoryId,
      {String? name, int? sortOrder});

  Future<void> updateSortOrders(List<GroupCategory> categories);

  Future<void> deleteCategory(String categoryId);
}
