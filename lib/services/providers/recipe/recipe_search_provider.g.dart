// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchQuery)
final searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  SearchQueryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchQueryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchQueryHash();

  @$internal
  @override
  SearchQuery create() => SearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$searchQueryHash() => r'a74fdf04dbf795b3f9090a7307b574a8bff68199';

abstract class _$SearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(categoryRecipes)
final categoryRecipesProvider = CategoryRecipesFamily._();

final class CategoryRecipesProvider extends $FunctionalProvider<
        AsyncValue<List<Recipe>>, List<Recipe>, FutureOr<List<Recipe>>>
    with $FutureModifier<List<Recipe>>, $FutureProvider<List<Recipe>> {
  CategoryRecipesProvider._(
      {required CategoryRecipesFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'categoryRecipesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$categoryRecipesHash();

  @override
  String toString() {
    return r'categoryRecipesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Recipe>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Recipe>> create(Ref ref) {
    final argument = this.argument as String;
    return categoryRecipes(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryRecipesHash() => r'5485979002d3025ad36b4397ec46bccd1c4b58bc';

final class CategoryRecipesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Recipe>>, String> {
  CategoryRecipesFamily._()
      : super(
          retry: null,
          name: r'categoryRecipesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  CategoryRecipesProvider call(
    String categoryId,
  ) =>
      CategoryRecipesProvider._(argument: categoryId, from: this);

  @override
  String toString() => r'categoryRecipesProvider';
}

@ProviderFor(IsSearchActive)
final isSearchActiveProvider = IsSearchActiveProvider._();

final class IsSearchActiveProvider
    extends $NotifierProvider<IsSearchActive, bool> {
  IsSearchActiveProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isSearchActiveProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isSearchActiveHash();

  @$internal
  @override
  IsSearchActive create() => IsSearchActive();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isSearchActiveHash() => r'ca6742634bcc2f4ad2f95b8d58e474163651ea4e';

abstract class _$IsSearchActive extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(searchResults)
final searchResultsProvider = SearchResultsProvider._();

final class SearchResultsProvider extends $FunctionalProvider<
        AsyncValue<List<Recipe>>, List<Recipe>, FutureOr<List<Recipe>>>
    with $FutureModifier<List<Recipe>>, $FutureProvider<List<Recipe>> {
  SearchResultsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchResultsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $FutureProviderElement<List<Recipe>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Recipe>> create(Ref ref) {
    return searchResults(ref);
  }
}

String _$searchResultsHash() => r'bfa246394e6c19be2e76e8f6f42a42b3013f777b';
