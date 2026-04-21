// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_cooking_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveCookingSession)
final activeCookingSessionProvider = ActiveCookingSessionProvider._();

final class ActiveCookingSessionProvider
    extends $NotifierProvider<ActiveCookingSession, ActiveCookingSessionState> {
  ActiveCookingSessionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeCookingSessionProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeCookingSessionHash();

  @$internal
  @override
  ActiveCookingSession create() => ActiveCookingSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveCookingSessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveCookingSessionState>(value),
    );
  }
}

String _$activeCookingSessionHash() =>
    r'617f8836af803ea33171a5b07e12aae6c30f8673';

abstract class _$ActiveCookingSession
    extends $Notifier<ActiveCookingSessionState> {
  ActiveCookingSessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ActiveCookingSessionState, ActiveCookingSessionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<ActiveCookingSessionState, ActiveCookingSessionState>,
        ActiveCookingSessionState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
