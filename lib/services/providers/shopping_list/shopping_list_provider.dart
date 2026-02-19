import 'package:meal_planner/core/utils/shopping_list_input_parser.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
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

  Future<void> addItem(String input) async {
    final parsed = ShoppingListInputParser.parse(input);
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.addItem(parsed.information, parsed.quantity);
    // kein state update nötig – Drift Stream triggert UI automatisch
  }

  Future<void> addItemsFromIngredients(List<Ingredient> ingredients) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    for (final ingredient in ingredients) {
      final quantity =
          '${ingredient.amount ?? ''} ${ingredient.unit?.displayName}'.trim();
      await repo.addItem(
        ingredient.name,
        quantity.isEmpty ? null : quantity,
      );
    }
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

