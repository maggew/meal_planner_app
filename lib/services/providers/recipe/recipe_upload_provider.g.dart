// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_upload_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RecipeUpload)
const recipeUploadProvider = RecipeUploadProvider._();

final class RecipeUploadProvider
    extends $NotifierProvider<RecipeUpload, AsyncValue<void>> {
  const RecipeUploadProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recipeUploadProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recipeUploadHash();

  @$internal
  @override
  RecipeUpload create() => RecipeUpload();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$recipeUploadHash() => r'9239eb89ab2f8b83ba1283934d9e4525a1a94592';

abstract class _$RecipeUpload extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
        AsyncValue<void>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
