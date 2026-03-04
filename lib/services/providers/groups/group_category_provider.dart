import 'package:meal_planner/domain/entities/group_category.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_category_provider.g.dart';

@riverpod
class GroupCategories extends _$GroupCategories {
  static final _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  @override
  Future<List<GroupCategory>> build() async {
    final session = ref.watch(sessionProvider);
    final groupId = session.groupId;
    if (groupId == null || !_uuidRegex.hasMatch(groupId)) return [];

    final repo = ref.watch(groupCategoryRepositoryProvider);
    return repo.getCategories(groupId);
  }

  Future<void> addCategory(String name, {String? iconName}) async {
    final session = ref.read(sessionProvider);
    final groupId = session.groupId;
    if (groupId == null) return;

    final repo = ref.read(groupCategoryRepositoryProvider);
    await repo.addCategory(groupId, name, iconName: iconName);
    ref.invalidateSelf();
  }

  Future<void> updateCategory(
      String categoryId, String newName, String? iconName) async {
    final repo = ref.read(groupCategoryRepositoryProvider);
    await repo.updateCategory(categoryId, name: newName, iconName: iconName);
    ref.invalidateSelf();
  }

  /// Wirft [CategoryInUseException] wenn Rezepte die Kategorie verwenden.
  Future<void> deleteCategory(String categoryId) async {
    final repo = ref.read(groupCategoryRepositoryProvider);
    await repo.deleteCategory(categoryId);
    ref.invalidateSelf();
  }

  Future<void> reorderCategory(String categoryId, int newOrder) async {
    final repo = ref.read(groupCategoryRepositoryProvider);
    await repo.updateCategory(categoryId, sortOrder: newOrder);
    ref.invalidateSelf();
  }

  Future<void> reorderCategories(List<GroupCategory> orderedCategories) async {
    final repo = ref.read(groupCategoryRepositoryProvider);

    final updated = [
      for (int i = 0; i < orderedCategories.length; i++)
        orderedCategories[i].copyWith(sortOrder: i),
    ];

    // Optimistic UI
    state = AsyncData(updated);

    try {
      await repo.updateSortOrders(updated); // ← EIN Call
    } catch (_) {
      ref.invalidateSelf();
      rethrow;
    }
  }
}
