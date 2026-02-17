// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_pagination_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecipesPagination)
final recipesPaginationProvider = RecipesPaginationFamily._();

final class RecipesPaginationProvider
    extends $NotifierProvider<RecipesPagination, RecipesPaginationState> {
  RecipesPaginationProvider._(
      {required RecipesPaginationFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'recipesPaginationProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recipesPaginationHash();

  @override
  String toString() {
    return r'recipesPaginationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RecipesPagination create() => RecipesPagination();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RecipesPaginationState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RecipesPaginationState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecipesPaginationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipesPaginationHash() => r'b10f096b8f523fa574ec89d84cd76dc3b464fdf4';

final class RecipesPaginationFamily extends $Family
    with
        $ClassFamilyOverride<RecipesPagination, RecipesPaginationState,
            RecipesPaginationState, RecipesPaginationState, String> {
  RecipesPaginationFamily._()
      : super(
          retry: null,
          name: r'recipesPaginationProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: false,
        );

  RecipesPaginationProvider call(
    String category,
  ) =>
      RecipesPaginationProvider._(argument: category, from: this);

  @override
  String toString() => r'recipesPaginationProvider';
}

abstract class _$RecipesPagination extends $Notifier<RecipesPaginationState> {
  late final _$args = ref.$arg as String;
  String get category => _$args;

  RecipesPaginationState build(
    String category,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<RecipesPaginationState, RecipesPaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RecipesPaginationState, RecipesPaginationState>,
        RecipesPaginationState,
        Object?,
        Object?>;
    element.handleCreate(
        ref,
        () => build(
              _$args,
            ));
  }
}
