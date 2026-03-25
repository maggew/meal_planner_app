// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_scraper_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecipeScraper)
final recipeScraperProvider = RecipeScraperProvider._();

final class RecipeScraperProvider
    extends $NotifierProvider<RecipeScraper, AsyncValue<ScrapedRecipeData?>> {
  RecipeScraperProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recipeScraperProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recipeScraperHash();

  @$internal
  @override
  RecipeScraper create() => RecipeScraper();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ScrapedRecipeData?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<ScrapedRecipeData?>>(value),
    );
  }
}

String _$recipeScraperHash() => r'bec6aada64988fec750d565c13bf3ab35ac56faa';

abstract class _$RecipeScraper
    extends $Notifier<AsyncValue<ScrapedRecipeData?>> {
  AsyncValue<ScrapedRecipeData?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref
        as $Ref<AsyncValue<ScrapedRecipeData?>, AsyncValue<ScrapedRecipeData?>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ScrapedRecipeData?>,
            AsyncValue<ScrapedRecipeData?>>,
        AsyncValue<ScrapedRecipeData?>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
