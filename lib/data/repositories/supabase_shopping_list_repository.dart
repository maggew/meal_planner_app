import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/data/model/shopping_list_item_model.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/domain/repositories/shopping_list_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseShoppingListRepository implements ShoppingListRepository {
  final SupabaseClient _supabase;
  final String _groupId;

  SupabaseShoppingListRepository({
    required SupabaseClient supabase,
    required String groupId,
  })  : _supabase = supabase,
        _groupId = groupId;

  @override
  Future<List<ShoppingListItem>> getItems() async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.shoppingListItemsTable)
          .select()
          .eq(SupabaseConstants.shoppingListItemGroupId, _groupId)
          .order(SupabaseConstants.shoppingListItemIsChecked)
          .order(SupabaseConstants.shoppingListItemInformation);

      return response
          .map((data) => ShoppingListItemModel.fromSupabase(data).toEntity())
          .toList();
    } catch (e) {
      throw Exception('Fehler beim Laden der Einkaufsliste: $e');
    }
  }

  @override
  Future<ShoppingListItem> addItem(String information, String? quantity) async {
    try {
      final response = await _supabase
          .from(SupabaseConstants.shoppingListItemsTable)
          .insert({
            SupabaseConstants.shoppingListItemGroupId: _groupId,
            SupabaseConstants.shoppingListItemInformation: information,
            SupabaseConstants.shoppingListItemQuantity: quantity,
            SupabaseConstants.shoppingListItemIsChecked: false,
          })
          .select()
          .single();

      return ShoppingListItemModel.fromSupabase(response).toEntity();
    } catch (e) {
      throw Exception('Fehler beim Hinzufügen: $e');
    }
  }

  @override
  Future<void> toggleItem(String itemId, bool isChecked) async {
    try {
      await _supabase
          .from(SupabaseConstants.shoppingListItemsTable)
          .update({SupabaseConstants.shoppingListItemIsChecked: isChecked}).eq(
              SupabaseConstants.shoppingListItemId, itemId);
    } catch (e) {
      throw Exception('Fehler beim Aktualisieren: $e');
    }
  }

  @override
  Future<void> removeItem(String itemId) async {
    try {
      await _supabase
          .from(SupabaseConstants.shoppingListItemsTable)
          .delete()
          .eq(SupabaseConstants.shoppingListItemId, itemId);
    } catch (e) {
      throw Exception('Fehler beim Löschen: $e');
    }
  }

  @override
  Future<void> removeCheckedItems() async {
    try {
      await _supabase
          .from(SupabaseConstants.shoppingListItemsTable)
          .delete()
          .eq(SupabaseConstants.shoppingListItemGroupId, _groupId)
          .eq(SupabaseConstants.shoppingListItemIsChecked, true);
    } catch (e) {
      throw Exception('Fehler beim Entfernen abgehakter Items: $e');
    }
  }
}
