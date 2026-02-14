// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_edit_recipe_ingredients_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddEditRecipeIngredients)
const addEditRecipeIngredientsProvider = AddEditRecipeIngredientsFamily._();

final class AddEditRecipeIngredientsProvider extends $NotifierProvider<
    AddEditRecipeIngredients, AddEditRecipeIngredientsState> {
  const AddEditRecipeIngredientsProvider._(
      {required AddEditRecipeIngredientsFamily super.from,
      required List<IngredientSection>? super.argument})
      : super(
          retry: null,
          name: r'addEditRecipeIngredientsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$addEditRecipeIngredientsHash();

  @override
  String toString() {
    return r'addEditRecipeIngredientsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddEditRecipeIngredients create() => AddEditRecipeIngredients();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddEditRecipeIngredientsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AddEditRecipeIngredientsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddEditRecipeIngredientsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addEditRecipeIngredientsHash() =>
    r'ed946a96174e3a6372aea02e4f7a4a6c9f2c525e';

final class AddEditRecipeIngredientsFamily extends $Family
    with
        $ClassFamilyOverride<
            AddEditRecipeIngredients,
            AddEditRecipeIngredientsState,
            AddEditRecipeIngredientsState,
            AddEditRecipeIngredientsState,
            List<IngredientSection>?> {
  const AddEditRecipeIngredientsFamily._()
      : super(
          retry: null,
          name: r'addEditRecipeIngredientsProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  AddEditRecipeIngredientsProvider call(
    List<IngredientSection>? initialSections,
  ) =>
      AddEditRecipeIngredientsProvider._(argument: initialSections, from: this);

  @override
  String toString() => r'addEditRecipeIngredientsProvider';
}

abstract class _$AddEditRecipeIngredients
    extends $Notifier<AddEditRecipeIngredientsState> {
  late final _$args = ref.$arg as List<IngredientSection>?;
  List<IngredientSection>? get initialSections => _$args;

  AddEditRecipeIngredientsState build(
    List<IngredientSection>? initialSections,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args,
    );
    final ref = this.ref
        as $Ref<AddEditRecipeIngredientsState, AddEditRecipeIngredientsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AddEditRecipeIngredientsState,
            AddEditRecipeIngredientsState>,
        AddEditRecipeIngredientsState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
