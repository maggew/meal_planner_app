class CookingRecipeEntry {
  final String recipeId;
  final String recipeName;
  final String? imageUrl;
  final int currentStep;

  const CookingRecipeEntry({
    required this.recipeId,
    required this.recipeName,
    this.imageUrl,
    this.currentStep = 0,
  });

  CookingRecipeEntry copyWith({
    String? recipeId,
    String? recipeName,
    String? imageUrl,
    int? currentStep,
  }) {
    return CookingRecipeEntry(
      recipeId: recipeId ?? this.recipeId,
      recipeName: recipeName ?? this.recipeName,
      imageUrl: imageUrl ?? this.imageUrl,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}
