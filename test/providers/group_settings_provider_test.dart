import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/group.dart';
import 'package:meal_planner/domain/entities/group_settings.dart';
import 'package:meal_planner/domain/enums/meal_type.dart';
import 'package:meal_planner/domain/enums/week_start_day.dart';
import 'package:meal_planner/domain/repositories/group_repository.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:meal_planner/services/providers/session_provider.dart';
import 'package:meal_planner/services/providers/user/group_settings_provider.dart';
import 'package:mocktail/mocktail.dart';

// --- Mocks ---

class MockGroupRepository extends Mock implements GroupRepository {}

class _TestSessionNotifier extends SessionNotifier {
  _TestSessionNotifier(this._initial);
  final SessionState _initial;

  @override
  SessionState build() => _initial;
}

// --- Helpers ---

ProviderContainer _makeContainer({
  required SessionState sessionState,
  GroupRepository? groupRepo,
}) {
  final repo = groupRepo ?? MockGroupRepository();
  return ProviderContainer(overrides: [
    sessionProvider.overrideWithValue(sessionState),
    groupRepositoryProvider.overrideWithValue(repo),
  ]);
}

/// Container for tests that invoke [GroupSettingsNotifier.update], which
/// internally accesses [sessionProvider.notifier]. [overrideWithValue] does
/// not expose a notifier, so we need [overrideWith] with a real notifier here.
ProviderContainer _makeNotifierContainer({
  required SessionState sessionState,
  GroupRepository? groupRepo,
}) {
  final repo = groupRepo ?? MockGroupRepository();
  return ProviderContainer(overrides: [
    sessionProvider.overrideWith(() => _TestSessionNotifier(sessionState)),
    groupRepositoryProvider.overrideWithValue(repo),
  ]);
}

Group _groupWithSettings(GroupSettings settings) => Group(
      id: 'g1',
      name: 'Test',
      imageUrl: '',
      settings: settings,
    );

// --- Tests ---

void main() {
  setUpAll(() {
    registerFallbackValue(GroupSettings.defaultSettings);
  });

  group('GroupSettingsNotifier.build()', () {
    test('gibt defaultSettings zurück wenn keine Gruppe in Session', () {
      final container = _makeContainer(
        sessionState: const SessionState(userId: 'u1', groupId: null),
      );
      addTearDown(container.dispose);

      final settings = container.read(groupSettingsProvider);

      expect(settings.weekStartDay, GroupSettings.defaultSettings.weekStartDay);
      expect(settings.defaultMealSlots,
          GroupSettings.defaultSettings.defaultMealSlots);
      expect(settings.showCarbTags, GroupSettings.defaultSettings.showCarbTags);
    });

    test('liest Einstellungen direkt aus session.group.settings', () {
      final customSettings = GroupSettings(
        weekStartDay: WeekStartDay.sunday,
        defaultMealSlots: [MealType.lunch],
        carbVarietyWeight: 0,
      );
      final container = _makeContainer(
        sessionState: SessionState(
          userId: 'u1',
          groupId: 'g1',
          group: _groupWithSettings(customSettings),
        ),
      );
      addTearDown(container.dispose);

      final settings = container.read(groupSettingsProvider);

      expect(settings.weekStartDay, WeekStartDay.sunday);
      expect(settings.defaultMealSlots, [MealType.lunch]);
      expect(settings.showCarbTags, false);
    });

    test('reagiert auf session-Änderungen', () {
      final container = _makeContainer(
        sessionState: SessionState(
          userId: 'u1',
          groupId: 'g1',
          group: _groupWithSettings(GroupSettings.defaultSettings),
        ),
      );
      addTearDown(container.dispose);

      expect(container.read(groupSettingsProvider).weekStartDay,
          WeekStartDay.monday);

      // Session wird extern aktualisiert
      container.updateOverrides([
        sessionProvider.overrideWithValue(
          SessionState(
            userId: 'u1',
            groupId: 'g1',
            group: _groupWithSettings(
              GroupSettings(weekStartDay: WeekStartDay.sunday),
            ),
          ),
        ),
        groupRepositoryProvider.overrideWithValue(MockGroupRepository()),
      ]);

      expect(container.read(groupSettingsProvider).weekStartDay,
          WeekStartDay.sunday);
    });
  });

  group('GroupSettingsNotifier.update()', () {
    test('ruft groupRepository.updateSettings auf', () async {
      final repo = MockGroupRepository();
      when(() => repo.updateSettings(any(), any())).thenAnswer((_) async {});

      final container = _makeNotifierContainer(
        sessionState: SessionState(
          userId: 'u1',
          groupId: 'g1',
          group: _groupWithSettings(GroupSettings.defaultSettings),
        ),
        groupRepo: repo,
      );
      addTearDown(container.dispose);

      await container.read(groupSettingsProvider.notifier).update(
            GroupSettings(weekStartDay: WeekStartDay.sunday),
          );

      verify(() => repo.updateSettings(
            'g1',
            any(that: isA<GroupSettings>()),
          )).called(1);
    });

    test('tut nichts wenn keine Gruppe in Session', () async {
      final repo = MockGroupRepository();

      final container = _makeContainer(
        sessionState: const SessionState(userId: 'u1', groupId: null),
        groupRepo: repo,
      );
      addTearDown(container.dispose);

      await container.read(groupSettingsProvider.notifier).update(
            GroupSettings(weekStartDay: WeekStartDay.sunday),
          );

      verifyNever(() => repo.updateSettings(any(), any()));
    });
  });
}
