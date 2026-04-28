// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_non_empty_category_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Returns the ID of the first category (by sort_order) that contains at least
/// one recipe. Returns null if no recipes exist at all. Used for the one-time
/// auto-jump on cookbook open.

@ProviderFor(firstNonEmptyCategoryId)
final firstNonEmptyCategoryIdProvider = FirstNonEmptyCategoryIdProvider._();

/// Returns the ID of the first category (by sort_order) that contains at least
/// one recipe. Returns null if no recipes exist at all. Used for the one-time
/// auto-jump on cookbook open.

final class FirstNonEmptyCategoryIdProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// Returns the ID of the first category (by sort_order) that contains at least
  /// one recipe. Returns null if no recipes exist at all. Used for the one-time
  /// auto-jump on cookbook open.
  FirstNonEmptyCategoryIdProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'firstNonEmptyCategoryIdProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$firstNonEmptyCategoryIdHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return firstNonEmptyCategoryId(ref);
  }
}

String _$firstNonEmptyCategoryIdHash() =>
    r'65ce0ea3a7ebc29bc4fb14ae98aada0cfc6f66a5';
