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
    extends $NotifierProvider<RecipeAnalysis, RecipeAnalysisState> {
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
  Override overrideWithValue(RecipeAnalysisState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipeAnalysisState>(value),
    );
  }
}

String _$recipeAnalysisHash() => r'8e7add3945789f54a7577910248887424d1b703f';

abstract class _$RecipeAnalysis extends $Notifier<RecipeAnalysisState> {
  RecipeAnalysisState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<RecipeAnalysisState, RecipeAnalysisState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RecipeAnalysisState, RecipeAnalysisState>,
        RecipeAnalysisState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
