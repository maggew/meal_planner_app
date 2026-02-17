// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserSettingsNotifier)
final userSettingsProvider = UserSettingsNotifierProvider._();

final class UserSettingsNotifierProvider
    extends $NotifierProvider<UserSettingsNotifier, UserSettings> {
  UserSettingsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'userSettingsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$userSettingsNotifierHash();

  @$internal
  @override
  UserSettingsNotifier create() => UserSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserSettings>(value),
    );
  }
}

String _$userSettingsNotifierHash() =>
    r'86cef926321425bda77f766c1ef5c198a7d6ee15';

abstract class _$UserSettingsNotifier extends $Notifier<UserSettings> {
  UserSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserSettings, UserSettings>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<UserSettings, UserSettings>,
        UserSettings,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
