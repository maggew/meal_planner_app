import 'package:meal_planner/core/constants/categories.dart';
import 'package:meal_planner/data/repositories/supabase_group_category_repository.dart';
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
    final categories = await repo.getCategories(groupId);

    // Neue Gruppe ohne Kategorien: Default-Kategorien anlegen
    if (categories.isEmpty) {

      return _createDefaultCategories(groupId, repo);

    }


    return categories;
  }

  Future<List<GroupCategory>> _createDefaultCategories(
    String groupId,
    dynamic repo,
  ) async {
    final created = <GroupCategory>[];
    for (int i = 0; i < defaultCategoryNames.length; i++) {
      try {
        final category =

            await repo.addCategory(groupId, defaultCategoryNames[i]);
        created.add(category);
      } catch (_) {
        // Kategorie existiert ggf. schon — ignorieren
      }
    }
    // Nach dem Anlegen nochmal laden um sort_order korrekt zu haben
    final repo2 = ref.read(groupCategoryRepositoryProvider);
    return repo2.getCategories(groupId);
  }

  Future<void> addCategory(String name) async {
    final session = ref.read(sessionProvider);
    final groupId = session.groupId;
    if (groupId == null) return;

    final repo = ref.read(groupCategoryRepositoryProvider);
    await repo.addCategory(groupId, name);
    ref.invalidateSelf();
  }

  Future<void> renameCategory(String categoryId, String newName) async {
    final repo = ref.read(groupCategoryRepositoryProvider);
    await repo.updateCategory(categoryId, name: newName);
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
}
