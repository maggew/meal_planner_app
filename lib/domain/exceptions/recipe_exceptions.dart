class RecipeNotFoundException implements Exception {
  final String recipeId;
  RecipeNotFoundException(this.recipeId);

  @override
  String toString() => 'Rezept nicht gefunden: $recipeId';
}

class RecipeCreationException implements Exception {
  final String message;
  RecipeCreationException(this.message);

  @override
  String toString() => 'Rezept konnte nicht erstellt werden: $message';
}

class RecipeUpdateException implements Exception {
  final String message;
  RecipeUpdateException(this.message);

  @override
  String toString() => 'Rezept konnte nicht aktualisiert werden: $message';
}

class RecipeDeletionException implements Exception {
  final String message;
  RecipeDeletionException(this.message);

  @override
  String toString() => 'Rezept konnte nicht gelöscht werden: $message';
}
