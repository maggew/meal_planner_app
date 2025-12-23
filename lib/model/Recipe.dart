class Recipe {
  String title;
  String imagePath;
  List ingredients;
  int portions;
  String instructions;

  Recipe({
    required this.title,
    required this.imagePath,
    required this.ingredients,
    required this.portions,
    required this.instructions,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      title: json['name'] as String? ?? '',
      imagePath:
          json['recipe_pic'] as String? ?? 'assets/images/default_pic_2.jpg',
      ingredients:
          (json['ingredients'] as List?)?.map((e) => e.toString()).toList() ??
              <String>[],
      portions: json['portions'] is int
          ? json['portions'] as int
          : int.tryParse(json['portions']?.toString() ?? '') ?? 0,
      instructions: json['instructions'] as String? ?? '',
    );
  }
}
