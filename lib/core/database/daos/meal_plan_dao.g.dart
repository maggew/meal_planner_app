// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_dao.dart';

// ignore_for_file: type=lint
mixin _$MealPlanDaoMixin on DatabaseAccessor<AppDatabase> {
  $LocalMealPlanEntriesTable get localMealPlanEntries =>
      attachedDatabase.localMealPlanEntries;
  MealPlanDaoManager get managers => MealPlanDaoManager(this);
}

class MealPlanDaoManager {
  final _$MealPlanDaoMixin _db;
  MealPlanDaoManager(this._db);
  $$LocalMealPlanEntriesTableTableManager get localMealPlanEntries =>
      $$LocalMealPlanEntriesTableTableManager(
          _db.attachedDatabase, _db.localMealPlanEntries);
}
