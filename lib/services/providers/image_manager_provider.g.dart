// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_manager_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ImageManager)
final imageManagerProvider = ImageManagerProvider._();

final class ImageManagerProvider
    extends $NotifierProvider<ImageManager, CustomImages> {
  ImageManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'imageManagerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$imageManagerHash();

  @$internal
  @override
  ImageManager create() => ImageManager();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CustomImages value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CustomImages>(value),
    );
  }
}

String _$imageManagerHash() => r'bc6fc33cbd0d87672826a762b2c4fae9874f481a';

abstract class _$ImageManager extends $Notifier<CustomImages> {
  CustomImages build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CustomImages, CustomImages>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<CustomImages, CustomImages>,
        CustomImages,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
