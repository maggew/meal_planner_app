import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/services/notification_service.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/recipe/timer/timer_notification_controller.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fakes & Mocks
// ---------------------------------------------------------------------------

class _FakeTimerNotifier extends ActiveTimerNotifier {
  @override
  Map<String, ActiveTimer> build() => {};

  // Public test helper to directly set state without side effects
  void setTimers(Map<String, ActiveTimer> timers) => state = timers;
}

class MockNotificationService extends Mock implements NotificationService {}

class _MockPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

class _MockAudioPlayer extends Mock implements AudioPlayer {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

ActiveTimer _runningTimer({
  String recipeId = 'r1',
  int stepIndex = 0,
  String label = 'Nudeln',
  int totalSeconds = 300,
}) =>
    ActiveTimer(
      recipeId: recipeId,
      stepIndex: stepIndex,
      recipeTitle: 'Test Rezept',label: label,
      totalSeconds: totalSeconds,
      savedDurationSeconds: totalSeconds,
      endTime: DateTime.now().add(const Duration(seconds: 120)),
      status: TimerStatus.running,
    );

ActiveTimer _pausedTimer({
  String recipeId = 'r1',
  int stepIndex = 0,
  String label = 'Nudeln',
}) =>
    ActiveTimer(
      recipeId: recipeId,
      stepIndex: stepIndex,
      recipeTitle: 'Test Rezept',label: label,
      totalSeconds: 300,
      savedDurationSeconds: 300,
      pausedRemainingSeconds: 90,
      status: TimerStatus.paused,
    );

ActiveTimer _finishedTimer({String recipeId = 'r1', int stepIndex = 0}) =>
    ActiveTimer(
      recipeId: recipeId,
      stepIndex: stepIndex,
      recipeTitle: 'Test Rezept',label: 'Nudeln',
      totalSeconds: 300,
      savedDurationSeconds: 300,
      status: TimerStatus.finished,
    );

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockNotificationService mockService;
  late ProviderContainer container;
  late _FakeTimerNotifier fakeTimers;

  void _stubAll() {
    when(
      () => mockService.showSummaryNotification(
        timerCount: any(named: 'timerCount'),
        nearestEndTime: any(named: 'nearestEndTime'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockService.showTimerChildNotification(
        key: any(named: 'key'),
        recipeTitle: any(named: 'recipeTitle'),
        label: any(named: 'label'),
        isPaused: any(named: 'isPaused'),
        endTime: any(named: 'endTime'),
        pausedRemainingSeconds: any(named: 'pausedRemainingSeconds'),
      ),
    ).thenAnswer((_) async {});
    when(() => mockService.cancelTimerChildNotification(any()))
        .thenAnswer((_) async {});
    when(() => mockService.cancelSummaryNotification())
        .thenAnswer((_) async {});
  }

  setUp(() {
    mockService = MockNotificationService();
    NotificationService.instance = mockService;
    _stubAll();

    container = ProviderContainer(overrides: [
      activeTimerProvider.overrideWith(() => _FakeTimerNotifier()),
    ]);

    container.read(timerNotificationControllerProvider);
    fakeTimers = container.read(activeTimerProvider.notifier) as _FakeTimerNotifier;
  });

  tearDown(() {
    container.dispose();
    NotificationService.instance = NotificationService.forTesting(
      plugin: _MockPlugin(),
      audioPlayer: _MockAudioPlayer(),
    );
  });

  // ==========================================================================
  // Leerstart
  // ==========================================================================

  group('Leerstart', () {
    test('keine Notifications bei leerem Zustand', () {
      verifyNever(
        () => mockService.showSummaryNotification(
          timerCount: any(named: 'timerCount'),
          nearestEndTime: any(named: 'nearestEndTime'),
        ),
      );
      verifyNever(
        () => mockService.showTimerChildNotification(
          key: any(named: 'key'),
          recipeTitle: any(named: 'recipeTitle'),
          label: any(named: 'label'),
          isPaused: any(named: 'isPaused'),
          endTime: any(named: 'endTime'),
          pausedRemainingSeconds: any(named: 'pausedRemainingSeconds'),
        ),
      );
    });
  });

  // ==========================================================================
  // Timer startet
  // ==========================================================================

  group('Timer startet', () {
    test('zeigt Kind-Notification und Summary wenn Timer läuft', () {
      final key = 'r1:0';
      fakeTimers.setTimers({key: _runningTimer()});

      verify(
        () => mockService.showTimerChildNotification(
          key: key,
          recipeTitle: any(named: 'recipeTitle'),
          label: any(named: 'label'),
          isPaused: false,
          endTime: any(named: 'endTime'),
          pausedRemainingSeconds: any(named: 'pausedRemainingSeconds'),
        ),
      ).called(1);

      verify(
        () => mockService.showSummaryNotification(
          timerCount: 1,
          nearestEndTime: any(named: 'nearestEndTime'),
        ),
      ).called(1);
    });

    test('mehrere Timer → Summary zeigt korrekte Anzahl', () {
      fakeTimers.setTimers({
        'r1:0': _runningTimer(recipeId: 'r1', stepIndex: 0),
        'r2:1': _runningTimer(recipeId: 'r2', stepIndex: 1),
      });

      verify(
        () => mockService.showSummaryNotification(
          timerCount: 2,
          nearestEndTime: any(named: 'nearestEndTime'),
        ),
      ).called(1);

      verify(
        () => mockService.showTimerChildNotification(
          key: any(named: 'key'),
          recipeTitle: any(named: 'recipeTitle'),
          label: any(named: 'label'),
          isPaused: any(named: 'isPaused'),
          endTime: any(named: 'endTime'),
          pausedRemainingSeconds: any(named: 'pausedRemainingSeconds'),
        ),
      ).called(2);
    });
  });

  // ==========================================================================
  // Timer pausiert / fortgesetzt
  // ==========================================================================

  group('Pause / Resume', () {
    test('pausierter Timer → Kind-Notification mit isPaused: true', () {
      const key = 'r1:0';
      fakeTimers.setTimers({key: _runningTimer()});
      clearInteractions(mockService);

      fakeTimers.setTimers({key: _pausedTimer()});

      verify(
        () => mockService.showTimerChildNotification(
          key: key,
          recipeTitle: any(named: 'recipeTitle'),
          label: any(named: 'label'),
          isPaused: true,
          endTime: any(named: 'endTime'),
          pausedRemainingSeconds: any(named: 'pausedRemainingSeconds'),
        ),
      ).called(1);
    });

    test('fortgesetzter Timer → Kind-Notification mit isPaused: false', () {
      const key = 'r1:0';
      fakeTimers.setTimers({key: _pausedTimer()});
      clearInteractions(mockService);

      fakeTimers.setTimers({key: _runningTimer()});

      verify(
        () => mockService.showTimerChildNotification(
          key: key,
          recipeTitle: any(named: 'recipeTitle'),
          label: any(named: 'label'),
          isPaused: false,
          endTime: any(named: 'endTime'),
          pausedRemainingSeconds: any(named: 'pausedRemainingSeconds'),
        ),
      ).called(1);
    });
  });

  // ==========================================================================
  // Timer abgebrochen
  // ==========================================================================

  group('Timer abgebrochen', () {
    test('letzter Timer entfernt → Kind-Notification und Summary canceln', () {
      const key = 'r1:0';
      fakeTimers.setTimers({key: _runningTimer()});
      clearInteractions(mockService);

      fakeTimers.setTimers({});

      verify(() => mockService.cancelTimerChildNotification(key)).called(1);
      verify(() => mockService.cancelSummaryNotification()).called(1);
    });

    test('einer von zwei Timern entfernt → nur dessen Kind-Notification canceln', () {
      const key1 = 'r1:0';
      const key2 = 'r2:1';
      fakeTimers.setTimers({
        key1: _runningTimer(recipeId: 'r1', stepIndex: 0),
        key2: _runningTimer(recipeId: 'r2', stepIndex: 1),
      });
      clearInteractions(mockService);

      fakeTimers.setTimers({key2: _runningTimer(recipeId: 'r2', stepIndex: 1)});

      verify(() => mockService.cancelTimerChildNotification(key1)).called(1);
      verifyNever(() => mockService.cancelTimerChildNotification(key2));
      verifyNever(() => mockService.cancelSummaryNotification());
    });
  });

  // ==========================================================================
  // Timer abgelaufen
  // ==========================================================================

  group('Timer abgelaufen', () {
    test('abgelaufener Timer → Kind-Notification canceln', () {
      const key = 'r1:0';
      fakeTimers.setTimers({key: _runningTimer()});
      clearInteractions(mockService);

      fakeTimers.setTimers({key: _finishedTimer()});

      verify(() => mockService.cancelTimerChildNotification(key)).called(1);
    });

    test('abgelaufener Timer (letzter aktiver) → Summary ebenfalls canceln', () {
      const key = 'r1:0';
      fakeTimers.setTimers({key: _runningTimer()});
      clearInteractions(mockService);

      fakeTimers.setTimers({key: _finishedTimer()});

      verify(() => mockService.cancelSummaryNotification()).called(1);
    });

    test('abgelaufener Timer aber anderer noch aktiv → Summary bleibt', () {
      const key1 = 'r1:0';
      const key2 = 'r2:1';
      fakeTimers.setTimers({
        key1: _runningTimer(recipeId: 'r1', stepIndex: 0),
        key2: _runningTimer(recipeId: 'r2', stepIndex: 1),
      });
      clearInteractions(mockService);

      fakeTimers.setTimers({
        key1: _finishedTimer(recipeId: 'r1', stepIndex: 0),
        key2: _runningTimer(recipeId: 'r2', stepIndex: 1),
      });

      verify(() => mockService.cancelTimerChildNotification(key1)).called(1);
      verifyNever(() => mockService.cancelSummaryNotification());
      verify(
        () => mockService.showSummaryNotification(
          timerCount: 1,
          nearestEndTime: any(named: 'nearestEndTime'),
        ),
      ).called(1);
    });
  });
}
