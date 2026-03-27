import 'package:meal_planner/services/consent_service.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'consent_provider.g.dart';

@Riverpod(keepAlive: true)
ConsentService consentService(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ConsentService(prefs);
}

@Riverpod(keepAlive: true)
class AnalyticsConsent extends _$AnalyticsConsent {
  @override
  bool build() => ref.watch(consentServiceProvider).analyticsConsent;

  Future<void> setConsent(bool value) async {
    await ref.read(consentServiceProvider).setAnalyticsConsent(value);
    state = value;
  }
}
