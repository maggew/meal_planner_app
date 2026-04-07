import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/repositories/meal_plan_repository.dart';
import 'package:uuid/uuid.dart';

/// Local-only write path for meal plan entries. All persistence happens against
/// the Drift DAO; remote sync is owned by `SyncCoordinator` + `SyncEngine` and
/// runs out-of-band against the same DAO. This class no longer talks to
/// Supabase directly.
class OfflineFirstMealPlanRepository implements MealPlanRepository {
  final MealPlanDao _dao;
  final String _groupId;
  final _uuid = const Uuid();

  OfflineFirstMealPlanRepository({
    required MealPlanDao dao,
    required String groupId,
  })  : _dao = dao,
        _groupId = groupId;

  @override
  Stream<List<MealPlanEntry>> watchEntriesForDate(DateTime date) {
    return _dao
        .watchEntriesForDate(_groupId, _dateToString(date))
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<void> addEntry({
    required DateTime date,
    required MealType mealType,
    String? recipeId,
    String? customName,
    List<String> cookIds = const [],
  }) async {
    final localId = _uuid.v4();
    final dateStr = _dateToString(date);
    final now = DateTime.now();
    await _dao.upsertEntry(LocalMealPlanEntriesCompanion(
      localId: Value(localId),
      groupId: Value(_groupId),
      recipeId: Value(recipeId ?? ''),
      customName: Value(customName),
      date: Value(dateStr),
      mealType: Value(mealType.value),
      cookIdsJson: Value(_encodeCookIds(cookIds)),
      syncStatus: const Value('pendingCreate'),
      updatedAt: Value(now),
    ));
  }

  @override
  Future<void> updateEntry(
    String localId, {
    String? recipeId,
    String? customName,
    List<String> cookIds = const [],
  }) async {
    final existing = await _dao.getEntryByLocalId(localId);
    if (existing == null) return;

    await _dao.updateEntry(
      localId,
      recipeId: recipeId ?? '',
      customName: customName,
      cookIdsJson: _encodeCookIds(cookIds),
      keepPendingCreate: existing.remoteId == null,
    );
  }

  @override
  Future<void> setCookIds(String localId, List<String> cookIds) async {
    await _dao.updateCookIds(localId, _encodeCookIds(cookIds));
  }

  @override
  Future<void> removeEntry(String localId) async {
    final entry = await _dao.getEntryByLocalId(localId);
    if (entry == null) return;

    await _dao.markAsDeleted(localId);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  MealPlanEntry _toEntity(LocalMealPlanEntry row) {
    final parts = row.date.split('-');
    return MealPlanEntry(
      id: row.localId,
      remoteId: row.remoteId,
      groupId: row.groupId,
      recipeId: row.recipeId.isEmpty ? null : row.recipeId,
      customName: row.customName,
      date: DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      ),
      mealType: MealType.fromValue(row.mealType),
      cookIds: _decodeCookIds(row.cookIdsJson),
    );
  }

  static String? _encodeCookIds(List<String> ids) {
    if (ids.isEmpty) return null;
    return jsonEncode(ids);
  }

  static List<String> _decodeCookIds(String? json) {
    if (json == null) return const [];
    return (jsonDecode(json) as List<dynamic>).cast<String>();
  }

  static String _dateToString(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
