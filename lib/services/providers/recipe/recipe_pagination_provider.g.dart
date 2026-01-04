// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_pagination_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecipesPagination)
const recipesPaginationProvider = RecipesPaginationFamily._();

final class RecipesPaginationProvider
    extends $NotifierProvider<RecipesPagination, RecipesPaginationState> {
  const RecipesPaginationProvider._(
      {required RecipesPaginationFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'recipesPaginationProvider',
          isAutoDispose: true,
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

String _$recipesPaginationHash() => r'07a5a899031a43c4a6b2b048e98a91b8a1a0486c';

final class RecipesPaginationFamily extends $Family
    with
        $ClassFamilyOverride<RecipesPagination, RecipesPaginationState,
            RecipesPaginationState, RecipesPaginationState, String> {
  const RecipesPaginationFamily._()
      : super(
          retry: null,
          name: r'recipesPaginationProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
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
    final created = build(
      _$args,
    );
    final ref =
        this.ref as $Ref<RecipesPaginationState, RecipesPaginationState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<RecipesPaginationState, RecipesPaginationState>,
        RecipesPaginationState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
