import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:meal_planner/core/constants/supabase_constants.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/daos/meal_plan_dao.dart';
import 'package:meal_planner/data/model/meal_plan_entry_model.dart';
import 'package:meal_planner/domain/entities/meal_plan_entry.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/repositories/meal_plan_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class OfflineFirstMealPlanRepository implements MealPlanRepository {
  final MealPlanDao _dao;
  final SupabaseClient _supabase;
  final String _groupId;
  final _uuid = const Uuid();

  Timer? _timer;
  bool _isSyncing = false;
  int _currentYear = 0;
  int _currentMonth = 0;

  OfflineFirstMealPlanRepository({
    required MealPlanDao dao,
    required SupabaseClient supabase,
    required String groupId,
  })  : _dao = dao,
        _supabase = supabase,
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

  // ── Sync ───────────────────────────────────────────────────────────────────

  void startPeriodicSync(int year, int month) {
    _currentYear = year;
    _currentMonth = month;
    _timer?.cancel();
    sync(_currentYear, _currentMonth);
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => sync(_currentYear, _currentMonth),
    );
  }

  void updateMonth(int year, int month) {
    _currentYear = year;
    _currentMonth = month;
    sync(_currentYear, _currentMonth);
  }

  void stopPeriodicSync() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> sync(int year, int month) async {
    if (_isSyncing) return;
    _isSyncing = true;
    try {
      await syncPending();
      await pullRemoteForMonth(year, month);
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> syncPending() async {
    final pending = await _dao.getPendingEntries(_groupId);

    for (final entry in pending) {
      try {
        switch (entry.syncStatus) {
          case 'pendingCreate':
            final response = await _supabase
                .from(SupabaseConstants.mealPlanEntriesTable)
                .insert({
                  SupabaseConstants.mealPlanEntryGroupId: _groupId,
                  SupabaseConstants.mealPlanEntryRecipeId:
                      entry.recipeId.isEmpty ? null : entry.recipeId,
                  SupabaseConstants.mealPlanEntryCustomName: entry.customName,
                  SupabaseConstants.mealPlanEntryDate: entry.date,
                  SupabaseConstants.mealPlanEntryMealType: entry.mealType,
                  SupabaseConstants.mealPlanEntryUpdatedAt:
                      entry.updatedAt.toIso8601String(),
                })
                .select()
                .single();
            final remoteId =
                response[SupabaseConstants.mealPlanEntryId] as String;
            await _dao.updateSyncStatus(entry.localId, 'synced',
                remoteId: remoteId);

          case 'pendingUpdate':
            if (entry.remoteId != null) {
              List<String> cookIds;
              try {
                cookIds = entry.cookIdsJson != null
                    ? (jsonDecode(entry.cookIdsJson!) as List<dynamic>)
                        .cast<String>()
                    : <String>[];
              } catch (_) {
                cookIds = <String>[];
              }
              await _supabase
                  .from(SupabaseConstants.mealPlanEntriesTable)
                  .update({
                    SupabaseConstants.mealPlanEntryRecipeId:
                        entry.recipeId.isEmpty ? null : entry.recipeId,
                    SupabaseConstants.mealPlanEntryCustomName: entry.customName,
                    SupabaseConstants.mealPlanEntryCookIds: cookIds,
                    SupabaseConstants.mealPlanEntryUpdatedAt:
                        entry.updatedAt.toIso8601String(),
                  })
                  .eq(SupabaseConstants.mealPlanEntryId, entry.remoteId!);
              await _dao.updateSyncStatus(entry.localId, 'synced',
                  remoteId: entry.remoteId);
            }

          case 'pendingDelete':
            if (entry.remoteId != null) {
              await _supabase
                  .from(SupabaseConstants.mealPlanEntriesTable)
                  .delete()
                  .eq(SupabaseConstants.mealPlanEntryId, entry.remoteId!);
            }
            await _dao.hardDeleteEntry(entry.localId);
        }
      } catch (e) {
        debugPrint('[MealPlanSync] Fehler bei ${entry.localId}: $e');
        continue;
      }
    }
  }

  Future<void> pullRemoteForMonth(int year, int month) async {
    try {
      final yearMonth =
          '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}';

      final response = await _supabase
          .from(SupabaseConstants.mealPlanEntriesTable)
          .select()
          .eq(SupabaseConstants.mealPlanEntryGroupId, _groupId)
          .gte(SupabaseConstants.mealPlanEntryDate, '$yearMonth-01')
          .lte(SupabaseConstants.mealPlanEntryDate, '$yearMonth-31');

      final companions = (response as List)
          .cast<Map<String, dynamic>>()
          .map((data) {
            final model = MealPlanEntryModel.fromSupabase(data);
            return LocalMealPlanEntriesCompanion(
              localId: Value(model.id),
              remoteId: Value(model.id),
              groupId: Value(_groupId),
              recipeId: Value(model.recipeId ?? ''),
              customName: Value(model.customName),
              date: Value(model.date),
              mealType: Value(model.mealType),
              cookIdsJson: Value(model.cookIds.isEmpty
                  ? null
                  : jsonEncode(model.cookIds)),
              syncStatus: const Value('synced'),
              updatedAt: Value(DateTime.now()),
            );
          })
          .toList();

      await _dao.replaceAllSynced(_groupId, yearMonth, companions);
    } catch (_) {
      // Pull fehlgeschlagen – lokale Daten bleiben erhalten
    }
  }
}
