import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/services/recipe_extractor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_analysis_provider.g.dart';

class AnalyzedRecipeData {
  final List<Ingredient>? ingredients;
  final String? instructions;

  AnalyzedRecipeData({
    this.ingredients,
    this.instructions,
  });
}

@Riverpod(keepAlive: true)
class RecipeAnalysis extends _$RecipeAnalysis {
  bool _isLoadingIngredients = false;
  bool _isLoadingInstructions = false;

  bool get isLoadingIngredients => _isLoadingIngredients;
  bool get isLoadingInstructions => _isLoadingInstructions;

  @override
  AsyncValue<AnalyzedRecipeData?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> analyzeImage({
    required File image,
    required bool isIngredientImage,
  }) async {
    if (isIngredientImage) {
      _isLoadingIngredients = true;
    } else {
      _isLoadingInstructions = true;
    }
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final result = await _performImageAnalysis(
        imageFile: image,
        isIngredientImage: isIngredientImage,
      );

      if (isIngredientImage) {
        _isLoadingIngredients = false;
      } else {
        _isLoadingInstructions = false;
      }

      return result;
    });
  }

  Future<AnalyzedRecipeData> _performImageAnalysis(
      {required File imageFile, required bool isIngredientImage}) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    late ExtractionResult recipeData;
    if (isIngredientImage) {
      recipeData = RecipeExtractor.extractRecipeIngredients(recognizedText);
      return AnalyzedRecipeData(ingredients: recipeData.ingredients);
    } else {
      recipeData = RecipeExtractor.extractRecipeInstructions(recognizedText);
      return AnalyzedRecipeData(instructions: recipeData.instructions);
    }
  }

  void clear() {
    state = const AsyncValue.data(null);
  }
}
