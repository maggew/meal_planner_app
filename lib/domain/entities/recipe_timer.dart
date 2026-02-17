class RecipeTimer {
  final String? id;
  final String recipeId;
  final int stepIndex;
  final String timerName;
  final int durationSeconds;

  RecipeTimer({
    this.id,
    required this.recipeId,
    required this.stepIndex,
    required this.timerName,
    required this.durationSeconds,
  });

  RecipeTimer copyWith({
    String? id,
    String? recipeId,
    int? stepIndex,
    String? timerName,
    int? durationSeconds,
  }) {
    return RecipeTimer(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      stepIndex: stepIndex ?? this.stepIndex,
      timerName: timerName ?? this.timerName,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}
