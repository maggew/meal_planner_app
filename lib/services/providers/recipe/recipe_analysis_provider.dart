import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meal_planner/core/constants/firebase_constants.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/domain/enums/unit.dart';
import 'package:meal_planner/services/recipe_extractor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
      final result = await _performImageAnalysis(image);

      return AnalyzedRecipeData(
        name: result[FirebaseConstants.recipeName],
        ingredients: result[FirebaseConstants.recipeIngredients],
        instructions: result[FirebaseConstants.recipeInstructions],
      );
    });
  }

  Future<Map<String, dynamic>> _performImageAnalysis(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    final recipeData = RecipeExtractor.extractRecipeData(recognizedText);

    return {
      FirebaseConstants.recipeName: recipeData[FirebaseConstants.recipeName],
      FirebaseConstants.recipeIngredients:
          recipeData[FirebaseConstants.recipeIngredients],
      FirebaseConstants.recipeInstructions:
          recipeData[FirebaseConstants.recipeInstructions],
    };
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
