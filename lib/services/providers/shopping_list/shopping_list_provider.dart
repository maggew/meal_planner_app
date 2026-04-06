import 'package:meal_planner/core/utils/shopping_list_input_parser.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/domain/repositories/shopping_list_repository.dart';
import 'package:meal_planner/domain/services/ingredient_merge_service.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_provider.g.dart';

// Stream-Provider für die UI – reagiert automatisch auf Drift-Änderungen
@Riverpod(keepAlive: true)
Stream<List<ShoppingListItem>> shoppingListStream(Ref ref) {
  final repo = ref.watch(shoppingListRepositoryProvider);
  return repo.watchItems();
}

// Notifier nur noch für Aktionen – kein manuelles State-Management mehr
@Riverpod(keepAlive: true)
class ShoppingListActions extends _$ShoppingListActions {
  @override
  void build() {}

  final _mergeService = IngredientMergeService();

  Future<List<MergeResult>> addItem(String input) async {
    final parsed = ShoppingListInputParser.parse(input);
    final repo = ref.read(shoppingListRepositoryProvider);

    final mergeResult = await _tryMergeOrAdd(
      parsed.information,
      parsed.quantity,
      repo,
    );
    return mergeResult != null ? [mergeResult] : [];
  }

  Future<List<MergeResult>> addItemsFromIngredients(
    List<Ingredient> ingredients,
  ) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    final merges = <MergeResult>[];

    for (final ingredient in ingredients) {
      final name = ingredient.name.trim();
      if (name.isEmpty) continue;
      final quantity = [
        if (ingredient.amount != null) '${ingredient.amount}',
        if (ingredient.unit != null) ingredient.unit!.displayName,
      ].join(' ');

      final mergeResult = await _tryMergeOrAdd(
        name,
        quantity.isEmpty ? null : quantity,
        repo,
      );
      if (mergeResult != null) merges.add(mergeResult);
    }
    return merges;
  }

  Future<MergeResult?> _tryMergeOrAdd(
    String information,
    String? quantity,
    ShoppingListRepository repo,
  ) async {
    final items = await repo.getItems();
    final mergeResult = _mergeService.tryMerge(information, quantity, items);

    if (mergeResult != null) {
      await repo.updateItem(
        mergeResult.itemId,
        information,
        mergeResult.newQuantity,
      );
      return mergeResult;
    }

    await repo.addItem(information, quantity);
    return null;
  }

  Future<void> updateItem(String itemId, String information, String? quantity) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.updateItem(itemId, information, quantity);
  }

  Future<void> toggleItem(String itemId, bool isChecked) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.toggleItem(itemId, isChecked);
  }

  Future<void> removeItem(String itemId) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.removeItem(itemId);
  }

  Future<void> removeCheckedItems() async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.removeCheckedItems();
  }
}

