// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slot_drag_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// True while a meal-slot drag gesture is in progress. Widgets read this to
/// expand empty-day compact buttons into full drop targets and to apply the
/// subtle drop-zone outline across the weekplan.

@ProviderFor(IsDraggingSlot)
final isDraggingSlotProvider = IsDraggingSlotProvider._();

/// True while a meal-slot drag gesture is in progress. Widgets read this to
/// expand empty-day compact buttons into full drop targets and to apply the
/// subtle drop-zone outline across the weekplan.
final class IsDraggingSlotProvider
    extends $NotifierProvider<IsDraggingSlot, bool> {
  /// True while a meal-slot drag gesture is in progress. Widgets read this to
  /// expand empty-day compact buttons into full drop targets and to apply the
  /// subtle drop-zone outline across the weekplan.
  IsDraggingSlotProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isDraggingSlotProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isDraggingSlotHash();

  @$internal
  @override
  IsDraggingSlot create() => IsDraggingSlot();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isDraggingSlotHash() => r'b23ec2ddb6e0c8a0a134badd2b35b015ae7c4159';

/// True while a meal-slot drag gesture is in progress. Widgets read this to
/// expand empty-day compact buttons into full drop targets and to apply the
/// subtle drop-zone outline across the weekplan.

abstract class _$IsDraggingSlot extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// True while the drag pointer sits on one of the week-strip chevrons. The
/// auto-scroller reads it so the viewport stays still during a dwell —
/// otherwise the stale pointer position (pinned near the top edge) would
/// keep advancing the scroll and hide the week change from the user.

@ProviderFor(IsHoveringChevron)
final isHoveringChevronProvider = IsHoveringChevronProvider._();

/// True while the drag pointer sits on one of the week-strip chevrons. The
/// auto-scroller reads it so the viewport stays still during a dwell —
/// otherwise the stale pointer position (pinned near the top edge) would
/// keep advancing the scroll and hide the week change from the user.
final class IsHoveringChevronProvider
    extends $NotifierProvider<IsHoveringChevron, bool> {
  /// True while the drag pointer sits on one of the week-strip chevrons. The
  /// auto-scroller reads it so the viewport stays still during a dwell —
  /// otherwise the stale pointer position (pinned near the top edge) would
  /// keep advancing the scroll and hide the week change from the user.
  IsHoveringChevronProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'isHoveringChevronProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$isHoveringChevronHash();

  @$internal
  @override
  IsHoveringChevron create() => IsHoveringChevron();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isHoveringChevronHash() => r'e2d3896d57a12bf0efe2a3bd4b084fd8b86c8f7f';

/// True while the drag pointer sits on one of the week-strip chevrons. The
/// auto-scroller reads it so the viewport stays still during a dwell —
/// otherwise the stale pointer position (pinned near the top edge) would
/// keep advancing the scroll and hide the week change from the user.

abstract class _$IsHoveringChevron extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
