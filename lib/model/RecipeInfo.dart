class Recipe {

  String title;
  String imagePath;
  List ingredients;
  int portions;
  String instructions;

  Recipe({this.title, this.imagePath, this.ingredients, this.portions, this.instructions});

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