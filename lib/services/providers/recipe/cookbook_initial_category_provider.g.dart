// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cookbook_initial_category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Hält die Kategorie-ID + eine Generation, zu der das Kochbuch beim nächsten
/// Build springen soll. Die Generation wird bei jedem Upload hochgezählt und
/// dient als ValueKey für VerticalTabs, damit initState neu ausgeführt wird.
/// Nach dem Build wird nur die categoryId gecleart — die Generation bleibt,
/// damit kein weiterer Rebuild ausgelöst wird.

@ProviderFor(CookbookInitialCategory)
final cookbookInitialCategoryProvider = CookbookInitialCategoryProvider._();

/// Hält die Kategorie-ID + eine Generation, zu der das Kochbuch beim nächsten
/// Build springen soll. Die Generation wird bei jedem Upload hochgezählt und
/// dient als ValueKey für VerticalTabs, damit initState neu ausgeführt wird.
/// Nach dem Build wird nur die categoryId gecleart — die Generation bleibt,
/// damit kein weiterer Rebuild ausgelöst wird.
final class CookbookInitialCategoryProvider extends $NotifierProvider<
    CookbookInitialCategory,
    ({
      String? categoryId,
      int generation,
    })> {
  /// Hält die Kategorie-ID + eine Generation, zu der das Kochbuch beim nächsten
  /// Build springen soll. Die Generation wird bei jedem Upload hochgezählt und
  /// dient als ValueKey für VerticalTabs, damit initState neu ausgeführt wird.
  /// Nach dem Build wird nur die categoryId gecleart — die Generation bleibt,
  /// damit kein weiterer Rebuild ausgelöst wird.
  CookbookInitialCategoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'cookbookInitialCategoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$cookbookInitialCategoryHash();

  @$internal
  @override
  CookbookInitialCategory create() => CookbookInitialCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
      ({
        String? categoryId,
        int generation,
      }) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<
          ({
            String? categoryId,
            int generation,
          })>(value),
    );
  }
}

String _$cookbookInitialCategoryHash() =>
    r'0384ec0c7e55eaa908aaeb403a79431a7897c49f';

/// Hält die Kategorie-ID + eine Generation, zu der das Kochbuch beim nächsten
/// Build springen soll. Die Generation wird bei jedem Upload hochgezählt und
/// dient als ValueKey für VerticalTabs, damit initState neu ausgeführt wird.
/// Nach dem Build wird nur die categoryId gecleart — die Generation bleibt,
/// damit kein weiterer Rebuild ausgelöst wird.

abstract class _$CookbookInitialCategory extends $Notifier<
    ({
      String? categoryId,
      int generation,
    })> {
  ({
    String? categoryId,
    int generation,
  }) build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<
        ({
          String? categoryId,
          int generation,
        }),
        ({
          String? categoryId,
          int generation,
        })>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<
            ({
              String? categoryId,
              int generation,
            }),
            ({
              String? categoryId,
              int generation,
            })>,
        ({
          String? categoryId,
          int generation,
        }),
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
