import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/shopping_list_item.dart';
import 'package:meal_planner/domain/services/ingredient_merge_service.dart';

ShoppingListItem _item(
  String name, {
  String? quantity,
  bool isChecked = false,
  String id = '1',
}) {
  return ShoppingListItem(
    id: id,
    groupId: 'g1',
    information: name,
    quantity: quantity,
    isChecked: isChecked,
  );
}

void main() {
  late IngredientMergeService service;

  setUp(() {
    service = IngredientMergeService();
  });

  test('merges same unit — 300g + 200g Mehl → 500g', () {
    final existing = [_item('Mehl', quantity: '300g')];

    final result = service.tryMerge('Mehl', '200g', existing);

    expect(result, isNotNull);
    expect(result!.itemId, '1');
    expect(result.newQuantity, '500g');
    expect(result.oldQuantity, '300g');
    expect(result.itemName, 'Mehl');
  });

  test('returns null when no matching item exists', () {
    final existing = [_item('Butter', quantity: '100g')];

    final result = service.tryMerge('Mehl', '200g', existing);

    expect(result, isNull);
  });

  test('name matching is case-insensitive and trimmed', () {
    final existing = [_item('Mehl', quantity: '300g')];

    final result = service.tryMerge(' mehl ', '200g', existing);

    expect(result, isNotNull);
    expect(result!.newQuantity, '500g');
  });

  test('ignores checked items', () {
    final existing = [_item('Mehl', quantity: '300g', isChecked: true)];

    final result = service.tryMerge('Mehl', '200g', existing);

    expect(result, isNull);
  });

  test('merges g + kg → converts to kg when ≥1000', () {
    final existing = [_item('Mehl', quantity: '500g')];

    final result = service.tryMerge('Mehl', '1kg', existing);

    expect(result, isNotNull);
    expect(result!.newQuantity, '1,5kg');
  });

  test('merges ml + l → converts to l when ≥1000', () {
    final existing = [_item('Milch', quantity: '500ml')];

    final result = service.tryMerge('Milch', '0,5l', existing);

    expect(result, isNotNull);
    expect(result!.newQuantity, '1l');
  });

  test('stays in small unit when below 1000', () {
    final existing = [_item('Mehl', quantity: '300g')];

    final result = service.tryMerge('Mehl', '200g', existing);

    expect(result!.newQuantity, '500g');
  });

  test('switches to large unit at exactly 1000', () {
    final existing = [_item('Mehl', quantity: '800g')];

    final result = service.tryMerge('Mehl', '200g', existing);

    expect(result!.newQuantity, '1kg');
  });

  test('no-unit and Stk. are compatible — result has no unit', () {
    final existing = [_item('Tomaten', quantity: '2')];

    final result = service.tryMerge('Tomaten', '3 Stk.', existing);

    expect(result, isNotNull);
    expect(result!.newQuantity, '5');
  });

  test('incompatible units → no merge', () {
    final existing = [_item('Tomaten', quantity: '500g')];

    final result = service.tryMerge('Tomaten', '2 Stk.', existing);

    expect(result, isNull);
  });

  test('both no quantity → merge with null quantity', () {
    final existing = [_item('Salz')];

    final result = service.tryMerge('Salz', null, existing);

    expect(result, isNotNull);
    expect(result!.newQuantity, isNull);
    expect(result.itemId, '1');
  });

  test('one has quantity, other does not → no merge', () {
    final existing = [_item('Salz')];

    final result = service.tryMerge('Salz', '200g', existing);

    expect(result, isNull);
  });

  test('decimal amounts with comma — 1,5kg + 0,5kg → 2kg', () {
    final existing = [_item('Mehl', quantity: '1,5kg')];

    final result = service.tryMerge('Mehl', '0,5kg', existing);

    expect(result!.newQuantity, '2kg');
  });

  test('merges with first matching unchecked item', () {
    final existing = [
      _item('Mehl', quantity: '100g', isChecked: true, id: '1'),
      _item('Mehl', quantity: '300g', id: '2'),
      _item('Mehl', quantity: '50g', id: '3'),
    ];

    final result = service.tryMerge('Mehl', '200g', existing);

    expect(result, isNotNull);
    expect(result!.itemId, '2');
    expect(result.newQuantity, '500g');
  });

  test('Stk. + Stk. merges', () {
    final existing = [_item('Eier', quantity: '3 Stk.')];

    final result = service.tryMerge('Eier', '6 Stk.', existing);

    expect(result, isNotNull);
    expect(result!.newQuantity, '9 Stk.');
  });

  test('quantity with space — "500 g" is parsed correctly', () {
    final existing = [_item('Mehl', quantity: '500 g')];

    final result = service.tryMerge('Mehl', '300 g', existing);

    expect(result, isNotNull);
    expect(result!.newQuantity, '800g');
  });
}
