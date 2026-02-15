import 'package:meal_planner/core/utils/shopping_list_input_parser.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shopping_list_provider.g.dart';

@Riverpod(keepAlive: true)
class ShoppingList extends _$ShoppingList {
  @override
  FutureOr<List<ShoppingListItem>> build() async {
    final repo = ref.read(shoppingListRepositoryProvider);
    return await repo.getItems();
  }

  Future<void> addItem(String input) async {
    final parsed = ShoppingListInputParser.parse(input);
    final repo = ref.read(shoppingListRepositoryProvider);
    final newItem = await repo.addItem(parsed.information, parsed.quantity);

    final current = state.value ?? [];
    state = AsyncData([...current, newItem]);
  }

  Future<void> toggleItem(String itemId, bool isChecked) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.toggleItem(itemId, isChecked);

    final current = state.value ?? [];
    state = AsyncData([
      for (final item in current)
        if (item.id == itemId) item.copyWith(isChecked: isChecked) else item,
    ]);
  }

  Future<void> removeItem(String itemId) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.removeItem(itemId);

    final current = state.value ?? [];
    state = AsyncData(current.where((item) => item.id != itemId).toList());
  }

  Future<void> removeCheckedItems() async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.removeCheckedItems();

    final current = state.value ?? [];
    state = AsyncData(current.where((item) => !item.isChecked).toList());
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final repo = ref.read(shoppingListRepositoryProvider);
    state = AsyncData(await repo.getItems());
  }
}
