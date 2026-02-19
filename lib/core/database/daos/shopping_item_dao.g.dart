// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item_dao.dart';

// ignore_for_file: type=lint
mixin _$ShoppingItemDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalShoppingItemsTable get localShoppingItems =>
      attachedDatabase.localShoppingItems;
  ShoppingItemDaoManager get managers => ShoppingItemDaoManager(this);
}

class ShoppingItemDaoManager {
  final _$ShoppingItemDaoMixin _db;
  ShoppingItemDaoManager(this._db);
  $$LocalShoppingItemsTableTableManager get localShoppingItems =>
      $$LocalShoppingItemsTableTableManager(
          _db.attachedDatabase, _db.localShoppingItems);
}
