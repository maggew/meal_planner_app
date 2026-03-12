class ScrapedRecipeData {
  final String? name;
  final List<String> rawIngredients;
  final String? instructions;
  final int? servings;
  final String? localImagePath;

  const ScrapedRecipeData({
    this.name,
    required this.rawIngredients,
    this.instructions,
    this.servings,
    this.localImagePath,
  });
}
