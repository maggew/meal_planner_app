// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalShoppingItemsTable extends LocalShoppingItems
    with TableInfo<$LocalShoppingItemsTable, LocalShoppingItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalShoppingItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
      'local_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _remoteIdMeta =
      const VerificationMeta('remoteId');
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
      'remote_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _informationMeta =
      const VerificationMeta('information');
  @override
  late final GeneratedColumn<String> information = GeneratedColumn<String>(
      'information', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<String> quantity = GeneratedColumn<String>(
      'quantity', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCheckedMeta =
      const VerificationMeta('isChecked');
  @override
  late final GeneratedColumn<bool> isChecked = GeneratedColumn<bool>(
      'is_checked', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_checked" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pendingCreate'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        remoteId,
        groupId,
        information,
        quantity,
        isChecked,
        syncStatus,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_shopping_items';
  @override
  VerificationContext validateIntegrity(Insertable<LocalShoppingItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('remote_id')) {
      context.handle(_remoteIdMeta,
          remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('information')) {
      context.handle(
          _informationMeta,
          information.isAcceptableOrUnknown(
              data['information']!, _informationMeta));
    } else if (isInserting) {
      context.missing(_informationMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    }
    if (data.containsKey('is_checked')) {
      context.handle(_isCheckedMeta,
          isChecked.isAcceptableOrUnknown(data['is_checked']!, _isCheckedMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  LocalShoppingItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalShoppingItem(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      information: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}information'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}quantity']),
      isChecked: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_checked'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalShoppingItemsTable createAlias(String alias) {
    return $LocalShoppingItemsTable(attachedDatabase, alias);
  }
}

class LocalShoppingItem extends DataClass
    implements Insertable<LocalShoppingItem> {
  final String localId;
  final String? remoteId;
  final String groupId;
  final String information;
  final String? quantity;
  final bool isChecked;
  final String syncStatus;
  final DateTime updatedAt;
  const LocalShoppingItem(
      {required this.localId,
      this.remoteId,
      required this.groupId,
      required this.information,
      this.quantity,
      required this.isChecked,
      required this.syncStatus,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['group_id'] = Variable<String>(groupId);
    map['information'] = Variable<String>(information);
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<String>(quantity);
    }
    map['is_checked'] = Variable<bool>(isChecked);
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalShoppingItemsCompanion toCompanion(bool nullToAbsent) {
    return LocalShoppingItemsCompanion(
      localId: Value(localId),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      groupId: Value(groupId),
      information: Value(information),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      isChecked: Value(isChecked),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalShoppingItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalShoppingItem(
      localId: serializer.fromJson<String>(json['localId']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      information: serializer.fromJson<String>(json['information']),
      quantity: serializer.fromJson<String?>(json['quantity']),
      isChecked: serializer.fromJson<bool>(json['isChecked']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'remoteId': serializer.toJson<String?>(remoteId),
      'groupId': serializer.toJson<String>(groupId),
      'information': serializer.toJson<String>(information),
      'quantity': serializer.toJson<String?>(quantity),
      'isChecked': serializer.toJson<bool>(isChecked),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalShoppingItem copyWith(
          {String? localId,
          Value<String?> remoteId = const Value.absent(),
          String? groupId,
          String? information,
          Value<String?> quantity = const Value.absent(),
          bool? isChecked,
          String? syncStatus,
          DateTime? updatedAt}) =>
      LocalShoppingItem(
        localId: localId ?? this.localId,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        groupId: groupId ?? this.groupId,
        information: information ?? this.information,
        quantity: quantity.present ? quantity.value : this.quantity,
        isChecked: isChecked ?? this.isChecked,
        syncStatus: syncStatus ?? this.syncStatus,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalShoppingItem copyWithCompanion(LocalShoppingItemsCompanion data) {
    return LocalShoppingItem(
      localId: data.localId.present ? data.localId.value : this.localId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      information:
          data.information.present ? data.information.value : this.information,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      isChecked: data.isChecked.present ? data.isChecked.value : this.isChecked,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingItem(')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('information: $information, ')
          ..write('quantity: $quantity, ')
          ..write('isChecked: $isChecked, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, remoteId, groupId, information,
      quantity, isChecked, syncStatus, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalShoppingItem &&
          other.localId == this.localId &&
          other.remoteId == this.remoteId &&
          other.groupId == this.groupId &&
          other.information == this.information &&
          other.quantity == this.quantity &&
          other.isChecked == this.isChecked &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class LocalShoppingItemsCompanion extends UpdateCompanion<LocalShoppingItem> {
  final Value<String> localId;
  final Value<String?> remoteId;
  final Value<String> groupId;
  final Value<String> information;
  final Value<String?> quantity;
  final Value<bool> isChecked;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalShoppingItemsCompanion({
    this.localId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.information = const Value.absent(),
    this.quantity = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalShoppingItemsCompanion.insert({
    required String localId,
    this.remoteId = const Value.absent(),
    required String groupId,
    required String information,
    this.quantity = const Value.absent(),
    this.isChecked = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : localId = Value(localId),
        groupId = Value(groupId),
        information = Value(information),
        updatedAt = Value(updatedAt);
  static Insertable<LocalShoppingItem> custom({
    Expression<String>? localId,
    Expression<String>? remoteId,
    Expression<String>? groupId,
    Expression<String>? information,
    Expression<String>? quantity,
    Expression<bool>? isChecked,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (remoteId != null) 'remote_id': remoteId,
      if (groupId != null) 'group_id': groupId,
      if (information != null) 'information': information,
      if (quantity != null) 'quantity': quantity,
      if (isChecked != null) 'is_checked': isChecked,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalShoppingItemsCompanion copyWith(
      {Value<String>? localId,
      Value<String?>? remoteId,
      Value<String>? groupId,
      Value<String>? information,
      Value<String?>? quantity,
      Value<bool>? isChecked,
      Value<String>? syncStatus,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalShoppingItemsCompanion(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      groupId: groupId ?? this.groupId,
      information: information ?? this.information,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      syncStatus: syncStatus ?? this.syncStatus,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (information.present) {
      map['information'] = Variable<String>(information.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<String>(quantity.value);
    }
    if (isChecked.present) {
      map['is_checked'] = Variable<bool>(isChecked.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalShoppingItemsCompanion(')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('information: $information, ')
          ..write('quantity: $quantity, ')
          ..write('isChecked: $isChecked, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalShoppingItemsTable localShoppingItems =
      $LocalShoppingItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localShoppingItems];
}

typedef $$LocalShoppingItemsTableCreateCompanionBuilder
    = LocalShoppingItemsCompanion Function({
  required String localId,
  Value<String?> remoteId,
  required String groupId,
  required String information,
  Value<String?> quantity,
  Value<bool> isChecked,
  Value<String> syncStatus,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LocalShoppingItemsTableUpdateCompanionBuilder
    = LocalShoppingItemsCompanion Function({
  Value<String> localId,
  Value<String?> remoteId,
  Value<String> groupId,
  Value<String> information,
  Value<String?> quantity,
  Value<bool> isChecked,
  Value<String> syncStatus,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalShoppingItemsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalShoppingItemsTable> {
  $$LocalShoppingItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get information => $composableBuilder(
      column: $table.information, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalShoppingItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalShoppingItemsTable> {
  $$LocalShoppingItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get remoteId => $composableBuilder(
      column: $table.remoteId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get information => $composableBuilder(
      column: $table.information, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isChecked => $composableBuilder(
      column: $table.isChecked, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalShoppingItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalShoppingItemsTable> {
  $$LocalShoppingItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get information => $composableBuilder(
      column: $table.information, builder: (column) => column);

  GeneratedColumn<String> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<bool> get isChecked =>
      $composableBuilder(column: $table.isChecked, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalShoppingItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalShoppingItemsTable,
    LocalShoppingItem,
    $$LocalShoppingItemsTableFilterComposer,
    $$LocalShoppingItemsTableOrderingComposer,
    $$LocalShoppingItemsTableAnnotationComposer,
    $$LocalShoppingItemsTableCreateCompanionBuilder,
    $$LocalShoppingItemsTableUpdateCompanionBuilder,
    (
      LocalShoppingItem,
      BaseReferences<_$AppDatabase, $LocalShoppingItemsTable, LocalShoppingItem>
    ),
    LocalShoppingItem,
    PrefetchHooks Function()> {
  $$LocalShoppingItemsTableTableManager(
      _$AppDatabase db, $LocalShoppingItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalShoppingItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalShoppingItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalShoppingItemsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> localId = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> information = const Value.absent(),
            Value<String?> quantity = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalShoppingItemsCompanion(
            localId: localId,
            remoteId: remoteId,
            groupId: groupId,
            information: information,
            quantity: quantity,
            isChecked: isChecked,
            syncStatus: syncStatus,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String localId,
            Value<String?> remoteId = const Value.absent(),
            required String groupId,
            required String information,
            Value<String?> quantity = const Value.absent(),
            Value<bool> isChecked = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalShoppingItemsCompanion.insert(
            localId: localId,
            remoteId: remoteId,
            groupId: groupId,
            information: information,
            quantity: quantity,
            isChecked: isChecked,
            syncStatus: syncStatus,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalShoppingItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalShoppingItemsTable,
    LocalShoppingItem,
    $$LocalShoppingItemsTableFilterComposer,
    $$LocalShoppingItemsTableOrderingComposer,
    $$LocalShoppingItemsTableAnnotationComposer,
    $$LocalShoppingItemsTableCreateCompanionBuilder,
    $$LocalShoppingItemsTableUpdateCompanionBuilder,
    (
      LocalShoppingItem,
      BaseReferences<_$AppDatabase, $LocalShoppingItemsTable, LocalShoppingItem>
    ),
    LocalShoppingItem,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalShoppingItemsTableTableManager get localShoppingItems =>
      $$LocalShoppingItemsTableTableManager(_db, _db.localShoppingItems);
}
