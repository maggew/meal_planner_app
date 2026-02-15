import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';

class ShoppingListItemModel extends ShoppingListItem {
  ShoppingListItemModel({
    required super.id,
    required super.groupId,
    required super.information,
    required super.isChecked,
    super.quantity,
  });

  Map<String, dynamic> toSupabaseInsert({required String groupId}) {
    return {
      SupabaseConstants.shoppingListItemGroupId: groupId,
      SupabaseConstants.shoppingListItemInformation: information,
      SupabaseConstants.shoppingListItemQuantity: quantity,
      SupabaseConstants.shoppingListItemIsChecked: isChecked,
    };
  }

  factory ShoppingListItemModel.fromSupabase(Map<String, dynamic> data) {
    return ShoppingListItemModel(
      id: data[SupabaseConstants.shoppingListItemId] as String,
      groupId: data[SupabaseConstants.shoppingListItemGroupId] as String,
      information:
          data[SupabaseConstants.shoppingListItemInformation] as String,
      quantity: data[SupabaseConstants.shoppingListItemQuantity] as String?,
      isChecked:
          data[SupabaseConstants.shoppingListItemIsChecked] as bool? ?? false,
    );
  }

  factory ShoppingListItemModel.fromEntity(ShoppingListItem item) {
    return ShoppingListItemModel(
      id: item.id,
      groupId: item.groupId,
      information: item.information,
      quantity: item.quantity,
      isChecked: item.isChecked,
    );
  }

  ShoppingListItem toEntity() {
    return ShoppingListItem(
      id: id,
      groupId: groupId,
      information: information,
      quantity: quantity,
      isChecked: isChecked,
    );
  }
}
