// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_tick_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TimerTick)
final timerTickProvider = TimerTickProvider._();

final class TimerTickProvider extends $NotifierProvider<TimerTick, int> {
  TimerTickProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'timerTickProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$timerTickHash();

  @$internal
  @override
  TimerTick create() => TimerTick();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$timerTickHash() => r'70b15e2caa73247e55a7abe029f4b51393aee40b';

abstract class _$TimerTick extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element = ref.element
        as $ClassProviderElement<AnyNotifier<int, int>, int, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
