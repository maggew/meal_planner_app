import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/domain/services/amount_scaler.dart';

class Ingredient {
  final String name;
  final Unit unit;
  final String amount;

  Ingredient({
    required this.name,
    required this.unit,
    required this.amount,
  });

  Ingredient scale(double factor) {
    return Ingredient(
      name: name,
      unit: unit,
      amount: AmountScaler.scale(amount, factor),
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
        other.amount == amount;
  }

  @override
  int get hashCode => Object.hash(name, unit, amount);
}

class IngredientSection {
  final String title;
  final List<Ingredient> items;

  IngredientSection({
    required this.title,
    required this.items,
  });
}
