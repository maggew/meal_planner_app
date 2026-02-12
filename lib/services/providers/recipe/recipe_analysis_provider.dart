import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:meal_planner/domain/entities/ingredient.dart';
import 'package:meal_planner/services/recipe_extractor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'recipe_analysis_provider.g.dart';

class AnalyzedRecipeData {
  final List<IngredientSection>? ingredientSections;
  final String? instructions;

  AnalyzedRecipeData({
    this.ingredientSections,
    this.instructions,
  });
}

class RecipeAnalysisState {
  final AnalyzedRecipeData? data;
  final bool isLoadingIngredients;
  final bool isLoadingInstructions;
  final Object? error;

  const RecipeAnalysisState({
    this.data,
    this.isLoadingIngredients = false,
    this.isLoadingInstructions = false,
    this.error,
  });

  bool get isLoading => isLoadingIngredients || isLoadingInstructions;

  RecipeAnalysisState copyWith({
    AnalyzedRecipeData? data,
    bool? isLoadingIngredients,
    bool? isLoadingInstructions,
    Object? error,
  }) {
    return RecipeAnalysisState(
      data: data ?? this.data,
      isLoadingIngredients: isLoadingIngredients ?? this.isLoadingIngredients,
      isLoadingInstructions:
          isLoadingInstructions ?? this.isLoadingInstructions,
      error: error,
    );
  }
}

@Riverpod(keepAlive: true)
class RecipeAnalysis extends _$RecipeAnalysis {
  @override
  RecipeAnalysisState build() {
    return const RecipeAnalysisState();
  }

  Future<void> analyzeImage({
    required File image,
    required bool isIngredientImage,
  }) async {
    state = state.copyWith(
      isLoadingIngredients: isIngredientImage ? true : null,
      isLoadingInstructions: !isIngredientImage ? true : null,
    );

    try {
      final result = await _performImageAnalysis(
        imageFile: image,
        isIngredientImage: isIngredientImage,
      );
      state = state.copyWith(
        data: result,
        isLoadingIngredients: isIngredientImage ? false : null,
        isLoadingInstructions: !isIngredientImage ? false : null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e,
        isLoadingIngredients: isIngredientImage ? false : null,
        isLoadingInstructions: !isIngredientImage ? false : null,
      );
    }
  }

  Future<AnalyzedRecipeData> _performImageAnalysis({
    required File imageFile,
    required bool isIngredientImage,
  }) async {
    final inputImage = InputImage.fromFile(imageFile);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    late ExtractionResult recipeData;
    if (isIngredientImage) {
      recipeData = RecipeExtractor.extractRecipeIngredients(recognizedText);
      return AnalyzedRecipeData(
        ingredientSections: recipeData.ingredientSections,
      );
    } else {
      recipeData = RecipeExtractor.extractRecipeInstructions(recognizedText);
      return AnalyzedRecipeData(
        instructions: recipeData.instructions,
      );
    }
  }

  void clear() {
    state = const RecipeAnalysisState();
  }
}
