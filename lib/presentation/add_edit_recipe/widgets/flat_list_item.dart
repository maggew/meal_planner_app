import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_form_item.dart';
import 'package:meal_planner/presentation/add_edit_recipe/form/ingredient_section_form.dart';

enum FlatListItemType { header, ingredient, addButton }

class FlatListItem {
  final FlatListItemType type;
  final int sectionIndex;
  final int? itemIndex;
  final IngredientFormItem? item;
  final IngredientSectionForm? section;

  FlatListItem._({
    required this.type,
    required this.sectionIndex,
    this.itemIndex,
    this.item,
    this.section,
  });

  factory FlatListItem.header(
      {required int sectionIndex, required IngredientSectionForm section}) {
    return FlatListItem._(
      type: FlatListItemType.header,
      sectionIndex: sectionIndex,
      section: section,
    );
  }

  factory FlatListItem.ingredient({
    required int sectionIndex,
    required int itemIndex,
    required IngredientFormItem item,
  }) {
    return FlatListItem._(
      type: FlatListItemType.ingredient,
      sectionIndex: sectionIndex,
      itemIndex: itemIndex,
      item: item,
    );
  }

  factory FlatListItem.addButton({
    required int sectionIndex,
  }) {
    return FlatListItem._(
      type: FlatListItemType.addButton,
      sectionIndex: sectionIndex,
    );
  }
}
