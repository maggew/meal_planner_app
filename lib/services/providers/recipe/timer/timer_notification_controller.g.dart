// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timer_notification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(timerNotificationController)
final timerNotificationControllerProvider =
    TimerNotificationControllerProvider._();

final class TimerNotificationControllerProvider
    extends $FunctionalProvider<void, void, void> with $Provider<void> {
  TimerNotificationControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'timerNotificationControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$timerNotificationControllerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return timerNotificationController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$timerNotificationControllerHash() =>
    r'a2917156445df0f5c5ecfee74087f7655b50de31';
