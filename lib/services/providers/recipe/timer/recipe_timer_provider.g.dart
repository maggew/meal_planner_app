// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recipeTimers)
final recipeTimersProvider = RecipeTimersFamily._();

final class RecipeTimersProvider extends $FunctionalProvider<
        AsyncValue<Map<int, RecipeTimer>>,
        Map<int, RecipeTimer>,
        FutureOr<Map<int, RecipeTimer>>>
    with
        $FutureModifier<Map<int, RecipeTimer>>,
        $FutureProvider<Map<int, RecipeTimer>> {
  RecipeTimersProvider._(
      {required RecipeTimersFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'recipeTimersProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recipeTimersHash();

  @override
  String toString() {
    return r'recipeTimersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<int, RecipeTimer>> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, RecipeTimer>> create(Ref ref) {
    final argument = this.argument as String;
    return recipeTimers(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RecipeTimersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$recipeTimersHash() => r'd7afde94b5e1447edf0f43c4b0d09c20ba2a60c2';

final class RecipeTimersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Map<int, RecipeTimer>>, String> {
  RecipeTimersFamily._()
      : super(
          retry: null,
          name: r'recipeTimersProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  RecipeTimersProvider call(
    String recipeId,
  ) =>
      RecipeTimersProvider._(argument: recipeId, from: this);

  @override
  String toString() => r'recipeTimersProvider';
}
