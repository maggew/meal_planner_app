import 'package:meal_planner/domain/entities/shopping_list_item.dart';

abstract class ShoppingListRepository {
  Future<List<ShoppingListItem>> getItems();
  Future<ShoppingListItem> addItem(String information);
  Future<void> toggleItem(String itemId, bool isChecked);
  Future<void> removeItem(String itemId);
  Future<void> removeCheckedItems();
}
