// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchQuery)
const searchQueryProvider = SearchQueryProvider._();

final class SearchQueryProvider extends $NotifierProvider<SearchQuery, String> {
  const SearchQueryProvider._()
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
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SearchAllCategories)
const searchAllCategoriesProvider = SearchAllCategoriesProvider._();

final class SearchAllCategoriesProvider
    extends $NotifierProvider<SearchAllCategories, bool> {
  const SearchAllCategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'searchAllCategoriesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$searchAllCategoriesHash();

  @$internal
  @override
  SearchAllCategories create() => SearchAllCategories();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$searchAllCategoriesHash() =>
    r'0c93395c8bbafae3781f3781b8074987ca54a968';

abstract class _$SearchAllCategories extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(FilteredRecipes)
const filteredRecipesProvider = FilteredRecipesFamily._();

final class FilteredRecipesProvider
    extends $NotifierProvider<FilteredRecipes, List<Recipe>> {
  const FilteredRecipesProvider._(
      {required FilteredRecipesFamily super.from,
      required ({
        String category,
        List<String> allCategories,
      })
          super.argument})
      : super(
          retry: null,
          name: r'filteredRecipesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$filteredRecipesHash();

  @override
  String toString() {
    return r'filteredRecipesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  FilteredRecipes create() => FilteredRecipes();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Recipe> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Recipe>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredRecipesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$filteredRecipesHash() => r'cda123871750fc1b587eefa048da36395aee372c';

final class FilteredRecipesFamily extends $Family
    with
        $ClassFamilyOverride<
            FilteredRecipes,
            List<Recipe>,
            List<Recipe>,
            List<Recipe>,
            ({
              String category,
              List<String> allCategories,
            })> {
  const FilteredRecipesFamily._()
      : super(
          retry: null,
          name: r'filteredRecipesProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  FilteredRecipesProvider call({
    required String category,
    required List<String> allCategories,
  }) =>
      FilteredRecipesProvider._(argument: (
        category: category,
        allCategories: allCategories,
      ), from: this);

  @override
  String toString() => r'filteredRecipesProvider';
}

abstract class _$FilteredRecipes extends $Notifier<List<Recipe>> {
  late final _$args = ref.$arg as ({
    String category,
    List<String> allCategories,
  });
  String get category => _$args.category;
  List<String> get allCategories => _$args.allCategories;

  List<Recipe> build({
    required String category,
    required List<String> allCategories,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      category: _$args.category,
      allCategories: _$args.allCategories,
    );
    final ref = this.ref as $Ref<List<Recipe>, List<Recipe>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Recipe>, List<Recipe>>,
        List<Recipe>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(IsSearchActive)
const isSearchActiveProvider = IsSearchActiveProvider._();

final class IsSearchActiveProvider
    extends $NotifierProvider<IsSearchActive, bool> {
  const IsSearchActiveProvider._()
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

String _$isSearchActiveHash() => r'0d8b5c5350f76fa5a16d709ef29d9ab5699548b0';

abstract class _$IsSearchActive extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
