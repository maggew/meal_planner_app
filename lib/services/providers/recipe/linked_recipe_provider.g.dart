// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'linked_recipe_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(linkedRecipe)
final linkedRecipeProvider = LinkedRecipeFamily._();

final class LinkedRecipeProvider
    extends $FunctionalProvider<AsyncValue<Recipe?>, Recipe?, FutureOr<Recipe?>>
    with $FutureModifier<Recipe?>, $FutureProvider<Recipe?> {
  LinkedRecipeProvider._(
      {required LinkedRecipeFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'linkedRecipeProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$linkedRecipeHash();

  @override
  String toString() {
    return r'linkedRecipeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Recipe?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Recipe?> create(Ref ref) {
    final argument = this.argument as String;
    return linkedRecipe(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LinkedRecipeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$linkedRecipeHash() => r'd9e1768104065ade031979383f0221a36fe23ffa';

final class LinkedRecipeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Recipe?>, String> {
  LinkedRecipeFamily._()
      : super(
          retry: null,
          name: r'linkedRecipeProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  LinkedRecipeProvider call(
    String recipeId,
  ) =>
      LinkedRecipeProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'linkedRecipeProvider';
}
