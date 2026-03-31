// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_sync_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(recipeDeltaSync)
final recipeDeltaSyncProvider = RecipeDeltaSyncProvider._();

final class RecipeDeltaSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  RecipeDeltaSyncProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'recipeDeltaSyncProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$recipeDeltaSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return recipeDeltaSync(ref);
  }
}

String _$recipeDeltaSyncHash() => r'93b625230a09c276d6facb55e0b11b15a5a358e9';
