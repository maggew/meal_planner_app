import 'package:drift/drift.dart';

/// Stores per-(feature, scope) sync bookkeeping.
///
/// One row per `(featureKey, scopeKey)`. `lastPulledAt` is the upper bound
/// of the most recent successful pull window — the engine uses it as the
/// `since` cursor for the next pull.
class SyncMeta extends Table {
  TextColumn get featureKey => text()();
  TextColumn get scopeKey => text()();
  DateTimeColumn get lastPulledAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {featureKey, scopeKey};
}
