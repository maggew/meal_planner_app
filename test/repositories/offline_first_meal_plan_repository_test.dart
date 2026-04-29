import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/data/repositories/offline_first_meal_plan_repository.dart';
import 'package:meal_planner/data/sync/local_sync_status.dart';
import 'package:meal_planner/data/sync/meal_plan_local_store.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:mocktail/mocktail.dart';

class _MockDao extends Mock implements MealPlanDao {}

MealPlanRow _row({
  required String localId,
  String recipeId = 'r1',
  String date = '2026-04-15',
  String mealType = 'lunch',
  LocalSyncStatus syncStatus = LocalSyncStatus.synced,
  String? remoteId = 'rem1',
}) =>
    MealPlanRow(
      localId: localId,
      remoteId: remoteId,
      recipeId: recipeId,
      customName: null,
      date: date,
      mealType: mealType,
      cookIds: const [],
      syncStatus: syncStatus,
      updatedAt: DateTime(2026, 4, 1, 12),
    );

void main() {
  late _MockDao dao;
  late OfflineFirstMealPlanRepository repo;

  setUp(() {
    dao = _MockDao();
    repo = OfflineFirstMealPlanRepository(dao: dao, groupId: 'g1');
  });

  group('moveEntry', () {
    test('persists new date and mealType when entry exists', () async {
      when(() => dao.getEntryByLocalId('a'))
          .thenAnswer((_) async => _row(localId: 'a'));
      when(() => dao.moveEntry(
            any(),
            date: any(named: 'date'),
            mealType: any(named: 'mealType'),
            keepPendingCreate: any(named: 'keepPendingCreate'),
          )).thenAnswer((_) async {});

      final moved = await repo.moveEntry(
        'a',
        date: DateTime(2026, 4, 17),
        mealType: MealType.dinner,
      );

      expect(moved, isTrue);
      verify(() => dao.moveEntry(
            'a',
            date: '2026-04-17',
            mealType: 'dinner',
            keepPendingCreate: false,
          )).called(1);
    });

    test('returns false without touching DAO when entry is missing', () async {
      when(() => dao.getEntryByLocalId('missing'))
          .thenAnswer((_) async => null);

      final moved = await repo.moveEntry(
        'missing',
        date: DateTime(2026, 4, 17),
        mealType: MealType.dinner,
      );

      expect(moved, isFalse);
      verifyNever(() => dao.moveEntry(
            any(),
            date: any(named: 'date'),
            mealType: any(named: 'mealType'),
            keepPendingCreate: any(named: 'keepPendingCreate'),
          ));
    });
  });
}
