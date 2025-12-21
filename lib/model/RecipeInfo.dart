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
      title: json['title'],
      imagePath: "",
      ingredients: json['ingredients'],
      portions: json['portions'],
      instructions: json['instructions'],
    );
  }
}

