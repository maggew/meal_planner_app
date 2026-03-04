// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trash_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Trash)
final trashProvider = TrashProvider._();

final class TrashProvider extends $NotifierProvider<Trash, TrashState> {
  TrashProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'trashProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$trashHash();

  @$internal
  @override
  Trash create() => Trash();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrashState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrashState>(value),
    );
  }
}

String _$trashHash() => r'1fc6670073214411e8c168effd9f0cf6028dbe46';

abstract class _$Trash extends $Notifier<TrashState> {
  TrashState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TrashState, TrashState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TrashState, TrashState>, TrashState, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
