// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_analysis_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecipeAnalysis)
const recipeAnalysisProvider = RecipeAnalysisProvider._();

final class RecipeAnalysisProvider
    extends $NotifierProvider<RecipeAnalysis, AsyncValue<AnalyzedRecipeData?>> {
  const RecipeAnalysisProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recipeAnalysisProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recipeAnalysisHash();

  @$internal
  @override
  RecipeAnalysis create() => RecipeAnalysis();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AnalyzedRecipeData?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<AnalyzedRecipeData?>>(value),
    );
  }
}

String _$recipeAnalysisHash() => r'e55321374042f5c2581c03b1fa5d2d3fe0f949fe';

abstract class _$RecipeAnalysis
    extends $Notifier<AsyncValue<AnalyzedRecipeData?>> {
  AsyncValue<AnalyzedRecipeData?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AnalyzedRecipeData?>,
        AsyncValue<AnalyzedRecipeData?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AnalyzedRecipeData?>,
            AsyncValue<AnalyzedRecipeData?>>,
        AsyncValue<AnalyzedRecipeData?>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
