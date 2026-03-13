// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_plan_clipboard_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MealPlanClipboard)
final mealPlanClipboardProvider = MealPlanClipboardProvider._();

final class MealPlanClipboardProvider
    extends $NotifierProvider<MealPlanClipboard, MealPlanClipboardEntry?> {
  MealPlanClipboardProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'mealPlanClipboardProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$mealPlanClipboardHash();

  @$internal
  @override
  MealPlanClipboard create() => MealPlanClipboard();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MealPlanClipboardEntry? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MealPlanClipboardEntry?>(value),
    );
  }
}

String _$mealPlanClipboardHash() => r'a04f48a23afa3b2fa0831df4ebb8a4f93b828f0b';

abstract class _$MealPlanClipboard extends $Notifier<MealPlanClipboardEntry?> {
  MealPlanClipboardEntry? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<MealPlanClipboardEntry?, MealPlanClipboardEntry?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<MealPlanClipboardEntry?, MealPlanClipboardEntry?>,
        MealPlanClipboardEntry?,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
