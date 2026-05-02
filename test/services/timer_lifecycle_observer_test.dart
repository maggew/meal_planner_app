import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/services/notification_service.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_tick_provider.dart';
import 'package:meal_planner/services/timer_lifecycle_observer.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Fakes & Mocks
// ---------------------------------------------------------------------------

class _FakeTimerNotifier extends ActiveTimerNotifier {
  @override
  Map<String, ActiveTimer> build() => {};

  void setTimers(Map<String, ActiveTimer> timers) => state = timers;
}

class _FakeTimerTick extends TimerTick {
  bool startCalled = false;
  bool stopCalled = false;

  @override
  int build() => 0;

  @override
  void start() => startCalled = true;

  @override
  void stop() => stopCalled = true;
}

class MockNotificationService extends Mock implements NotificationService {}

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _MockAudioPlayer extends Mock implements AudioPlayer {}

// ---------------------------------------------------------------------------
// Harness widget
// ---------------------------------------------------------------------------

class _ObserverHarness extends ConsumerStatefulWidget {
  const _ObserverHarness({super.key});

  @override
  ConsumerState<_ObserverHarness> createState() => _ObserverHarnessState();
}

class _ObserverHarnessState extends ConsumerState<_ObserverHarness> {
  late TimerLifecycleObserver _observer;

  @override
  void initState() {
    super.initState();
    _observer = TimerLifecycleObserver(ref);
    WidgetsBinding.instance.addObserver(_observer);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

ActiveTimer _runningTimer({String recipeId = 'r1', int stepIndex = 0}) =>
    ActiveTimer(
      recipeId: recipeId,
      stepIndex: stepIndex,
      recipeTitle: 'Test Rezept',label: 'Test',
      totalSeconds: 300,
      savedDurationSeconds: 300,
      endTime: DateTime.now().add(const Duration(seconds: 120)),
      status: TimerStatus.running,
    );

ActiveTimer _expiredTimer({String recipeId = 'r1', int stepIndex = 0}) =>
    ActiveTimer(
      recipeId: recipeId,
      stepIndex: stepIndex,
      recipeTitle: 'Test Rezept',label: 'Test',
      totalSeconds: 300,
      savedDurationSeconds: 300,
      endTime: DateTime.now().subtract(const Duration(seconds: 1)),
      status: TimerStatus.running,
    );

ActiveTimer _pausedTimer({String recipeId = 'r1', int stepIndex = 0}) =>
    ActiveTimer(
      recipeId: recipeId,
      stepIndex: stepIndex,
      recipeTitle: 'Test Rezept',label: 'Test',
      totalSeconds: 300,
      savedDurationSeconds: 300,
      pausedRemainingSeconds: 90,
      status: TimerStatus.paused,
    );

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ProviderContainer _makeContainer() => ProviderContainer(overrides: [
      activeTimerProvider.overrideWith(() => _FakeTimerNotifier()),
      timerTickProvider.overrideWith(() => _FakeTimerTick()),
    ]);

Widget _wrap(ProviderContainer container) => UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: _ObserverHarness()),
    );

Future<void> _triggerResume(WidgetTester tester) async {
  WidgetsBinding.instance
      .handleAppLifecycleStateChanged(AppLifecycleState.paused);
  WidgetsBinding.instance
      .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  await tester.pumpAndSettle();
}

_FakeTimerNotifier _fakeTimers(ProviderContainer c) =>
    c.read(activeTimerProvider.notifier) as _FakeTimerNotifier;

_FakeTimerTick _fakeTick(ProviderContainer c) =>
    c.read(timerTickProvider.notifier) as _FakeTimerTick;

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockNotificationService mockService;

  setUp(() {
    mockService = MockNotificationService();
    NotificationService.instance = mockService;

    when(() => mockService.cancelNotification(any()))
        .thenAnswer((_) async {});
    when(
      () => mockService.scheduleNotification(
        id: any(named: 'id'),
        title: any(named: 'title'),
        body: any(named: 'body'),
        scheduledTime: any(named: 'scheduledTime'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockService.playAlarmSound()).thenAnswer((_) async {});
    when(() => mockService.stopAlarmSound()).thenAnswer((_) async {});
    when(
      () => mockService.showTimerFinishedNotification(
        id: any(named: 'id'),
        recipeTitle: any(named: 'recipeTitle'),
        timerName: any(named: 'timerName'),
        payload: any(named: 'payload'),
      ),
    ).thenAnswer((_) async {});
    // Default: no active notifications (safe for tests that don't trigger expiry)
    when(() => mockService.getActiveNotificationIds())
        .thenAnswer((_) async => <int>{});
  });

  tearDown(() {
    NotificationService.instance = NotificationService.forTesting(
      plugin: _MockPlugin(),
      audioPlayer: _MockAudioPlayer(),
    );
  });

  // ==========================================================================
  // Background-Action Reconcile
  // ==========================================================================

  group('Background-Action Reconcile', () {
    testWidgets('pause Aktion → laufender Timer wird pausiert', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pending_timer_actions': ['pause:r1:0'],
      });
      final container = _makeContainer();
      addTearDown(container.dispose);
      _fakeTimers(container).setTimers({'r1:0': _runningTimer()});

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      expect(
        container.read(activeTimerProvider)['r1:0']?.status,
        TimerStatus.paused,
      );
    });

    testWidgets('resume Aktion → pausierter Timer wird fortgesetzt',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'pending_timer_actions': ['resume:r1:0'],
      });
      final container = _makeContainer();
      addTearDown(container.dispose);
      _fakeTimers(container).setTimers({'r1:0': _pausedTimer()});

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      expect(
        container.read(activeTimerProvider)['r1:0']?.status,
        TimerStatus.running,
      );
    });

    testWidgets('cancel Aktion → Timer wird aus State entfernt', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pending_timer_actions': ['cancel:r1:0'],
      });
      final container = _makeContainer();
      addTearDown(container.dispose);
      _fakeTimers(container).setTimers({'r1:0': _runningTimer()});

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      expect(
        container.read(activeTimerProvider).containsKey('r1:0'),
        isFalse,
      );
    });

    testWidgets('mehrere Aktionen werden alle angewendet', (tester) async {
      SharedPreferences.setMockInitialValues({
        'pending_timer_actions': ['pause:r1:0', 'cancel:r2:1'],
      });
      final container = _makeContainer();
      addTearDown(container.dispose);
      _fakeTimers(container).setTimers({
        'r1:0': _runningTimer(recipeId: 'r1', stepIndex: 0),
        'r2:1': _runningTimer(recipeId: 'r2', stepIndex: 1),
      });

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      expect(
        container.read(activeTimerProvider)['r1:0']?.status,
        TimerStatus.paused,
        reason: 'r1:0 muss pausiert worden sein',
      );
      expect(
        container.read(activeTimerProvider).containsKey('r2:1'),
        isFalse,
        reason: 'r2:1 muss entfernt worden sein',
      );
    });

    testWidgets('SharedPreferences-Eintrag wird nach Anwendung geleert',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'pending_timer_actions': ['cancel:r1:0'],
      });
      final container = _makeContainer();
      addTearDown(container.dispose);
      _fakeTimers(container).setTimers({'r1:0': _runningTimer()});

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('pending_timer_actions'), isNull);
    });

    testWidgets('leere Aktionsliste → State bleibt unverändert', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = _makeContainer();
      addTearDown(container.dispose);
      _fakeTimers(container).setTimers({'r1:0': _runningTimer()});

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      expect(
        container.read(activeTimerProvider)['r1:0']?.status,
        TimerStatus.running,
      );
    });

    testWidgets('fehlerhafter Payload → wird ignoriert, kein Crash',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'pending_timer_actions': ['invalid', 'cancel:', 'foo:r1:notanumber'],
      });
      final container = _makeContainer();
      addTearDown(container.dispose);
      _fakeTimers(container).setTimers({'r1:0': _runningTimer()});

      await tester.pumpWidget(_wrap(container));
      // Wirft die Implementierung hier, schlägt der Test fehl — "kein Crash" ist implizit.
      await _triggerResume(tester);

      expect(
        container.read(activeTimerProvider)['r1:0']?.status,
        TimerStatus.running,
        reason: 'Fehlerhafter Payload darf State nicht verändern',
      );
    });

    testWidgets(
        'reconcile läuft vor hasRunning-Check → pausierter Timer startet keinen Tick',
        (tester) async {
      SharedPreferences.setMockInitialValues({
        'pending_timer_actions': ['pause:r1:0'],
      });
      final container = _makeContainer();
      addTearDown(container.dispose);
      _fakeTimers(container).setTimers({'r1:0': _runningTimer()});

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      // Nach Pause-Reconcile gibt es keinen laufenden Timer mehr →
      // start() darf NICHT aufgerufen werden.
      expect(_fakeTick(container).startCalled, isFalse);
    });
  });

  // ==========================================================================
  // Notification-Dismiss beim Wischen
  // ==========================================================================

  group('Notification-Dismiss beim Wischen', () {
    testWidgets(
        'abgelaufener Timer mit weggewischter Notification → kein Sound, keine finished-Notification',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = _makeContainer();
      addTearDown(container.dispose);
      _fakeTimers(container).setTimers({'r1:0': _expiredTimer()});

      // Alarm-Notification ist nicht mehr in der Shade (wurde weggewischt)
      when(() => mockService.getActiveNotificationIds())
          .thenAnswer((_) async => <int>{});

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      verifyNever(() => mockService.playAlarmSound());
      verifyNever(() => mockService.showTimerFinishedNotification(
            id: any(named: 'id'),
            recipeTitle: any(named: 'recipeTitle'),
            timerName: any(named: 'timerName'),
            payload: any(named: 'payload'),
          ));
      expect(
        container.read(activeTimerProvider)['r1:0']?.status,
        TimerStatus.finished,
        reason: 'Timer muss trotzdem als finished markiert werden',
      );
    });

    testWidgets(
        'abgelaufener Timer mit sichtbarer Notification → Sound spielt, finished-Notification wird gezeigt',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = _makeContainer();
      addTearDown(container.dispose);

      const key = 'r1:0';
      final alarmId = NotificationService.alarmNotificationIdForKey(key);
      _fakeTimers(container).setTimers({key: _expiredTimer()});

      // Alarm-Notification ist noch sichtbar (User hat nicht gewischt)
      when(() => mockService.getActiveNotificationIds())
          .thenAnswer((_) async => {alarmId});

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      verify(() => mockService.playAlarmSound()).called(1);
      verify(() => mockService.showTimerFinishedNotification(
            id: any(named: 'id'),
            recipeTitle: any(named: 'recipeTitle'),
            timerName: any(named: 'timerName'),
            payload: key,
          )).called(1);
    });

    testWidgets(
        'zwei abgelaufene Timer: einer gewischt, einer sichtbar → Sound und Notification nur für sichtbaren',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final container = _makeContainer();
      addTearDown(container.dispose);

      const key1 = 'r1:0';
      const key2 = 'r1:1';
      final alarmId2 = NotificationService.alarmNotificationIdForKey(key2);
      _fakeTimers(container).setTimers({
        key1: _expiredTimer(recipeId: 'r1', stepIndex: 0),
        key2: _expiredTimer(recipeId: 'r1', stepIndex: 1),
      });

      // Nur key2 ist noch in der Shade
      when(() => mockService.getActiveNotificationIds())
          .thenAnswer((_) async => {alarmId2});

      await tester.pumpWidget(_wrap(container));
      await _triggerResume(tester);

      verify(() => mockService.playAlarmSound()).called(1);
      verify(() => mockService.showTimerFinishedNotification(
            id: any(named: 'id'),
            recipeTitle: any(named: 'recipeTitle'),
            timerName: any(named: 'timerName'),
            payload: key2,
          )).called(1);
      verifyNever(() => mockService.showTimerFinishedNotification(
            id: any(named: 'id'),
            recipeTitle: any(named: 'recipeTitle'),
            timerName: any(named: 'timerName'),
            payload: key1,
          ));
    });
  });
}
