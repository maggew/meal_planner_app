// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(consentService)
final consentServiceProvider = ConsentServiceProvider._();

final class ConsentServiceProvider
    extends $FunctionalProvider<ConsentService, ConsentService, ConsentService>
    with $Provider<ConsentService> {
  ConsentServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'consentServiceProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$consentServiceHash();

  @$internal
  @override
  $ProviderElement<ConsentService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConsentService create(Ref ref) {
    return consentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsentService>(value),
    );
  }
}

String _$consentServiceHash() => r'28a82baf163d70495e3f23a84ef5fd1af60afc9b';

@ProviderFor(AnalyticsConsent)
final analyticsConsentProvider = AnalyticsConsentProvider._();

final class AnalyticsConsentProvider
    extends $NotifierProvider<AnalyticsConsent, bool> {
  AnalyticsConsentProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'analyticsConsentProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$analyticsConsentHash();

  @$internal
  @override
  AnalyticsConsent create() => AnalyticsConsent();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$analyticsConsentHash() => r'04ff9afa2eb47d0a11e57e7f9e0087594bda1d72';

abstract class _$AnalyticsConsent extends $Notifier<bool> {
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
