import 'package:firebase_analytics_platform_interface/firebase_analytics_platform_interface.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart' as firebase_test;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/src/ad_instance_manager.dart';
import 'package:google_mobile_ads/src/ump/user_messaging_codec.dart';
import 'package:meal_planner/services/consent_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Firebase Analytics Platform Mock ──────────────────────────────────────

class MockFirebaseAnalyticsPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements FirebaseAnalyticsPlatform {
  @override
  FirebaseAnalyticsPlatform delegateFor({
    required FirebaseApp app,
    Map<String, dynamic>? webOptions,
  }) =>
      this;
}

// ── Tests ──────────────────────────────────────────────────────────────────

void main() {
  late MockFirebaseAnalyticsPlatform mockAnalytics;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    firebase_test.setupFirebaseCoreMocks();
    await Firebase.initializeApp();

    mockAnalytics = MockFirebaseAnalyticsPlatform();
    when(() => mockAnalytics.setAnalyticsCollectionEnabled(any()))
        .thenAnswer((_) async {});
    FirebaseAnalyticsPlatform.instance = mockAnalytics;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    reset(mockAnalytics);
    when(() => mockAnalytics.setAnalyticsCollectionEnabled(any()))
        .thenAnswer((_) async {});
  });

  Future<ConsentService> make(
      [Map<String, Object> prefs = const {}]) async {
    SharedPreferences.setMockInitialValues(prefs);
    final sharedPrefs = await SharedPreferences.getInstance();
    return ConsentService(sharedPrefs);
  }

  // ── analyticsConsentAsked ──────────────────────────────────────────────

  group('analyticsConsentAsked', () {
    test('false wenn noch nicht gesetzt', () async {
      final svc = await make();
      expect(svc.analyticsConsentAsked, isFalse);
    });

    test('true wenn in prefs true', () async {
      final svc = await make({'analytics_consent_asked': true});
      expect(svc.analyticsConsentAsked, isTrue);
    });
  });

  // ── analyticsConsent ───────────────────────────────────────────────────

  group('analyticsConsent', () {
    test('false wenn noch nicht gesetzt', () async {
      final svc = await make();
      expect(svc.analyticsConsent, isFalse);
    });

    test('true wenn in prefs true', () async {
      final svc = await make({
        'analytics_consent': true,
        'analytics_consent_asked': true,
      });
      expect(svc.analyticsConsent, isTrue);
    });

    test('false wenn in prefs false', () async {
      final svc = await make({
        'analytics_consent': false,
        'analytics_consent_asked': true,
      });
      expect(svc.analyticsConsent, isFalse);
    });
  });

  // ── setAnalyticsConsent ────────────────────────────────────────────────

  group('setAnalyticsConsent', () {
    test('true → beide Keys korrekt gespeichert', () async {
      final svc = await make();
      await svc.setAnalyticsConsent(true);

      expect(svc.analyticsConsent, isTrue);
      expect(svc.analyticsConsentAsked, isTrue);
    });

    test('false → beide Keys korrekt gespeichert', () async {
      final svc = await make();
      await svc.setAnalyticsConsent(false);

      expect(svc.analyticsConsent, isFalse);
      expect(svc.analyticsConsentAsked, isTrue);
    });

    test('überschreibt vorherigen Wert', () async {
      final svc = await make({'analytics_consent': true});
      await svc.setAnalyticsConsent(false);

      expect(svc.analyticsConsent, isFalse);
    });

    test('true → Firebase setAnalyticsCollectionEnabled(true) aufgerufen',
        () async {
      final svc = await make();
      await svc.setAnalyticsConsent(true);

      verify(() => mockAnalytics.setAnalyticsCollectionEnabled(true)).called(1);
    });

    test('false → Firebase setAnalyticsCollectionEnabled(false) aufgerufen',
        () async {
      final svc = await make();
      await svc.setAnalyticsConsent(false);

      verify(() => mockAnalytics.setAnalyticsCollectionEnabled(false))
          .called(1);
    });
  });

  // ── applyStoredAnalyticsConsent ────────────────────────────────────────

  group('applyStoredAnalyticsConsent', () {
    test('noch nicht gefragt → kein Firebase-Aufruf', () async {
      final svc = await make();
      await svc.applyStoredAnalyticsConsent();

      verifyNever(() => mockAnalytics.setAnalyticsCollectionEnabled(any()));
    });

    test('gefragt + consent=true → Firebase mit true aufgerufen', () async {
      final svc = await make({
        'analytics_consent': true,
        'analytics_consent_asked': true,
      });
      await svc.applyStoredAnalyticsConsent();

      verify(() => mockAnalytics.setAnalyticsCollectionEnabled(true)).called(1);
    });

    test('gefragt + consent=false → Firebase mit false aufgerufen', () async {
      final svc = await make({
        'analytics_consent': false,
        'analytics_consent_asked': true,
      });
      await svc.applyStoredAnalyticsConsent();

      verify(() => mockAnalytics.setAnalyticsCollectionEnabled(false))
          .called(1);
    });
  });

  // ── requestAdsConsent ──────────────────────────────────────────────────

  group('requestAdsConsent', () {
    late MethodChannel umpChannel;
    late MethodChannel adsChannel;
    final List<String> calledMethods = [];

    setUp(() {
      calledMethods.clear();
      umpChannel = MethodChannel(
        'plugins.flutter.io/google_mobile_ads/ump',
        StandardMethodCodec(UserMessagingCodec()),
      );
      adsChannel = MethodChannel(
        'plugins.flutter.io/google_mobile_ads',
        StandardMethodCodec(AdMessageCodec()),
      );
      // Ads channel: handle _init (singleton) + initialize
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(adsChannel, (MethodCall call) async {
        if (call.method == 'MobileAds#initialize') {
          calledMethods.add('MobileAds#initialize');
          return InitializationStatus(<String, AdapterStatus>{});
        }
        return null; // _init and others
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(umpChannel, null);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(adsChannel, null);
    });

    test('Consent-Form verfügbar → lädt Form + initialisiert Ads', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(umpChannel, (MethodCall call) async {
        calledMethods.add(call.method);
        switch (call.method) {
          case 'ConsentInformation#requestConsentInfoUpdate':
            return null;
          case 'ConsentInformation#isConsentFormAvailable':
            return true;
          case 'UserMessagingPlatform#loadAndShowConsentFormIfRequired':
            return null;
          default:
            return null;
        }
      });

      final svc = await make();
      await svc.requestAdsConsent();

      expect(calledMethods, containsAllInOrder([
        'ConsentInformation#requestConsentInfoUpdate',
        'ConsentInformation#isConsentFormAvailable',
        'UserMessagingPlatform#loadAndShowConsentFormIfRequired',
        'MobileAds#initialize',
      ]));
    });

    test('keine Consent-Form → überspringt Form, initialisiert Ads', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(umpChannel, (MethodCall call) async {
        calledMethods.add(call.method);
        switch (call.method) {
          case 'ConsentInformation#requestConsentInfoUpdate':
            return null;
          case 'ConsentInformation#isConsentFormAvailable':
            return false;
          default:
            return null;
        }
      });

      final svc = await make();
      await svc.requestAdsConsent();

      expect(calledMethods, containsAllInOrder([
        'ConsentInformation#requestConsentInfoUpdate',
        'ConsentInformation#isConsentFormAvailable',
        'MobileAds#initialize',
      ]));
      expect(calledMethods,
          isNot(contains('UserMessagingPlatform#loadAndShowConsentFormIfRequired')));
    });

    test('Fehler bei consentInfoUpdate → initialisiert Ads trotzdem', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(umpChannel, (MethodCall call) async {
        calledMethods.add(call.method);
        if (call.method == 'ConsentInformation#requestConsentInfoUpdate') {
          throw PlatformException(code: '1', message: 'network error');
        }
        return null;
      });

      final svc = await make();
      await svc.requestAdsConsent();

      expect(calledMethods, contains('ConsentInformation#requestConsentInfoUpdate'));
      expect(calledMethods, contains('MobileAds#initialize'));
      expect(calledMethods,
          isNot(contains('ConsentInformation#isConsentFormAvailable')));
    });
  });

  // ── resetAdsConsent ────────────────────────────────────────────────────

  group('resetAdsConsent', () {
    test('ruft ConsentInformation#reset auf', () async {
      final umpChannel = MethodChannel(
        'plugins.flutter.io/google_mobile_ads/ump',
        StandardMethodCodec(UserMessagingCodec()),
      );
      bool resetCalled = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(umpChannel, (MethodCall call) async {
        if (call.method == 'ConsentInformation#reset') {
          resetCalled = true;
        }
        return null;
      });

      final svc = await make();
      await svc.resetAdsConsent();

      expect(resetCalled, isTrue);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(umpChannel, null);
    });
  });
}
