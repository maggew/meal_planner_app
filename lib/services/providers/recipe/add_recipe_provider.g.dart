// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_recipe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedCategories)
const selectedCategoriesProvider = SelectedCategoriesProvider._();

final class SelectedCategoriesProvider
    extends $NotifierProvider<SelectedCategories, List<String>> {
  const SelectedCategoriesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedCategoriesProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedCategoriesHash();

  @$internal
  @override
  SelectedCategories create() => SelectedCategories();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<String>>(value),
    );
  }
}

String _$selectedCategoriesHash() =>
    r'e0cfcad71971dfb515e69c0769650ff02f2391c6';

abstract class _$SelectedCategories extends $Notifier<List<String>> {
  List<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<List<String>, List<String>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<String>, List<String>>,
        List<String>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedPortions)
const selectedPortionsProvider = SelectedPortionsProvider._();

final class SelectedPortionsProvider
    extends $NotifierProvider<SelectedPortions, int> {
  const SelectedPortionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'selectedPortionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$selectedPortionsHash();

  @$internal
  @override
  SelectedPortions create() => SelectedPortions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$selectedPortionsHash() => r'98afdce00f38b49603c9670a8cffff346e9e493a';

abstract class _$SelectedPortions extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
