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

class $LocalRecipesTable extends LocalRecipes
    with TableInfo<$LocalRecipesTable, LocalRecipe> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalRecipesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _portionsMeta =
      const VerificationMeta('portions');
  @override
  late final GeneratedColumn<int> portions = GeneratedColumn<int>(
      'portions', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _instructionsMeta =
      const VerificationMeta('instructions');
  @override
  late final GeneratedColumn<String> instructions = GeneratedColumn<String>(
      'instructions', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageUrlMeta =
      const VerificationMeta('imageUrl');
  @override
  late final GeneratedColumn<String> imageUrl = GeneratedColumn<String>(
      'image_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoriesJsonMeta =
      const VerificationMeta('categoriesJson');
  @override
  late final GeneratedColumn<String> categoriesJson = GeneratedColumn<String>(
      'categories_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ingredientSectionsJsonMeta =
      const VerificationMeta('ingredientSectionsJson');
  @override
  late final GeneratedColumn<String> ingredientSectionsJson =
      GeneratedColumn<String>('ingredient_sections_json', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timersJsonMeta =
      const VerificationMeta('timersJson');
  @override
  late final GeneratedColumn<String> timersJson = GeneratedColumn<String>(
      'timers_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDeletedMeta =
      const VerificationMeta('isDeleted');
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
      'is_deleted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_deleted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _cachedAtMeta =
      const VerificationMeta('cachedAt');
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
      'cached_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        groupId,
        name,
        portions,
        instructions,
        imageUrl,
        createdAt,
        categoriesJson,
        ingredientSectionsJson,
        timersJson,
        isDeleted,
        cachedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_recipes';
  @override
  VerificationContext validateIntegrity(Insertable<LocalRecipe> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('portions')) {
      context.handle(_portionsMeta,
          portions.isAcceptableOrUnknown(data['portions']!, _portionsMeta));
    } else if (isInserting) {
      context.missing(_portionsMeta);
    }
    if (data.containsKey('instructions')) {
      context.handle(
          _instructionsMeta,
          instructions.isAcceptableOrUnknown(
              data['instructions']!, _instructionsMeta));
    } else if (isInserting) {
      context.missing(_instructionsMeta);
    }
    if (data.containsKey('image_url')) {
      context.handle(_imageUrlMeta,
          imageUrl.isAcceptableOrUnknown(data['image_url']!, _imageUrlMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('categories_json')) {
      context.handle(
          _categoriesJsonMeta,
          categoriesJson.isAcceptableOrUnknown(
              data['categories_json']!, _categoriesJsonMeta));
    } else if (isInserting) {
      context.missing(_categoriesJsonMeta);
    }
    if (data.containsKey('ingredient_sections_json')) {
      context.handle(
          _ingredientSectionsJsonMeta,
          ingredientSectionsJson.isAcceptableOrUnknown(
              data['ingredient_sections_json']!, _ingredientSectionsJsonMeta));
    } else if (isInserting) {
      context.missing(_ingredientSectionsJsonMeta);
    }
    if (data.containsKey('timers_json')) {
      context.handle(
          _timersJsonMeta,
          timersJson.isAcceptableOrUnknown(
              data['timers_json']!, _timersJsonMeta));
    } else if (isInserting) {
      context.missing(_timersJsonMeta);
    }
    if (data.containsKey('is_deleted')) {
      context.handle(_isDeletedMeta,
          isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta));
    }
    if (data.containsKey('cached_at')) {
      context.handle(_cachedAtMeta,
          cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta));
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalRecipe map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalRecipe(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      portions: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}portions'])!,
      instructions: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}instructions'])!,
      imageUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}image_url']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      categoriesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}categories_json'])!,
      ingredientSectionsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ingredient_sections_json'])!,
      timersJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timers_json'])!,
      isDeleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_deleted'])!,
      cachedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}cached_at'])!,
    );
  }

  @override
  $LocalRecipesTable createAlias(String alias) {
    return $LocalRecipesTable(attachedDatabase, alias);
  }
}

class LocalRecipe extends DataClass implements Insertable<LocalRecipe> {
  final String id;
  final String groupId;
  final String name;
  final int portions;
  final String instructions;
  final String? imageUrl;
  final DateTime createdAt;
  final String categoriesJson;
  final String ingredientSectionsJson;
  final String timersJson;
  final bool isDeleted;
  final DateTime cachedAt;
  const LocalRecipe(
      {required this.id,
      required this.groupId,
      required this.name,
      required this.portions,
      required this.instructions,
      this.imageUrl,
      required this.createdAt,
      required this.categoriesJson,
      required this.ingredientSectionsJson,
      required this.timersJson,
      required this.isDeleted,
      required this.cachedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['group_id'] = Variable<String>(groupId);
    map['name'] = Variable<String>(name);
    map['portions'] = Variable<int>(portions);
    map['instructions'] = Variable<String>(instructions);
    if (!nullToAbsent || imageUrl != null) {
      map['image_url'] = Variable<String>(imageUrl);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['categories_json'] = Variable<String>(categoriesJson);
    map['ingredient_sections_json'] = Variable<String>(ingredientSectionsJson);
    map['timers_json'] = Variable<String>(timersJson);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  LocalRecipesCompanion toCompanion(bool nullToAbsent) {
    return LocalRecipesCompanion(
      id: Value(id),
      groupId: Value(groupId),
      name: Value(name),
      portions: Value(portions),
      instructions: Value(instructions),
      imageUrl: imageUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(imageUrl),
      createdAt: Value(createdAt),
      categoriesJson: Value(categoriesJson),
      ingredientSectionsJson: Value(ingredientSectionsJson),
      timersJson: Value(timersJson),
      isDeleted: Value(isDeleted),
      cachedAt: Value(cachedAt),
    );
  }

  factory LocalRecipe.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalRecipe(
      id: serializer.fromJson<String>(json['id']),
      groupId: serializer.fromJson<String>(json['groupId']),
      name: serializer.fromJson<String>(json['name']),
      portions: serializer.fromJson<int>(json['portions']),
      instructions: serializer.fromJson<String>(json['instructions']),
      imageUrl: serializer.fromJson<String?>(json['imageUrl']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      categoriesJson: serializer.fromJson<String>(json['categoriesJson']),
      ingredientSectionsJson:
          serializer.fromJson<String>(json['ingredientSectionsJson']),
      timersJson: serializer.fromJson<String>(json['timersJson']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'groupId': serializer.toJson<String>(groupId),
      'name': serializer.toJson<String>(name),
      'portions': serializer.toJson<int>(portions),
      'instructions': serializer.toJson<String>(instructions),
      'imageUrl': serializer.toJson<String?>(imageUrl),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'categoriesJson': serializer.toJson<String>(categoriesJson),
      'ingredientSectionsJson':
          serializer.toJson<String>(ingredientSectionsJson),
      'timersJson': serializer.toJson<String>(timersJson),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  LocalRecipe copyWith(
          {String? id,
          String? groupId,
          String? name,
          int? portions,
          String? instructions,
          Value<String?> imageUrl = const Value.absent(),
          DateTime? createdAt,
          String? categoriesJson,
          String? ingredientSectionsJson,
          String? timersJson,
          bool? isDeleted,
          DateTime? cachedAt}) =>
      LocalRecipe(
        id: id ?? this.id,
        groupId: groupId ?? this.groupId,
        name: name ?? this.name,
        portions: portions ?? this.portions,
        instructions: instructions ?? this.instructions,
        imageUrl: imageUrl.present ? imageUrl.value : this.imageUrl,
        createdAt: createdAt ?? this.createdAt,
        categoriesJson: categoriesJson ?? this.categoriesJson,
        ingredientSectionsJson:
            ingredientSectionsJson ?? this.ingredientSectionsJson,
        timersJson: timersJson ?? this.timersJson,
        isDeleted: isDeleted ?? this.isDeleted,
        cachedAt: cachedAt ?? this.cachedAt,
      );
  LocalRecipe copyWithCompanion(LocalRecipesCompanion data) {
    return LocalRecipe(
      id: data.id.present ? data.id.value : this.id,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      name: data.name.present ? data.name.value : this.name,
      portions: data.portions.present ? data.portions.value : this.portions,
      instructions: data.instructions.present
          ? data.instructions.value
          : this.instructions,
      imageUrl: data.imageUrl.present ? data.imageUrl.value : this.imageUrl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      categoriesJson: data.categoriesJson.present
          ? data.categoriesJson.value
          : this.categoriesJson,
      ingredientSectionsJson: data.ingredientSectionsJson.present
          ? data.ingredientSectionsJson.value
          : this.ingredientSectionsJson,
      timersJson:
          data.timersJson.present ? data.timersJson.value : this.timersJson,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecipe(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('portions: $portions, ')
          ..write('instructions: $instructions, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('categoriesJson: $categoriesJson, ')
          ..write('ingredientSectionsJson: $ingredientSectionsJson, ')
          ..write('timersJson: $timersJson, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      groupId,
      name,
      portions,
      instructions,
      imageUrl,
      createdAt,
      categoriesJson,
      ingredientSectionsJson,
      timersJson,
      isDeleted,
      cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalRecipe &&
          other.id == this.id &&
          other.groupId == this.groupId &&
          other.name == this.name &&
          other.portions == this.portions &&
          other.instructions == this.instructions &&
          other.imageUrl == this.imageUrl &&
          other.createdAt == this.createdAt &&
          other.categoriesJson == this.categoriesJson &&
          other.ingredientSectionsJson == this.ingredientSectionsJson &&
          other.timersJson == this.timersJson &&
          other.isDeleted == this.isDeleted &&
          other.cachedAt == this.cachedAt);
}

class LocalRecipesCompanion extends UpdateCompanion<LocalRecipe> {
  final Value<String> id;
  final Value<String> groupId;
  final Value<String> name;
  final Value<int> portions;
  final Value<String> instructions;
  final Value<String?> imageUrl;
  final Value<DateTime> createdAt;
  final Value<String> categoriesJson;
  final Value<String> ingredientSectionsJson;
  final Value<String> timersJson;
  final Value<bool> isDeleted;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const LocalRecipesCompanion({
    this.id = const Value.absent(),
    this.groupId = const Value.absent(),
    this.name = const Value.absent(),
    this.portions = const Value.absent(),
    this.instructions = const Value.absent(),
    this.imageUrl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.categoriesJson = const Value.absent(),
    this.ingredientSectionsJson = const Value.absent(),
    this.timersJson = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalRecipesCompanion.insert({
    required String id,
    required String groupId,
    required String name,
    required int portions,
    required String instructions,
    this.imageUrl = const Value.absent(),
    required DateTime createdAt,
    required String categoriesJson,
    required String ingredientSectionsJson,
    required String timersJson,
    this.isDeleted = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        groupId = Value(groupId),
        name = Value(name),
        portions = Value(portions),
        instructions = Value(instructions),
        createdAt = Value(createdAt),
        categoriesJson = Value(categoriesJson),
        ingredientSectionsJson = Value(ingredientSectionsJson),
        timersJson = Value(timersJson),
        cachedAt = Value(cachedAt);
  static Insertable<LocalRecipe> custom({
    Expression<String>? id,
    Expression<String>? groupId,
    Expression<String>? name,
    Expression<int>? portions,
    Expression<String>? instructions,
    Expression<String>? imageUrl,
    Expression<DateTime>? createdAt,
    Expression<String>? categoriesJson,
    Expression<String>? ingredientSectionsJson,
    Expression<String>? timersJson,
    Expression<bool>? isDeleted,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (groupId != null) 'group_id': groupId,
      if (name != null) 'name': name,
      if (portions != null) 'portions': portions,
      if (instructions != null) 'instructions': instructions,
      if (imageUrl != null) 'image_url': imageUrl,
      if (createdAt != null) 'created_at': createdAt,
      if (categoriesJson != null) 'categories_json': categoriesJson,
      if (ingredientSectionsJson != null)
        'ingredient_sections_json': ingredientSectionsJson,
      if (timersJson != null) 'timers_json': timersJson,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalRecipesCompanion copyWith(
      {Value<String>? id,
      Value<String>? groupId,
      Value<String>? name,
      Value<int>? portions,
      Value<String>? instructions,
      Value<String?>? imageUrl,
      Value<DateTime>? createdAt,
      Value<String>? categoriesJson,
      Value<String>? ingredientSectionsJson,
      Value<String>? timersJson,
      Value<bool>? isDeleted,
      Value<DateTime>? cachedAt,
      Value<int>? rowid}) {
    return LocalRecipesCompanion(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      portions: portions ?? this.portions,
      instructions: instructions ?? this.instructions,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      categoriesJson: categoriesJson ?? this.categoriesJson,
      ingredientSectionsJson:
          ingredientSectionsJson ?? this.ingredientSectionsJson,
      timersJson: timersJson ?? this.timersJson,
      isDeleted: isDeleted ?? this.isDeleted,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (portions.present) {
      map['portions'] = Variable<int>(portions.value);
    }
    if (instructions.present) {
      map['instructions'] = Variable<String>(instructions.value);
    }
    if (imageUrl.present) {
      map['image_url'] = Variable<String>(imageUrl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (categoriesJson.present) {
      map['categories_json'] = Variable<String>(categoriesJson.value);
    }
    if (ingredientSectionsJson.present) {
      map['ingredient_sections_json'] =
          Variable<String>(ingredientSectionsJson.value);
    }
    if (timersJson.present) {
      map['timers_json'] = Variable<String>(timersJson.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalRecipesCompanion(')
          ..write('id: $id, ')
          ..write('groupId: $groupId, ')
          ..write('name: $name, ')
          ..write('portions: $portions, ')
          ..write('instructions: $instructions, ')
          ..write('imageUrl: $imageUrl, ')
          ..write('createdAt: $createdAt, ')
          ..write('categoriesJson: $categoriesJson, ')
          ..write('ingredientSectionsJson: $ingredientSectionsJson, ')
          ..write('timersJson: $timersJson, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('cachedAt: $cachedAt, ')
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
  late final $LocalRecipesTable localRecipes = $LocalRecipesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [localShoppingItems, localRecipes];
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
typedef $$LocalRecipesTableCreateCompanionBuilder = LocalRecipesCompanion
    Function({
  required String id,
  required String groupId,
  required String name,
  required int portions,
  required String instructions,
  Value<String?> imageUrl,
  required DateTime createdAt,
  required String categoriesJson,
  required String ingredientSectionsJson,
  required String timersJson,
  Value<bool> isDeleted,
  required DateTime cachedAt,
  Value<int> rowid,
});
typedef $$LocalRecipesTableUpdateCompanionBuilder = LocalRecipesCompanion
    Function({
  Value<String> id,
  Value<String> groupId,
  Value<String> name,
  Value<int> portions,
  Value<String> instructions,
  Value<String?> imageUrl,
  Value<DateTime> createdAt,
  Value<String> categoriesJson,
  Value<String> ingredientSectionsJson,
  Value<String> timersJson,
  Value<bool> isDeleted,
  Value<DateTime> cachedAt,
  Value<int> rowid,
});

class $$LocalRecipesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalRecipesTable> {
  $$LocalRecipesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get portions => $composableBuilder(
      column: $table.portions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get categoriesJson => $composableBuilder(
      column: $table.categoriesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ingredientSectionsJson => $composableBuilder(
      column: $table.ingredientSectionsJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get timersJson => $composableBuilder(
      column: $table.timersJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalRecipesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalRecipesTable> {
  $$LocalRecipesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get portions => $composableBuilder(
      column: $table.portions, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get instructions => $composableBuilder(
      column: $table.instructions,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get imageUrl => $composableBuilder(
      column: $table.imageUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get categoriesJson => $composableBuilder(
      column: $table.categoriesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ingredientSectionsJson => $composableBuilder(
      column: $table.ingredientSectionsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get timersJson => $composableBuilder(
      column: $table.timersJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
      column: $table.isDeleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
      column: $table.cachedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalRecipesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalRecipesTable> {
  $$LocalRecipesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get portions =>
      $composableBuilder(column: $table.portions, builder: (column) => column);

  GeneratedColumn<String> get instructions => $composableBuilder(
      column: $table.instructions, builder: (column) => column);

  GeneratedColumn<String> get imageUrl =>
      $composableBuilder(column: $table.imageUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get categoriesJson => $composableBuilder(
      column: $table.categoriesJson, builder: (column) => column);

  GeneratedColumn<String> get ingredientSectionsJson => $composableBuilder(
      column: $table.ingredientSectionsJson, builder: (column) => column);

  GeneratedColumn<String> get timersJson => $composableBuilder(
      column: $table.timersJson, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$LocalRecipesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalRecipesTable,
    LocalRecipe,
    $$LocalRecipesTableFilterComposer,
    $$LocalRecipesTableOrderingComposer,
    $$LocalRecipesTableAnnotationComposer,
    $$LocalRecipesTableCreateCompanionBuilder,
    $$LocalRecipesTableUpdateCompanionBuilder,
    (
      LocalRecipe,
      BaseReferences<_$AppDatabase, $LocalRecipesTable, LocalRecipe>
    ),
    LocalRecipe,
    PrefetchHooks Function()> {
  $$LocalRecipesTableTableManager(_$AppDatabase db, $LocalRecipesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalRecipesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalRecipesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalRecipesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> portions = const Value.absent(),
            Value<String> instructions = const Value.absent(),
            Value<String?> imageUrl = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> categoriesJson = const Value.absent(),
            Value<String> ingredientSectionsJson = const Value.absent(),
            Value<String> timersJson = const Value.absent(),
            Value<bool> isDeleted = const Value.absent(),
            Value<DateTime> cachedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalRecipesCompanion(
            id: id,
            groupId: groupId,
            name: name,
            portions: portions,
            instructions: instructions,
            imageUrl: imageUrl,
            createdAt: createdAt,
            categoriesJson: categoriesJson,
            ingredientSectionsJson: ingredientSectionsJson,
            timersJson: timersJson,
            isDeleted: isDeleted,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String groupId,
            required String name,
            required int portions,
            required String instructions,
            Value<String?> imageUrl = const Value.absent(),
            required DateTime createdAt,
            required String categoriesJson,
            required String ingredientSectionsJson,
            required String timersJson,
            Value<bool> isDeleted = const Value.absent(),
            required DateTime cachedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalRecipesCompanion.insert(
            id: id,
            groupId: groupId,
            name: name,
            portions: portions,
            instructions: instructions,
            imageUrl: imageUrl,
            createdAt: createdAt,
            categoriesJson: categoriesJson,
            ingredientSectionsJson: ingredientSectionsJson,
            timersJson: timersJson,
            isDeleted: isDeleted,
            cachedAt: cachedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LocalRecipesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LocalRecipesTable,
    LocalRecipe,
    $$LocalRecipesTableFilterComposer,
    $$LocalRecipesTableOrderingComposer,
    $$LocalRecipesTableAnnotationComposer,
    $$LocalRecipesTableCreateCompanionBuilder,
    $$LocalRecipesTableUpdateCompanionBuilder,
    (
      LocalRecipe,
      BaseReferences<_$AppDatabase, $LocalRecipesTable, LocalRecipe>
    ),
    LocalRecipe,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalShoppingItemsTableTableManager get localShoppingItems =>
      $$LocalShoppingItemsTableTableManager(_db, _db.localShoppingItems);
  $$LocalRecipesTableTableManager get localRecipes =>
      $$LocalRecipesTableTableManager(_db, _db.localRecipes);
}
