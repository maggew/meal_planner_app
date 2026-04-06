// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shoppingListStream)
final shoppingListStreamProvider = ShoppingListStreamProvider._();

final class ShoppingListStreamProvider extends $FunctionalProvider<
        AsyncValue<List<ShoppingListItem>>,
        List<ShoppingListItem>,
        Stream<List<ShoppingListItem>>>
    with
        $FutureModifier<List<ShoppingListItem>>,
        $StreamProvider<List<ShoppingListItem>> {
  ShoppingListStreamProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'shoppingListStreamProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$shoppingListStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<ShoppingListItem>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<ShoppingListItem>> create(Ref ref) {
    return shoppingListStream(ref);
  }
}

String _$shoppingListStreamHash() =>
    r'1ab822fd003ace132bc1121d86deca42944c9364';

@ProviderFor(ShoppingListActions)
final shoppingListActionsProvider = ShoppingListActionsProvider._();

final class ShoppingListActionsProvider
    extends $NotifierProvider<ShoppingListActions, void> {
  ShoppingListActionsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'shoppingListActionsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$shoppingListActionsHash();

  @$internal
  @override
  ShoppingListActions create() => ShoppingListActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$shoppingListActionsHash() =>
    r'6cac41d2aa7b3de7526f550b02d86e7f7b8ff08c';

abstract class _$ShoppingListActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
