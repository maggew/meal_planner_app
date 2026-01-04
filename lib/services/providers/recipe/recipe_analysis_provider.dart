// lib/services/providers/recipe_analysis_provider.dart
import 'dart:io';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';

part 'recipe_analysis_provider.g.dart';

class AnalyzedRecipeData {
  final String? name;
  final int? portions;
  final List<Ingredient>? ingredients;
  final String? instructions;

  AnalyzedRecipeData({
    this.name,
    this.portions,
    this.ingredients,
    this.instructions,
  });
}

@Riverpod(keepAlive: true)
class RecipeAnalysis extends _$RecipeAnalysis {
  @override
  AsyncValue<AnalyzedRecipeData?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> analyzeImage(File image) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      // Hier deine BlinkID/Bildanalyse
      final result = await _performImageAnalysis(image);

      return AnalyzedRecipeData(
        name: result[FirebaseConstants.recipeName],
        portions: result[FirebaseConstants.recipePortions],
        ingredients: result[FirebaseConstants.recipeIngredients],
        instructions: result[FirebaseConstants.recipeInstructions],
      );
    });
  }

  Future<Map<String, dynamic>> _performImageAnalysis(File image) async {
    // TODO: Implementiere deine BlinkID-Analyse hier
    await Future.delayed(Duration(seconds: 3)); // Simuliere Analyse

    return {
      FirebaseConstants.recipeName: 'Spaghetti Carbonara',
      FirebaseConstants.recipePortions: 4,
      FirebaseConstants.recipeIngredients: <Ingredient>[
        Ingredient(name: "Tomate", amount: 150, unit: Unit.GRAMM),
        Ingredient(name: "Wasser", amount: 300, unit: Unit.MILLILITER),
      ],
      FirebaseConstants.recipeInstructions: 'Schritt 1...',
    };
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
