import 'package:meal_planner/model/enums/unit.dart';

class Ingredient {
  String name;
  Unit unit;
  int amount;

  Ingredient({
    required this.name,
    required this.unit,
    required this.amount,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String? ?? '',
      unit: Unit.values.byName(json['unit']),
      amount: json['amount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'unit': unit.displayName,
      'amount': amount,
    };
  }
}
