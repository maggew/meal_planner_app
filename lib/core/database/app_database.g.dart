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
  static const VerificationMeta _carbTagsJsonMeta =
      const VerificationMeta('carbTagsJson');
  @override
  late final GeneratedColumn<String> carbTagsJson = GeneratedColumn<String>(
      'carb_tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
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
        carbTagsJson,
        updatedAt,
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
    if (data.containsKey('carb_tags_json')) {
      context.handle(
          _carbTagsJsonMeta,
          carbTagsJson.isAcceptableOrUnknown(
              data['carb_tags_json']!, _carbTagsJsonMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
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
      carbTagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}carb_tags_json'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
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
  final String carbTagsJson;
  final DateTime? updatedAt;
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
      required this.carbTagsJson,
      this.updatedAt,
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
    map['carb_tags_json'] = Variable<String>(carbTagsJson);
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
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
      carbTagsJson: Value(carbTagsJson),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
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
      carbTagsJson: serializer.fromJson<String>(json['carbTagsJson']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
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
      'carbTagsJson': serializer.toJson<String>(carbTagsJson),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
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
          String? carbTagsJson,
          Value<DateTime?> updatedAt = const Value.absent(),
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
        carbTagsJson: carbTagsJson ?? this.carbTagsJson,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
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
      carbTagsJson: data.carbTagsJson.present
          ? data.carbTagsJson.value
          : this.carbTagsJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
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
          ..write('carbTagsJson: $carbTagsJson, ')
          ..write('updatedAt: $updatedAt, ')
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
      carbTagsJson,
      updatedAt,
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
          other.carbTagsJson == this.carbTagsJson &&
          other.updatedAt == this.updatedAt &&
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
  final Value<String> carbTagsJson;
  final Value<DateTime?> updatedAt;
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
    this.carbTagsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
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
    this.carbTagsJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
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
    Expression<String>? carbTagsJson,
    Expression<DateTime>? updatedAt,
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
      if (carbTagsJson != null) 'carb_tags_json': carbTagsJson,
      if (updatedAt != null) 'updated_at': updatedAt,
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
      Value<String>? carbTagsJson,
      Value<DateTime?>? updatedAt,
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
      carbTagsJson: carbTagsJson ?? this.carbTagsJson,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (carbTagsJson.present) {
      map['carb_tags_json'] = Variable<String>(carbTagsJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
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
          ..write('carbTagsJson: $carbTagsJson, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalMealPlanEntriesTable extends LocalMealPlanEntries
    with TableInfo<$LocalMealPlanEntriesTable, LocalMealPlanEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalMealPlanEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _recipeIdMeta =
      const VerificationMeta('recipeId');
  @override
  late final GeneratedColumn<String> recipeId = GeneratedColumn<String>(
      'recipe_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _customNameMeta =
      const VerificationMeta('customName');
  @override
  late final GeneratedColumn<String> customName = GeneratedColumn<String>(
      'custom_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
      'date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mealTypeMeta =
      const VerificationMeta('mealType');
  @override
  late final GeneratedColumn<String> mealType = GeneratedColumn<String>(
      'meal_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cookIdsJsonMeta =
      const VerificationMeta('cookIdsJson');
  @override
  late final GeneratedColumn<String> cookIdsJson = GeneratedColumn<String>(
      'cook_ids_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
        recipeId,
        customName,
        date,
        mealType,
        cookIdsJson,
        syncStatus,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_meal_plan_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LocalMealPlanEntry> instance,
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
    if (data.containsKey('recipe_id')) {
      context.handle(_recipeIdMeta,
          recipeId.isAcceptableOrUnknown(data['recipe_id']!, _recipeIdMeta));
    } else if (isInserting) {
      context.missing(_recipeIdMeta);
    }
    if (data.containsKey('custom_name')) {
      context.handle(
          _customNameMeta,
          customName.isAcceptableOrUnknown(
              data['custom_name']!, _customNameMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('meal_type')) {
      context.handle(_mealTypeMeta,
          mealType.isAcceptableOrUnknown(data['meal_type']!, _mealTypeMeta));
    } else if (isInserting) {
      context.missing(_mealTypeMeta);
    }
    if (data.containsKey('cook_ids_json')) {
      context.handle(
          _cookIdsJsonMeta,
          cookIdsJson.isAcceptableOrUnknown(
              data['cook_ids_json']!, _cookIdsJsonMeta));
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
  LocalMealPlanEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalMealPlanEntry(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_id'])!,
      remoteId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}remote_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      recipeId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recipe_id'])!,
      customName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}custom_name']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])!,
      mealType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meal_type'])!,
      cookIdsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cook_ids_json']),
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $LocalMealPlanEntriesTable createAlias(String alias) {
    return $LocalMealPlanEntriesTable(attachedDatabase, alias);
  }
}

class LocalMealPlanEntry extends DataClass
    implements Insertable<LocalMealPlanEntry> {
  final String localId;
  final String? remoteId;
  final String groupId;
  final String recipeId;
  final String? customName;
  final String date;
  final String mealType;
  final String? cookIdsJson;
  final String syncStatus;
  final DateTime updatedAt;
  const LocalMealPlanEntry(
      {required this.localId,
      this.remoteId,
      required this.groupId,
      required this.recipeId,
      this.customName,
      required this.date,
      required this.mealType,
      this.cookIdsJson,
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
    map['recipe_id'] = Variable<String>(recipeId);
    if (!nullToAbsent || customName != null) {
      map['custom_name'] = Variable<String>(customName);
    }
    map['date'] = Variable<String>(date);
    map['meal_type'] = Variable<String>(mealType);
    if (!nullToAbsent || cookIdsJson != null) {
      map['cook_ids_json'] = Variable<String>(cookIdsJson);
    }
    map['sync_status'] = Variable<String>(syncStatus);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocalMealPlanEntriesCompanion toCompanion(bool nullToAbsent) {
    return LocalMealPlanEntriesCompanion(
      localId: Value(localId),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      groupId: Value(groupId),
      recipeId: Value(recipeId),
      customName: customName == null && nullToAbsent
          ? const Value.absent()
          : Value(customName),
      date: Value(date),
      mealType: Value(mealType),
      cookIdsJson: cookIdsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(cookIdsJson),
      syncStatus: Value(syncStatus),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocalMealPlanEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalMealPlanEntry(
      localId: serializer.fromJson<String>(json['localId']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      groupId: serializer.fromJson<String>(json['groupId']),
      recipeId: serializer.fromJson<String>(json['recipeId']),
      customName: serializer.fromJson<String?>(json['customName']),
      date: serializer.fromJson<String>(json['date']),
      mealType: serializer.fromJson<String>(json['mealType']),
      cookIdsJson: serializer.fromJson<String?>(json['cookIdsJson']),
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
      'recipeId': serializer.toJson<String>(recipeId),
      'customName': serializer.toJson<String?>(customName),
      'date': serializer.toJson<String>(date),
      'mealType': serializer.toJson<String>(mealType),
      'cookIdsJson': serializer.toJson<String?>(cookIdsJson),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocalMealPlanEntry copyWith(
          {String? localId,
          Value<String?> remoteId = const Value.absent(),
          String? groupId,
          String? recipeId,
          Value<String?> customName = const Value.absent(),
          String? date,
          String? mealType,
          Value<String?> cookIdsJson = const Value.absent(),
          String? syncStatus,
          DateTime? updatedAt}) =>
      LocalMealPlanEntry(
        localId: localId ?? this.localId,
        remoteId: remoteId.present ? remoteId.value : this.remoteId,
        groupId: groupId ?? this.groupId,
        recipeId: recipeId ?? this.recipeId,
        customName: customName.present ? customName.value : this.customName,
        date: date ?? this.date,
        mealType: mealType ?? this.mealType,
        cookIdsJson: cookIdsJson.present ? cookIdsJson.value : this.cookIdsJson,
        syncStatus: syncStatus ?? this.syncStatus,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  LocalMealPlanEntry copyWithCompanion(LocalMealPlanEntriesCompanion data) {
    return LocalMealPlanEntry(
      localId: data.localId.present ? data.localId.value : this.localId,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      recipeId: data.recipeId.present ? data.recipeId.value : this.recipeId,
      customName:
          data.customName.present ? data.customName.value : this.customName,
      date: data.date.present ? data.date.value : this.date,
      mealType: data.mealType.present ? data.mealType.value : this.mealType,
      cookIdsJson:
          data.cookIdsJson.present ? data.cookIdsJson.value : this.cookIdsJson,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalMealPlanEntry(')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('recipeId: $recipeId, ')
          ..write('customName: $customName, ')
          ..write('date: $date, ')
          ..write('mealType: $mealType, ')
          ..write('cookIdsJson: $cookIdsJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(localId, remoteId, groupId, recipeId,
      customName, date, mealType, cookIdsJson, syncStatus, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalMealPlanEntry &&
          other.localId == this.localId &&
          other.remoteId == this.remoteId &&
          other.groupId == this.groupId &&
          other.recipeId == this.recipeId &&
          other.customName == this.customName &&
          other.date == this.date &&
          other.mealType == this.mealType &&
          other.cookIdsJson == this.cookIdsJson &&
          other.syncStatus == this.syncStatus &&
          other.updatedAt == this.updatedAt);
}

class LocalMealPlanEntriesCompanion
    extends UpdateCompanion<LocalMealPlanEntry> {
  final Value<String> localId;
  final Value<String?> remoteId;
  final Value<String> groupId;
  final Value<String> recipeId;
  final Value<String?> customName;
  final Value<String> date;
  final Value<String> mealType;
  final Value<String?> cookIdsJson;
  final Value<String> syncStatus;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocalMealPlanEntriesCompanion({
    this.localId = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.recipeId = const Value.absent(),
    this.customName = const Value.absent(),
    this.date = const Value.absent(),
    this.mealType = const Value.absent(),
    this.cookIdsJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalMealPlanEntriesCompanion.insert({
    required String localId,
    this.remoteId = const Value.absent(),
    required String groupId,
    required String recipeId,
    this.customName = const Value.absent(),
    required String date,
    required String mealType,
    this.cookIdsJson = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : localId = Value(localId),
        groupId = Value(groupId),
        recipeId = Value(recipeId),
        date = Value(date),
        mealType = Value(mealType),
        updatedAt = Value(updatedAt);
  static Insertable<LocalMealPlanEntry> custom({
    Expression<String>? localId,
    Expression<String>? remoteId,
    Expression<String>? groupId,
    Expression<String>? recipeId,
    Expression<String>? customName,
    Expression<String>? date,
    Expression<String>? mealType,
    Expression<String>? cookIdsJson,
    Expression<String>? syncStatus,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (remoteId != null) 'remote_id': remoteId,
      if (groupId != null) 'group_id': groupId,
      if (recipeId != null) 'recipe_id': recipeId,
      if (customName != null) 'custom_name': customName,
      if (date != null) 'date': date,
      if (mealType != null) 'meal_type': mealType,
      if (cookIdsJson != null) 'cook_ids_json': cookIdsJson,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalMealPlanEntriesCompanion copyWith(
      {Value<String>? localId,
      Value<String?>? remoteId,
      Value<String>? groupId,
      Value<String>? recipeId,
      Value<String?>? customName,
      Value<String>? date,
      Value<String>? mealType,
      Value<String?>? cookIdsJson,
      Value<String>? syncStatus,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return LocalMealPlanEntriesCompanion(
      localId: localId ?? this.localId,
      remoteId: remoteId ?? this.remoteId,
      groupId: groupId ?? this.groupId,
      recipeId: recipeId ?? this.recipeId,
      customName: customName ?? this.customName,
      date: date ?? this.date,
      mealType: mealType ?? this.mealType,
      cookIdsJson: cookIdsJson ?? this.cookIdsJson,
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
    if (recipeId.present) {
      map['recipe_id'] = Variable<String>(recipeId.value);
    }
    if (customName.present) {
      map['custom_name'] = Variable<String>(customName.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (mealType.present) {
      map['meal_type'] = Variable<String>(mealType.value);
    }
    if (cookIdsJson.present) {
      map['cook_ids_json'] = Variable<String>(cookIdsJson.value);
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
    return (StringBuffer('LocalMealPlanEntriesCompanion(')
          ..write('localId: $localId, ')
          ..write('remoteId: $remoteId, ')
          ..write('groupId: $groupId, ')
          ..write('recipeId: $recipeId, ')
          ..write('customName: $customName, ')
          ..write('date: $date, ')
          ..write('mealType: $mealType, ')
          ..write('cookIdsJson: $cookIdsJson, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _featureKeyMeta =
      const VerificationMeta('featureKey');
  @override
  late final GeneratedColumn<String> featureKey = GeneratedColumn<String>(
      'feature_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scopeKeyMeta =
      const VerificationMeta('scopeKey');
  @override
  late final GeneratedColumn<String> scopeKey = GeneratedColumn<String>(
      'scope_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastPulledAtMeta =
      const VerificationMeta('lastPulledAt');
  @override
  late final GeneratedColumn<DateTime> lastPulledAt = GeneratedColumn<DateTime>(
      'last_pulled_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [featureKey, scopeKey, lastPulledAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(Insertable<SyncMetaData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feature_key')) {
      context.handle(
          _featureKeyMeta,
          featureKey.isAcceptableOrUnknown(
              data['feature_key']!, _featureKeyMeta));
    } else if (isInserting) {
      context.missing(_featureKeyMeta);
    }
    if (data.containsKey('scope_key')) {
      context.handle(_scopeKeyMeta,
          scopeKey.isAcceptableOrUnknown(data['scope_key']!, _scopeKeyMeta));
    } else if (isInserting) {
      context.missing(_scopeKeyMeta);
    }
    if (data.containsKey('last_pulled_at')) {
      context.handle(
          _lastPulledAtMeta,
          lastPulledAt.isAcceptableOrUnknown(
              data['last_pulled_at']!, _lastPulledAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {featureKey, scopeKey};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      featureKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}feature_key'])!,
      scopeKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scope_key'])!,
      lastPulledAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_pulled_at']),
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final String featureKey;
  final String scopeKey;
  final DateTime? lastPulledAt;
  const SyncMetaData(
      {required this.featureKey, required this.scopeKey, this.lastPulledAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feature_key'] = Variable<String>(featureKey);
    map['scope_key'] = Variable<String>(scopeKey);
    if (!nullToAbsent || lastPulledAt != null) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt);
    }
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      featureKey: Value(featureKey),
      scopeKey: Value(scopeKey),
      lastPulledAt: lastPulledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPulledAt),
    );
  }

  factory SyncMetaData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      featureKey: serializer.fromJson<String>(json['featureKey']),
      scopeKey: serializer.fromJson<String>(json['scopeKey']),
      lastPulledAt: serializer.fromJson<DateTime?>(json['lastPulledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'featureKey': serializer.toJson<String>(featureKey),
      'scopeKey': serializer.toJson<String>(scopeKey),
      'lastPulledAt': serializer.toJson<DateTime?>(lastPulledAt),
    };
  }

  SyncMetaData copyWith(
          {String? featureKey,
          String? scopeKey,
          Value<DateTime?> lastPulledAt = const Value.absent()}) =>
      SyncMetaData(
        featureKey: featureKey ?? this.featureKey,
        scopeKey: scopeKey ?? this.scopeKey,
        lastPulledAt:
            lastPulledAt.present ? lastPulledAt.value : this.lastPulledAt,
      );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      featureKey:
          data.featureKey.present ? data.featureKey.value : this.featureKey,
      scopeKey: data.scopeKey.present ? data.scopeKey.value : this.scopeKey,
      lastPulledAt: data.lastPulledAt.present
          ? data.lastPulledAt.value
          : this.lastPulledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('featureKey: $featureKey, ')
          ..write('scopeKey: $scopeKey, ')
          ..write('lastPulledAt: $lastPulledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(featureKey, scopeKey, lastPulledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.featureKey == this.featureKey &&
          other.scopeKey == this.scopeKey &&
          other.lastPulledAt == this.lastPulledAt);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<String> featureKey;
  final Value<String> scopeKey;
  final Value<DateTime?> lastPulledAt;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.featureKey = const Value.absent(),
    this.scopeKey = const Value.absent(),
    this.lastPulledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String featureKey,
    required String scopeKey,
    this.lastPulledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : featureKey = Value(featureKey),
        scopeKey = Value(scopeKey);
  static Insertable<SyncMetaData> custom({
    Expression<String>? featureKey,
    Expression<String>? scopeKey,
    Expression<DateTime>? lastPulledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (featureKey != null) 'feature_key': featureKey,
      if (scopeKey != null) 'scope_key': scopeKey,
      if (lastPulledAt != null) 'last_pulled_at': lastPulledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith(
      {Value<String>? featureKey,
      Value<String>? scopeKey,
      Value<DateTime?>? lastPulledAt,
      Value<int>? rowid}) {
    return SyncMetaCompanion(
      featureKey: featureKey ?? this.featureKey,
      scopeKey: scopeKey ?? this.scopeKey,
      lastPulledAt: lastPulledAt ?? this.lastPulledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (featureKey.present) {
      map['feature_key'] = Variable<String>(featureKey.value);
    }
    if (scopeKey.present) {
      map['scope_key'] = Variable<String>(scopeKey.value);
    }
    if (lastPulledAt.present) {
      map['last_pulled_at'] = Variable<DateTime>(lastPulledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('featureKey: $featureKey, ')
          ..write('scopeKey: $scopeKey, ')
          ..write('lastPulledAt: $lastPulledAt, ')
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
  late final $LocalMealPlanEntriesTable localMealPlanEntries =
      $LocalMealPlanEntriesTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [localShoppingItems, localRecipes, localMealPlanEntries, syncMeta];
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
  Value<String> carbTagsJson,
  Value<DateTime?> updatedAt,
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
  Value<String> carbTagsJson,
  Value<DateTime?> updatedAt,
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

  ColumnFilters<String> get carbTagsJson => $composableBuilder(
      column: $table.carbTagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

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

  ColumnOrderings<String> get carbTagsJson => $composableBuilder(
      column: $table.carbTagsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

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

  GeneratedColumn<String> get carbTagsJson => $composableBuilder(
      column: $table.carbTagsJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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
            Value<String> carbTagsJson = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
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
            carbTagsJson: carbTagsJson,
            updatedAt: updatedAt,
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
            Value<String> carbTagsJson = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
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
            carbTagsJson: carbTagsJson,
            updatedAt: updatedAt,
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
typedef $$LocalMealPlanEntriesTableCreateCompanionBuilder
    = LocalMealPlanEntriesCompanion Function({
  required String localId,
  Value<String?> remoteId,
  required String groupId,
  required String recipeId,
  Value<String?> customName,
  required String date,
  required String mealType,
  Value<String?> cookIdsJson,
  Value<String> syncStatus,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$LocalMealPlanEntriesTableUpdateCompanionBuilder
    = LocalMealPlanEntriesCompanion Function({
  Value<String> localId,
  Value<String?> remoteId,
  Value<String> groupId,
  Value<String> recipeId,
  Value<String?> customName,
  Value<String> date,
  Value<String> mealType,
  Value<String?> cookIdsJson,
  Value<String> syncStatus,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$LocalMealPlanEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalMealPlanEntriesTable> {
  $$LocalMealPlanEntriesTableFilterComposer({
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

  ColumnFilters<String> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customName => $composableBuilder(
      column: $table.customName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cookIdsJson => $composableBuilder(
      column: $table.cookIdsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$LocalMealPlanEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalMealPlanEntriesTable> {
  $$LocalMealPlanEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get recipeId => $composableBuilder(
      column: $table.recipeId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customName => $composableBuilder(
      column: $table.customName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mealType => $composableBuilder(
      column: $table.mealType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cookIdsJson => $composableBuilder(
      column: $table.cookIdsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$LocalMealPlanEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalMealPlanEntriesTable> {
  $$LocalMealPlanEntriesTableAnnotationComposer({
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

  GeneratedColumn<String> get recipeId =>
      $composableBuilder(column: $table.recipeId, builder: (column) => column);

  GeneratedColumn<String> get customName => $composableBuilder(
      column: $table.customName, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get mealType =>
      $composableBuilder(column: $table.mealType, builder: (column) => column);

  GeneratedColumn<String> get cookIdsJson => $composableBuilder(
      column: $table.cookIdsJson, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocalMealPlanEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LocalMealPlanEntriesTable,
    LocalMealPlanEntry,
    $$LocalMealPlanEntriesTableFilterComposer,
    $$LocalMealPlanEntriesTableOrderingComposer,
    $$LocalMealPlanEntriesTableAnnotationComposer,
    $$LocalMealPlanEntriesTableCreateCompanionBuilder,
    $$LocalMealPlanEntriesTableUpdateCompanionBuilder,
    (
      LocalMealPlanEntry,
      BaseReferences<_$AppDatabase, $LocalMealPlanEntriesTable,
          LocalMealPlanEntry>
    ),
    LocalMealPlanEntry,
    PrefetchHooks Function()> {
  $$LocalMealPlanEntriesTableTableManager(
      _$AppDatabase db, $LocalMealPlanEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalMealPlanEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalMealPlanEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalMealPlanEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> localId = const Value.absent(),
            Value<String?> remoteId = const Value.absent(),
            Value<String> groupId = const Value.absent(),
            Value<String> recipeId = const Value.absent(),
            Value<String?> customName = const Value.absent(),
            Value<String> date = const Value.absent(),
            Value<String> mealType = const Value.absent(),
            Value<String?> cookIdsJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMealPlanEntriesCompanion(
            localId: localId,
            remoteId: remoteId,
            groupId: groupId,
            recipeId: recipeId,
            customName: customName,
            date: date,
            mealType: mealType,
            cookIdsJson: cookIdsJson,
            syncStatus: syncStatus,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String localId,
            Value<String?> remoteId = const Value.absent(),
            required String groupId,
            required String recipeId,
            Value<String?> customName = const Value.absent(),
            required String date,
            required String mealType,
            Value<String?> cookIdsJson = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              LocalMealPlanEntriesCompanion.insert(
            localId: localId,
            remoteId: remoteId,
            groupId: groupId,
            recipeId: recipeId,
            customName: customName,
            date: date,
            mealType: mealType,
            cookIdsJson: cookIdsJson,
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

typedef $$LocalMealPlanEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $LocalMealPlanEntriesTable,
        LocalMealPlanEntry,
        $$LocalMealPlanEntriesTableFilterComposer,
        $$LocalMealPlanEntriesTableOrderingComposer,
        $$LocalMealPlanEntriesTableAnnotationComposer,
        $$LocalMealPlanEntriesTableCreateCompanionBuilder,
        $$LocalMealPlanEntriesTableUpdateCompanionBuilder,
        (
          LocalMealPlanEntry,
          BaseReferences<_$AppDatabase, $LocalMealPlanEntriesTable,
              LocalMealPlanEntry>
        ),
        LocalMealPlanEntry,
        PrefetchHooks Function()>;
typedef $$SyncMetaTableCreateCompanionBuilder = SyncMetaCompanion Function({
  required String featureKey,
  required String scopeKey,
  Value<DateTime?> lastPulledAt,
  Value<int> rowid,
});
typedef $$SyncMetaTableUpdateCompanionBuilder = SyncMetaCompanion Function({
  Value<String> featureKey,
  Value<String> scopeKey,
  Value<DateTime?> lastPulledAt,
  Value<int> rowid,
});

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get featureKey => $composableBuilder(
      column: $table.featureKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scopeKey => $composableBuilder(
      column: $table.scopeKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPulledAt => $composableBuilder(
      column: $table.lastPulledAt, builder: (column) => ColumnFilters(column));
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get featureKey => $composableBuilder(
      column: $table.featureKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scopeKey => $composableBuilder(
      column: $table.scopeKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPulledAt => $composableBuilder(
      column: $table.lastPulledAt,
      builder: (column) => ColumnOrderings(column));
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get featureKey => $composableBuilder(
      column: $table.featureKey, builder: (column) => column);

  GeneratedColumn<String> get scopeKey =>
      $composableBuilder(column: $table.scopeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPulledAt => $composableBuilder(
      column: $table.lastPulledAt, builder: (column) => column);
}

class $$SyncMetaTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncMetaTable,
    SyncMetaData,
    $$SyncMetaTableFilterComposer,
    $$SyncMetaTableOrderingComposer,
    $$SyncMetaTableAnnotationComposer,
    $$SyncMetaTableCreateCompanionBuilder,
    $$SyncMetaTableUpdateCompanionBuilder,
    (SyncMetaData, BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>),
    SyncMetaData,
    PrefetchHooks Function()> {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> featureKey = const Value.absent(),
            Value<String> scopeKey = const Value.absent(),
            Value<DateTime?> lastPulledAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetaCompanion(
            featureKey: featureKey,
            scopeKey: scopeKey,
            lastPulledAt: lastPulledAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String featureKey,
            required String scopeKey,
            Value<DateTime?> lastPulledAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncMetaCompanion.insert(
            featureKey: featureKey,
            scopeKey: scopeKey,
            lastPulledAt: lastPulledAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncMetaTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncMetaTable,
    SyncMetaData,
    $$SyncMetaTableFilterComposer,
    $$SyncMetaTableOrderingComposer,
    $$SyncMetaTableAnnotationComposer,
    $$SyncMetaTableCreateCompanionBuilder,
    $$SyncMetaTableUpdateCompanionBuilder,
    (SyncMetaData, BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>),
    SyncMetaData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalShoppingItemsTableTableManager get localShoppingItems =>
      $$LocalShoppingItemsTableTableManager(_db, _db.localShoppingItems);
  $$LocalRecipesTableTableManager get localRecipes =>
      $$LocalRecipesTableTableManager(_db, _db.localRecipes);
  $$LocalMealPlanEntriesTableTableManager get localMealPlanEntries =>
      $$LocalMealPlanEntriesTableTableManager(_db, _db.localMealPlanEntries);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
}
