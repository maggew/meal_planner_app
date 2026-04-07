import 'package:drift/drift.dart';
import 'package:meal_planner/core/database/app_database.dart';
import 'package:meal_planner/core/database/tables/sync_meta_table.dart';
import 'package:meal_planner/data/sync/sync_engine.dart';

part 'sync_meta_dao.g.dart';

@DriftAccessor(tables: [SyncMeta])
class SyncMetaDao extends DatabaseAccessor<AppDatabase>
    with _$SyncMetaDaoMixin
    implements SyncMetaStore {
  SyncMetaDao(super.db);

  /// Returns the upper bound of the last successful pull for
  /// `(featureKey, scopeKey)`, or `null` if no pull has ever succeeded.
  Future<DateTime?> getLastPulledAt(String featureKey, String scopeKey) async {
    final row = await (select(syncMeta)
          ..where((t) =>
              t.featureKey.equals(featureKey) & t.scopeKey.equals(scopeKey)))
        .getSingleOrNull();
    return row?.lastPulledAt;
  }

  /// Records `pulledAt` as the new upper bound for the next pull window.
  Future<void> setLastPulledAt(
    String featureKey,
    String scopeKey,
    DateTime pulledAt,
  ) async {
    await into(syncMeta).insert(
      SyncMetaCompanion.insert(
        featureKey: featureKey,
        scopeKey: scopeKey,
        lastPulledAt: Value(pulledAt),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }
}
