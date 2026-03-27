import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConsentService {
  static const _analyticsConsentKey = 'analytics_consent';
  static const _analyticsConsentAskedKey = 'analytics_consent_asked';

  final SharedPreferences _prefs;

  ConsentService(this._prefs);

  bool get analyticsConsentAsked =>
      _prefs.getBool(_analyticsConsentAskedKey) ?? false;

  bool get analyticsConsent => _prefs.getBool(_analyticsConsentKey) ?? false;

  Future<void> setAnalyticsConsent(bool value) async {
    await _prefs.setBool(_analyticsConsentKey, value);
    await _prefs.setBool(_analyticsConsentAskedKey, true);
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(value);
  }

  /// Applies the stored analytics consent decision (called on every app start).
  Future<void> applyStoredAnalyticsConsent() async {
    if (analyticsConsentAsked) {
      await FirebaseAnalytics.instance
          .setAnalyticsCollectionEnabled(analyticsConsent);
    }
    // If not asked yet, analytics stays disabled (AndroidManifest default).
  }

  /// Runs the Google UMP consent flow and initializes MobileAds afterwards.
  Future<void> requestAdsConsent() async {
    final completer = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          ConsentForm.loadAndShowConsentFormIfRequired((_) async {
            await MobileAds.instance.initialize();
            completer.complete();
          });
        } else {
          await MobileAds.instance.initialize();
          completer.complete();
        }
      },
      (_) async {
        // On error: still initialize ads (user may be outside EU).
        await MobileAds.instance.initialize();
        completer.complete();
      },
    );

    return completer.future;
  }

  /// Resets the UMP consent state so the form is shown again on next call.
  Future<void> resetAdsConsent() async {
    await ConsentInformation.instance.reset();
  }
}
