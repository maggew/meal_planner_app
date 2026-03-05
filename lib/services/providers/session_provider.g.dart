// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SessionNotifier)
final sessionProvider = SessionNotifierProvider._();

final class SessionNotifierProvider
    extends $NotifierProvider<SessionNotifier, SessionState> {
  SessionNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sessionProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sessionNotifierHash();

  @$internal
  @override
  SessionNotifier create() => SessionNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SessionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SessionState>(value),
    );
  }
}

String _$sessionNotifierHash() => r'bf4cd0f63fc1fe0802e6789153a2cbb85720a2d7';

abstract class _$SessionNotifier extends $Notifier<SessionState> {
  SessionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SessionState, SessionState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SessionState, SessionState>,
        SessionState,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
