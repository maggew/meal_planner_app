import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/domain/services/amount_scaler.dart';

class Ingredient {
  final String name;
  final Unit? unit;
  final String? amount;

  Ingredient({
    required this.name,
    required this.unit,
    required this.amount,
  });

  Ingredient scale(double factor) {
    if (amount == null) return this;
    return Ingredient(
      name: name,
      unit: unit,
      amount: AmountScaler.scale(amount!, factor),
    );
  }

  static const _sentinel = _Sentinel();

  Ingredient copyWith({
    String? name,
    Object? unit = _sentinel,
    Object? amount = _sentinel,
  }) {
    return Ingredient(
      name: name ?? this.name,
      unit: unit == _sentinel ? this.unit : unit as Unit?,
      amount: amount == _sentinel ? this.amount : amount as String?,
    );
  }

  @override
  String toString() {
    return 'Ingredient(name: $name, unit: ${unit?.displayName}, amount: $amount)';
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
  final List<Ingredient> ingredients;

  IngredientSection({
    required this.title,
    required this.ingredients,
  });
}

class _Sentinel {
  const _Sentinel();
}
