// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_timer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveTimerNotifier)
final activeTimerProvider = ActiveTimerNotifierProvider._();

final class ActiveTimerNotifierProvider
    extends $NotifierProvider<ActiveTimerNotifier, Map<String, ActiveTimer>> {
  ActiveTimerNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeTimerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeTimerNotifierHash();

  @$internal
  @override
  ActiveTimerNotifier create() => ActiveTimerNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, ActiveTimer> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, ActiveTimer>>(value),
    );
  }
}

String _$activeTimerNotifierHash() =>
    r'83e20a067182a7019a4699b15e9e32d47b8b0d5d';

abstract class _$ActiveTimerNotifier
    extends $Notifier<Map<String, ActiveTimer>> {
  Map<String, ActiveTimer> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<Map<String, ActiveTimer>, Map<String, ActiveTimer>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<Map<String, ActiveTimer>, Map<String, ActiveTimer>>,
        Map<String, ActiveTimer>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
