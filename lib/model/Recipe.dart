import 'package:meal_planner/model/Ingredient.dart';

class Recipe {
  String name;
  String imagePath;
  List<Ingredient> ingredients;
  int portions;
  String instruction;

  Recipe({
    required this.name,
    required this.imagePath,
    required this.ingredients,
    required this.portions,
    required this.instruction,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<Ingredient> ingredients = [];
    for (dynamic ingredient in json['ingredients']) {
      ingredients.add(Ingredient.fromJson(ingredient));
    }
    return Recipe(
      name: json['name'] as String? ?? '',
      imagePath:
          json['recipe_pic'] as String? ?? 'assets/images/default_pic_2.jpg',
      ingredients: ingredients,
      portions: json['portions'] is int
          ? json['portions'] as int
          : int.tryParse(json['portions']?.toString() ?? '') ?? 0,
      instruction: _unescapeString(json['instruction'] as String? ?? ''),
    );
  }

  /// Hilfsmethode
  static String _unescapeString(String str) {
    return str
        .replaceAll('\\n', '\n')
        .replaceAll('\\t', '\t')
        .replaceAll('\\r', '\r');
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': imagePath,
      'ingredients': ingredients.map((ing) => ing.toJson()).toList(),
      'portions': portions,
      'instruction': instruction,
    };
  }
}
