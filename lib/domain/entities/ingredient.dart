import 'package:meal_planner/domain/enums/unit.dart';

class Ingredient {
  final String name;
  final Unit unit;
  final int amount;

  Ingredient({
    required this.name,
    required this.unit,
    required this.amount,
  });

  // Business-Logik

  String get displayText => '$amount ${unit.displayName} $name';

  bool get isValid => name.isNotEmpty && amount > 0;

  Ingredient scale(double factor) {
    return Ingredient(
      name: name,
      unit: unit,
      amount: (amount * factor).round(),
    );
  }

  Ingredient copyWith({
    String? name,
    Unit? unit,
    int? amount,
  }) {
    return Ingredient(
      name: name ?? this.name,
      unit: unit ?? this.unit,
      amount: amount ?? this.amount,
    );
  }

  @override
  String toString() {
    return 'Ingredient($displayText)';
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
