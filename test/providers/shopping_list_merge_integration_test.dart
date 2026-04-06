import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/domain/repositories/shopping_list_repository.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/shopping_list/shopping_list_provider.dart';

/// In-memory fake repo that mimics the behavior of OfflineFirstShoppingListRepository
/// but without sync. Used to verify the merge flow end-to-end.
class FakeShoppingListRepo implements ShoppingListRepository {
  final List<ShoppingListItem> _items = [];
  int _idCounter = 0;

  @override
  Stream<List<ShoppingListItem>> watchItems() async* {
    yield List.of(_items);
  }

  @override
  Future<List<ShoppingListItem>> getItems() async => List.of(_items);

  @override
  Future<ShoppingListItem> addItem(String information, String? quantity) async {
    final item = ShoppingListItem(
      id: 'id-${_idCounter++}',
      groupId: 'g1',
      information: information,
      quantity: quantity,
      isChecked: false,
    );
    _items.add(item);
    return item;
  }

  @override
  Future<void> updateItem(
      String itemId, String information, String? quantity) async {
    final idx = _items.indexWhere((i) => i.id == itemId);
    if (idx == -1) throw Exception('Item not found: $itemId');
    _items[idx] = _items[idx].copyWith(
      information: information,
      quantity: quantity,
    );
  }

  @override
  Future<void> toggleItem(String itemId, bool isChecked) async {}

  @override
  Future<void> removeItem(String itemId) async {}

  @override
  Future<void> removeCheckedItems() async {}
}

void main() {
  late FakeShoppingListRepo repo;
  late ProviderContainer container;

  setUp(() {
    repo = FakeShoppingListRepo();
    container = ProviderContainer(overrides: [
      shoppingListRepositoryProvider.overrideWithValue(repo),
    ]);
  });

  tearDown(() => container.dispose());

  test('addItemsFromIngredients twice — second call merges', () async {
    final ingredient = Ingredient(
      name: 'Cashew-Kerne',
      amount: '160',
      unit: Unit.GRAMM,
    );

    final notifier = container.read(shoppingListActionsProvider.notifier);

    // First call: creates item
    final firstMerges = await notifier.addItemsFromIngredients([ingredient]);
    expect(firstMerges, isEmpty);
    expect(repo._items, hasLength(1));
    expect(repo._items.first.information, 'Cashew-Kerne');
    expect(repo._items.first.quantity, '160 g');

    // Second call: should merge → 320g
    final secondMerges = await notifier.addItemsFromIngredients([ingredient]);
    expect(secondMerges, hasLength(1));
    expect(secondMerges.first.newQuantity, '320g');

    // CRITICAL: list should still have only 1 item with the merged quantity
    expect(repo._items, hasLength(1),
        reason: 'No new item should be added on merge');
    expect(repo._items.first.quantity, '320g',
        reason: 'Item quantity should be updated to merged value');
  });
}
