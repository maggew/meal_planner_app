import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/domain/entities/user_settings.dart';
import 'package:meal_planner/domain/enums/week_start_day.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/shared_preferences_provider.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- Fake Session Notifier ---

class FakeSessionNotifier extends StateNotifier<SessionState>
    implements SessionController {
  FakeSessionNotifier(super.state);

  @override
  Future<void> loadSession(String userId) async {}
  @override
  Future<void> joinGroup(String groupId) async {}
  @override
  Future<void> setActiveGroup(String groupId) async {}
  @override
  Future<void> reloadActiveGroup() async {}
  @override
  void setActiveUserAfterRegistration(String userId) {}
  @override
  Future<void> changeSettings(UserSettings settings) async {}
  @override
  Future<void> clearSession() async {}
  @override
  Ref get ref => throw UnimplementedError();
}

// --- Tests ---

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  ProviderContainer _makeContainer({
    required String? groupId,
    Map<String, Object> prefsValues = const {},
  }) {
    for (final entry in prefsValues.entries) {
      prefs.setString(entry.key, entry.value as String);
    }
    return ProviderContainer(overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      sessionProvider.overrideWith(
        (ref) => FakeSessionNotifier(
          SessionState(userId: groupId != null ? 'u1' : null, groupId: groupId),
        ),
      ),
    ]);
  }

  group('GroupSettingsNotifier.build()', () {
    test('gibt defaultSettings zurück wenn kein groupId in Session', () {
      final container = _makeContainer(groupId: null);
      addTearDown(container.dispose);

      final settings = container.read(groupSettingsProvider);

      expect(settings.weekStartDay, equals(GroupSettings.defaultSettings.weekStartDay));
      expect(settings.defaultMealSlots, equals(GroupSettings.defaultSettings.defaultMealSlots));
    });

    test('gibt defaultSettings zurück wenn kein gespeicherter Wert existiert', () {
      final container = _makeContainer(groupId: 'g1');
      addTearDown(container.dispose);

      final settings = container.read(groupSettingsProvider);

      expect(settings.weekStartDay, equals(GroupSettings.defaultSettings.weekStartDay));
    });

    test('lädt gespeicherte Einstellungen aus SharedPreferences', () {
      final container = _makeContainer(
        groupId: 'g1',
        prefsValues: {
          'group_settings_g1': jsonEncode({
            'week_start_day': 'sunday',
            'default_meal_slots': ['breakfast', 'lunch'],
          }),
        },
      );
      addTearDown(container.dispose);

      final settings = container.read(groupSettingsProvider);

      expect(settings.weekStartDay, equals(WeekStartDay.sunday));
    });

    test('gibt defaultSettings zurück bei ungültigem JSON im Cache', () {
      final container = _makeContainer(
        groupId: 'g1',
        prefsValues: {'group_settings_g1': 'kein-valides-json{{{'},
      );
      addTearDown(container.dispose);

      final settings = container.read(groupSettingsProvider);

      expect(settings.weekStartDay, equals(GroupSettings.defaultSettings.weekStartDay));
    });

    test('verschiedene Gruppen haben unabhängige Einstellungen', () async {
      final container = ProviderContainer(overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        sessionProvider.overrideWith(
          (ref) => FakeSessionNotifier(
            const SessionState(userId: 'u1', groupId: 'g1'),
          ),
        ),
      ]);
      addTearDown(container.dispose);

      await prefs.setString(
        'group_settings_g1',
        jsonEncode({'week_start_day': 'sunday', 'default_meal_slots': []}),
      );
      await prefs.setString(
        'group_settings_g2',
        jsonEncode({'week_start_day': 'saturday', 'default_meal_slots': []}),
      );

      // Gruppe 1: Sonntag
      final settingsG1 = container.read(groupSettingsProvider);
      expect(settingsG1.weekStartDay, equals(WeekStartDay.sunday));
    });
  });

  group('GroupSettingsNotifier.update()', () {
    test('speichert Einstellungen in SharedPreferences unter richtigem Key',
        () async {
      final container = _makeContainer(groupId: 'g1');
      addTearDown(container.dispose);

      await container
          .read(groupSettingsProvider.notifier)
          .update(GroupSettings(weekStartDay: WeekStartDay.sunday));

      final raw = prefs.getString('group_settings_g1');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as Map<String, dynamic>;
      expect(decoded['week_start_day'], equals('sunday'));
    });

    test('aktualisiert State sofort (vor SharedPreferences-Write)', () async {
      final container = _makeContainer(groupId: 'g1');
      addTearDown(container.dispose);

      await container
          .read(groupSettingsProvider.notifier)
          .update(GroupSettings(weekStartDay: WeekStartDay.sunday));

      final settings = container.read(groupSettingsProvider);
      expect(settings.weekStartDay, equals(WeekStartDay.sunday));
    });

    test('tut nichts wenn kein groupId in Session', () async {
      final container = _makeContainer(groupId: null);
      addTearDown(container.dispose);

      await container
          .read(groupSettingsProvider.notifier)
          .update(GroupSettings(weekStartDay: WeekStartDay.sunday));

      // Kein Key sollte gesetzt worden sein
      expect(prefs.getKeys(), isEmpty);
    });

    test('Einstellungen bleiben nach Neustart erhalten (neuer Container, selbe prefs)',
        () async {
      // Schritt 1: Einstellungen speichern
      final container1 = _makeContainer(groupId: 'g1');
      await container1
          .read(groupSettingsProvider.notifier)
          .update(GroupSettings(weekStartDay: WeekStartDay.sunday));
      container1.dispose();

      // Schritt 2: Neuen Container erstellen (simuliert App-Neustart)
      final container2 = _makeContainer(groupId: 'g1');
      addTearDown(container2.dispose);

      final settings = container2.read(groupSettingsProvider);
      expect(settings.weekStartDay, equals(WeekStartDay.sunday),
          reason: 'Einstellungen sollten nach Neustart noch vorhanden sein');
    });

    test('Einstellungen werden gruppenspezifisch gespeichert', () async {
      final container1 = _makeContainer(groupId: 'g1');
      addTearDown(container1.dispose);

      await container1
          .read(groupSettingsProvider.notifier)
          .update(GroupSettings(weekStartDay: WeekStartDay.sunday));

      // Gruppe g2 hat eigene (Default-)Einstellungen
      expect(prefs.getString('group_settings_g2'), isNull);
    });
  });
}
