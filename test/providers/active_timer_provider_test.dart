// Tests für ActiveTimerNotifier — geschrieben gegen das zonedSchedule-Interface.
//
// Tests mit [RED→GREEN] schlagen mit der aktuellen Dart-Timer-Implementierung
// fehl und werden grün sobald NotificationService.scheduleNotification() auf
// zonedSchedule() umgestellt ist.

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/domain/entities/active_timer.dart';
import 'package:meal_planner/domain/entities/recipe_timer.dart';
import 'package:meal_planner/domain/repositories/recipe_repository.dart';
import 'package:meal_planner/services/notification_service.dart';
import 'package:meal_planner/services/providers/recipe/timer/active_timer_provider.dart';
import 'package:meal_planner/services/providers/repository_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// --- Mocks ---

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAudioPlayer extends Mock implements AudioPlayer {}

class MockRecipeRepository extends Mock implements RecipeRepository {}

// --- Helper ---

/// scheduleNotification ist async, aber startTimer/resumeTimer/addMinute
/// awaiten es nicht. Microtask Queue pumpen damit zonedSchedule ausgeführt wird.
Future<void> pumpAsync() => Future.delayed(Duration.zero);

ProviderContainer _makeContainer(MockRecipeRepository mockRepo) {
  return ProviderContainer(
    overrides: [
      recipeRepositoryProvider.overrideWithValue(mockRepo),
    ],
  );
}

void _stubNotificationDefaults(
  MockFlutterLocalNotificationsPlugin mockPlugin,
  MockAudioPlayer mockAudioPlayer,
) {
  when(
    () => mockPlugin.zonedSchedule(
      id: any(named: 'id'),
      scheduledDate: any(named: 'scheduledDate'),
      notificationDetails: any(named: 'notificationDetails'),
      androidScheduleMode: any(named: 'androidScheduleMode'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      payload: any(named: 'payload'),
    ),
  ).thenAnswer((_) async {});

  when(
    () => mockPlugin.show(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      notificationDetails: any(named: 'notificationDetails'),
      payload: any(named: 'payload'),
    ),
  ).thenAnswer((_) async {});

  when(() => mockPlugin.cancel(id: any(named: 'id')))
      .thenAnswer((_) async {});

  when(() => mockAudioPlayer.setReleaseMode(any())).thenAnswer((_) async {});
  when(() => mockAudioPlayer.setSourceAsset(any())).thenAnswer((_) async {});
  when(() => mockAudioPlayer.resume()).thenAnswer((_) async {});
  when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
}

// --- Tests ---

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAudioPlayer mockAudioPlayer;
  late MockRecipeRepository mockRepo;

  setUpAll(() {
    tz_data.initializeTimeZones();
    registerFallbackValue(tz.TZDateTime(tz.UTC, 2026));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(ReleaseMode.loop);
    registerFallbackValue((NotificationResponse _) {});
    registerFallbackValue(
      RecipeTimer(recipeId: '', stepIndex: 0, timerName: '', durationSeconds: 0),
    );
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAudioPlayer = MockAudioPlayer();
    mockRepo = MockRecipeRepository();

    NotificationService.instance = NotificationService.forTesting(
      plugin: mockPlugin,
      audioPlayer: mockAudioPlayer,
    );
    _stubNotificationDefaults(mockPlugin, mockAudioPlayer);

    when(() => mockRepo.upsertTimer(any())).thenAnswer(
      (_) async => RecipeTimer(
        recipeId: 'r1',
        stepIndex: 0,
        timerName: 'T',
        durationSeconds: 60,
      ),
    );
  });

  tearDown(() {
    NotificationService.instance = NotificationService.forTesting(
      plugin: MockFlutterLocalNotificationsPlugin(),
      audioPlayer: MockAudioPlayer(),
    );
  });

  // ==========================================================================
  // startTimer()
  // ==========================================================================

  group('startTimer()', () {
    test('fügt Timer mit status=running in den State ein', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'Nudeln',
            durationSeconds: 60,
          );

      final timer = container.read(activeTimerProvider)['r1:0'];
      expect(timer, isNotNull);
      expect(timer!.status, equals(TimerStatus.running));
      expect(timer.label, equals('Nudeln'));
      expect(timer.totalSeconds, equals(60));
    });

    test('endTime liegt in der Zukunft (jetzt + durationSeconds)', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      final before = DateTime.now();
      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'Nudeln',
            durationSeconds: 60,
          );
      final after = DateTime.now();

      final timer = container.read(activeTimerProvider)['r1:0']!;
      expect(timer.endTime, isNotNull);
      expect(
        timer.endTime!.isAfter(before.add(const Duration(seconds: 59))),
        isTrue,
      );
      expect(
        timer.endTime!.isBefore(after.add(const Duration(seconds: 61))),
        isTrue,
      );
    });

    test(
      '[RED→GREEN] ruft scheduleNotification() auf, das zonedSchedule registriert',
      () async {
        final container = _makeContainer(mockRepo);
        addTearDown(container.dispose);

        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 0,
              label: 'Nudeln',
              durationSeconds: 60,
            );
        await pumpAsync();

        // scheduleNotification() → zonedSchedule() — OS-level, überlebt App-Kill
        verify(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: 'Timer abgelaufen',
            body: 'Nudeln',
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            payload: 'r1:0',
          ),
        ).called(1);
      },
    );

    test('zweiter startTimer() mit gleichem Key überschreibt bestehenden', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'Nudeln',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'Nudeln (neu)',
            durationSeconds: 120,
          );

      final state = container.read(activeTimerProvider);
      expect(state.length, equals(1));
      expect(state['r1:0']!.totalSeconds, equals(120));
    });

    test('Key ist recipeId:stepIndex', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'rezept-abc',
            stepIndex: 3,
            label: 'T',
            durationSeconds: 30,
          );

      expect(
        container.read(activeTimerProvider).containsKey('rezept-abc:3'),
        isTrue,
      );
    });
  });

  // ==========================================================================
  // pauseTimer()
  // ==========================================================================

  group('pauseTimer()', () {
    test('wechselt Status zu paused und speichert verbleibende Sekunden', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');

      final timer = container.read(activeTimerProvider)['r1:0']!;
      expect(timer.status, equals(TimerStatus.paused));
      expect(timer.pausedRemainingSeconds, isNotNull);
      expect(timer.pausedRemainingSeconds, greaterThan(0));
    });

    test('endTime wird beim Pausieren geleert', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');

      expect(container.read(activeTimerProvider)['r1:0']!.endTime, isNull);
    });

    test('ruft cancelNotification() auf', () async {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      await pumpAsync();
      final notifId =
          container.read(activeTimerProvider)['r1:0']!.notificationId;

      clearInteractions(mockPlugin);
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');

      verify(() => mockPlugin.cancel(id: notifId)).called(1);
    });

    test('ist No-op wenn Timer bereits paused ist', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');

      // Status nach erstem pause
      final statusAfterFirstPause =
          container.read(activeTimerProvider)['r1:0']!.status;

      clearInteractions(mockPlugin);

      // Zweites pauseTimer — bereits paused → No-op
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');

      verifyNever(() => mockPlugin.cancel(id: any(named: 'id')));
      expect(statusAfterFirstPause, equals(TimerStatus.paused));
    });
  });

  // ==========================================================================
  // resumeTimer()
  // ==========================================================================

  group('resumeTimer()', () {
    test('wechselt Status zurück zu running mit neuer endTime', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');
      container.read(activeTimerProvider.notifier).resumeTimer('r1:0');

      final timer = container.read(activeTimerProvider)['r1:0']!;
      expect(timer.status, equals(TimerStatus.running));
      expect(timer.endTime, isNotNull);
      expect(timer.endTime!.isAfter(DateTime.now()), isTrue);
    });

    test('pausedRemainingSeconds wird nach resume geleert', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');
      container.read(activeTimerProvider.notifier).resumeTimer('r1:0');

      expect(
        container.read(activeTimerProvider)['r1:0']!.pausedRemainingSeconds,
        isNull,
      );
    });

    test(
      '[RED→GREEN] plant neue Notification via zonedSchedule nach resume',
      () async {
        final container = _makeContainer(mockRepo);
        addTearDown(container.dispose);

        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 0,
              label: 'Nudeln',
              durationSeconds: 60,
            );
        await pumpAsync();
        container.read(activeTimerProvider.notifier).pauseTimer('r1:0');

        clearInteractions(mockPlugin);

        container.read(activeTimerProvider.notifier).resumeTimer('r1:0');
        await pumpAsync();

        verify(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: 'Timer abgelaufen',
            body: 'Nudeln',
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            payload: 'r1:0',
          ),
        ).called(1);
      },
    );

    test('ist No-op wenn Timer nicht paused ist (Status: running)', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );

      clearInteractions(mockPlugin);

      // Timer ist running, nicht paused → resumeTimer ist No-op
      container.read(activeTimerProvider.notifier).resumeTimer('r1:0');

      verifyNever(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      );
    });

    test('ist No-op wenn pausedRemainingSeconds == 0', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 0,
          );
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');

      clearInteractions(mockPlugin);
      container.read(activeTimerProvider.notifier).resumeTimer('r1:0');

      expect(
        container.read(activeTimerProvider)['r1:0']!.status,
        equals(TimerStatus.paused),
      );
    });
  });

  // ==========================================================================
  // cancelTimer()
  // ==========================================================================

  group('cancelTimer()', () {
    test('entfernt Timer aus dem State', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).cancelTimer('r1:0');

      expect(container.read(activeTimerProvider).containsKey('r1:0'), isFalse);
    });

    test('ruft cancelNotification() auf', () async {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      await pumpAsync();
      final notifId =
          container.read(activeTimerProvider)['r1:0']!.notificationId;

      clearInteractions(mockPlugin);
      container.read(activeTimerProvider.notifier).cancelTimer('r1:0');

      verify(() => mockPlugin.cancel(id: notifId)).called(1);
    });

    test(
      '[RED→GREEN] OS-Cancel verhindert Notification-Feuer — kein Dart Timer der noch läuft',
      () async {
        // Mit Dart Timer (alt): _scheduledTimers[id]?.cancel() — aber nur wenn VM läuft.
        // Mit zonedSchedule (neu): _plugin.cancel() entfernt den OS-Schedule atomar.
        final container = _makeContainer(mockRepo);
        addTearDown(container.dispose);

        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 0,
              label: 'T',
              durationSeconds: 60,
            );
        await pumpAsync();
        final notifId =
            container.read(activeTimerProvider)['r1:0']!.notificationId;

        clearInteractions(mockPlugin);
        container.read(activeTimerProvider.notifier).cancelTimer('r1:0');

        verify(() => mockPlugin.cancel(id: notifId)).called(1);
        expect(
          container.read(activeTimerProvider).containsKey('r1:0'),
          isFalse,
        );
      },
    );

    test('löscht nur den angegebenen Timer, andere bleiben erhalten', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'A',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 1,
            label: 'B',
            durationSeconds: 60,
          );

      container.read(activeTimerProvider.notifier).cancelTimer('r1:0');

      expect(container.read(activeTimerProvider).containsKey('r1:0'), isFalse);
      expect(container.read(activeTimerProvider).containsKey('r1:1'), isTrue);
    });
  });

  // ==========================================================================
  // markAsFinished()
  // ==========================================================================

  group('markAsFinished()', () {
    test('setzt Status auf finished und leert endTime', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).markAsFinished('r1:0');

      final timer = container.read(activeTimerProvider)['r1:0']!;
      expect(timer.status, equals(TimerStatus.finished));
      expect(timer.endTime, isNull);
    });

    test('ruft cancelNotification() auf — in-app UI übernimmt jetzt', () async {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      await pumpAsync();
      final notifId =
          container.read(activeTimerProvider)['r1:0']!.notificationId;

      clearInteractions(mockPlugin);
      container.read(activeTimerProvider.notifier).markAsFinished('r1:0');

      verify(() => mockPlugin.cancel(id: notifId)).called(1);
    });
  });

  // ==========================================================================
  // dismissFinished()
  // ==========================================================================

  group('dismissFinished()', () {
    test('entfernt finished Timer aus dem State', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).markAsFinished('r1:0');
      container.read(activeTimerProvider.notifier).dismissFinished('r1:0');

      expect(container.read(activeTimerProvider).containsKey('r1:0'), isFalse);
    });

    test(
      'ruft stopAlarmSound() auf wenn kein weiterer finished Timer mehr existiert',
      () {
        final container = _makeContainer(mockRepo);
        addTearDown(container.dispose);

        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 0,
              label: 'T',
              durationSeconds: 60,
            );
        container.read(activeTimerProvider.notifier).markAsFinished('r1:0');

        clearInteractions(mockAudioPlayer);
        container.read(activeTimerProvider.notifier).dismissFinished('r1:0');

        verify(() => mockAudioPlayer.stop()).called(1);
      },
    );

    test(
      'ruft stopAlarmSound() NICHT auf wenn noch andere finished Timer existieren',
      () {
        final container = _makeContainer(mockRepo);
        addTearDown(container.dispose);

        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 0,
              label: 'A',
              durationSeconds: 60,
            );
        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 1,
              label: 'B',
              durationSeconds: 60,
            );
        container.read(activeTimerProvider.notifier).markAsFinished('r1:0');
        container.read(activeTimerProvider.notifier).markAsFinished('r1:1');

        clearInteractions(mockAudioPlayer);

        // Ersten dismissen — zweiter ist noch finished → kein stopAlarmSound
        container.read(activeTimerProvider.notifier).dismissFinished('r1:0');
        verifyNever(() => mockAudioPlayer.stop());

        // Zweiten dismissen — jetzt kein finished mehr → stopAlarmSound
        container.read(activeTimerProvider.notifier).dismissFinished('r1:1');
        verify(() => mockAudioPlayer.stop()).called(1);
      },
    );
  });

  // ==========================================================================
  // checkExpiredTimers()
  // ==========================================================================

  group('checkExpiredTimers()', () {
    test('markiert nicht-abgelaufene Timer nicht als finished', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 3600, // 1 Stunde
          );

      container.read(activeTimerProvider.notifier).checkExpiredTimers();

      expect(
        container.read(activeTimerProvider)['r1:0']!.status,
        equals(TimerStatus.running),
      );
    });

    test(
      'markiert abgelaufene Timer als finished',
      () async {
        final container = _makeContainer(mockRepo);
        addTearDown(container.dispose);

        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 0,
              label: 'T',
              durationSeconds: 0,
            );

        // Minimal warten damit endTime wirklich in der Vergangenheit liegt
        await Future.delayed(const Duration(milliseconds: 10));

        container.read(activeTimerProvider.notifier).checkExpiredTimers();

        expect(
          container.read(activeTimerProvider)['r1:0']!.status,
          equals(TimerStatus.finished),
        );
      },
    );

    test('ruft playAlarmSound() auf wenn Timer abläuft', () async {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 0,
          );

      await Future.delayed(const Duration(milliseconds: 10));

      // _isPlaying zurücksetzen — der 0s-Dart-Timer könnte schon gefeuert haben
      // und den Flag gesetzt haben, bevor wir checkExpiredTimers() aufrufen.
      await NotificationService.instance.stopAlarmSound();
      clearInteractions(mockAudioPlayer);

      container.read(activeTimerProvider.notifier).checkExpiredTimers();
      // playAlarmSound() ist async — Microtask Queue pumpen damit alle awaits laufen
      await Future.delayed(Duration.zero);

      verify(() => mockAudioPlayer.setSourceAsset('sounds/timer.mp3')).called(1);
    });

    test(
      '[RED→GREEN] OS-Notification wurde bereits beim Start registriert — überlebt App-Kill',
      () async {
        // Mit zonedSchedule (neu): die Notification wird bei startTimer() vom OS registriert.
        // checkExpiredTimers() ist nur noch für den in-app State (UI-Update, Alarm-Sound) zuständig.
        // Die OS-Notification feuert unabhängig davon ob die VM läuft.
        //
        // Mit Dart Timer (alt): ohne laufende VM passiert nichts — weder Notification noch Alarm.
        final container = _makeContainer(mockRepo);
        addTearDown(container.dispose);

        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 0,
              label: 'Nudeln',
              durationSeconds: 5,
            );
        await pumpAsync();

        // zonedSchedule wurde beim startTimer() registriert
        verify(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: 'Timer abgelaufen',
            body: 'Nudeln',
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            payload: 'r1:0',
          ),
        ).called(1);
      },
    );
  });

  // ==========================================================================
  // addMinute()
  // ==========================================================================

  group('addMinute()', () {
    test('(running) verlängert totalSeconds und endTime um 60s', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      final oldEndTime = container.read(activeTimerProvider)['r1:0']!.endTime!;

      container.read(activeTimerProvider.notifier).addMinute('r1:0');

      final timer = container.read(activeTimerProvider)['r1:0']!;
      expect(timer.totalSeconds, equals(120));
      expect(
        timer.endTime!.isAfter(oldEndTime.add(const Duration(seconds: 59))),
        isTrue,
      );
    });

    test(
      '[RED→GREEN] (running) cancelt alte Notification und plant neue via zonedSchedule',
      () async {
        final container = _makeContainer(mockRepo);
        addTearDown(container.dispose);

        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 0,
              label: 'Nudeln',
              durationSeconds: 60,
            );
        await pumpAsync();
        final notifId =
            container.read(activeTimerProvider)['r1:0']!.notificationId;

        clearInteractions(mockPlugin);
        container.read(activeTimerProvider.notifier).addMinute('r1:0');
        await pumpAsync();

        // Alte OS-Notification canceln (einmal durch cancelNotification, einmal durch scheduleNotification intern)
        verify(() => mockPlugin.cancel(id: notifId)).called(2);
        // Neue OS-Notification mit verlängerter endTime registrieren
        verify(
          () => mockPlugin.zonedSchedule(
            id: notifId,
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
          ),
        ).called(1);
      },
    );

    test('(paused) verlängert pausedRemainingSeconds um 60s', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');
      final remaining =
          container.read(activeTimerProvider)['r1:0']!.pausedRemainingSeconds!;

      container.read(activeTimerProvider.notifier).addMinute('r1:0');

      final timer = container.read(activeTimerProvider)['r1:0']!;
      expect(timer.pausedRemainingSeconds, equals(remaining + 60));
      expect(timer.totalSeconds, equals(120));
    });

    test('(paused) plant keine neue Notification', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'T',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).pauseTimer('r1:0');

      clearInteractions(mockPlugin);
      container.read(activeTimerProvider.notifier).addMinute('r1:0');

      verifyNever(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      );
    });

    test('(finished) stoppt Alarm und startet neuen 60s-Timer', () {
      final container = _makeContainer(mockRepo);
      addTearDown(container.dispose);

      container.read(activeTimerProvider.notifier).startTimer(
            recipeId: 'r1',
            stepIndex: 0,
            label: 'Nudeln',
            durationSeconds: 60,
          );
      container.read(activeTimerProvider.notifier).markAsFinished('r1:0');

      clearInteractions(mockPlugin);
      clearInteractions(mockAudioPlayer);

      container.read(activeTimerProvider.notifier).addMinute('r1:0');

      verify(() => mockAudioPlayer.stop()).called(1);
      final timer = container.read(activeTimerProvider)['r1:0']!;
      expect(timer.status, equals(TimerStatus.running));
      expect(timer.totalSeconds, equals(60));
    });

    test(
      '[RED→GREEN] (finished) neuer 60s-Timer registriert OS-Notification via zonedSchedule',
      () async {
        final container = _makeContainer(mockRepo);
        addTearDown(container.dispose);

        container.read(activeTimerProvider.notifier).startTimer(
              recipeId: 'r1',
              stepIndex: 0,
              label: 'Nudeln',
              durationSeconds: 60,
            );
        await pumpAsync();
        container.read(activeTimerProvider.notifier).markAsFinished('r1:0');

        clearInteractions(mockPlugin);

        container.read(activeTimerProvider.notifier).addMinute('r1:0');
        await pumpAsync();

        verify(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            title: 'Timer abgelaufen',
            body: 'Nudeln',
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: AndroidScheduleMode.alarmClock,
            payload: 'r1:0',
          ),
        ).called(1);
      },
    );
  });
}
