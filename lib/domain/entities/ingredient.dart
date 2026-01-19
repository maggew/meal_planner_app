import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/domain/services/amount_scaler.dart';

class Ingredient {
  final String name;
  final Unit unit;
  final String amount;
  final int sortOrder;
  final String? groupName;
  final String localId;

  Ingredient({
    required this.name,
    required this.unit,
    required this.amount,
    this.sortOrder = 0,
    this.groupName,
    String? localId,
  }) : localId = localId ?? _generateLocalId();

  static String _generateLocalId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  Ingredient scale(double factor) {
    return Ingredient(
      name: name,
      unit: unit,
      amount: AmountScaler.scale(amount, factor),
      sortOrder: sortOrder,
      groupName: groupName,
    );
  }

  Ingredient copyWith({
    String? name,
    Unit? unit,
    String? amount,
    int? sortOrder,
    String? groupName,
    String? localId,
  }) {
    return Ingredient(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
      sortOrder: sortOrder ?? this.sortOrder,
      groupName: groupName ?? this.groupName,
      localId: localId ?? this.localId,
    );
  }

  @override
  String toString() {
    return 'Ingredient(name: $name, unit: ${unit.displayName}, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient &&
        other.name == name &&
        other.unit == unit &&
        other.amount == amount &&
        other.sortOrder == sortOrder &&
        other.groupName == groupName;
  }

  @override
  int get hashCode => Object.hash(name, unit, amount, sortOrder, groupName);
}
