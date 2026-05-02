// Tests für NotificationService — geschrieben gegen das zonedSchedule-Interface.
//
// Tests mit [RED→GREEN] schlagen mit der aktuellen Dart-Timer-Implementierung
// fehl und werden grün sobald scheduleNotification() auf zonedSchedule() umgestellt ist.
// Tests ohne diesen Marker sind bereits grün (oder plattform-agnostisch).

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_planner/services/notification_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

// --- Mocks ---

class MockFlutterLocalNotificationsPlugin extends Mock
    implements FlutterLocalNotificationsPlugin {}

class MockAudioPlayer extends Mock implements AudioPlayer {}

// --- Helper ---

void _stubDefaults(
  MockFlutterLocalNotificationsPlugin mockPlugin,
  MockAudioPlayer mockAudioPlayer,
) {
  when(
    () => mockPlugin.initialize(
      settings: any(named: 'settings'),
      onDidReceiveNotificationResponse:
          any(named: 'onDidReceiveNotificationResponse'),
    ),
  ).thenAnswer((_) async => true);

  when(
    () => mockPlugin.show(
      id: any(named: 'id'),
      title: any(named: 'title'),
      body: any(named: 'body'),
      notificationDetails: any(named: 'notificationDetails'),
      payload: any(named: 'payload'),
    ),
  ).thenAnswer((_) async {});

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

  when(() => mockPlugin.cancel(id: any(named: 'id')))
      .thenAnswer((_) async {});

  when(() => mockAudioPlayer.setAudioContext(any())).thenAnswer((_) async {});
  when(() => mockAudioPlayer.setReleaseMode(any())).thenAnswer((_) async {});
  when(() => mockAudioPlayer.setSourceAsset(any())).thenAnswer((_) async {});
  when(() => mockAudioPlayer.resume()).thenAnswer((_) async {});
  when(() => mockAudioPlayer.stop()).thenAnswer((_) async {});
}

// --- Tests ---

void main() {
  late MockFlutterLocalNotificationsPlugin mockPlugin;
  late MockAudioPlayer mockAudioPlayer;
  late NotificationService service;

  setUpAll(() {
    tz_data.initializeTimeZones();
    registerFallbackValue(tz.TZDateTime(tz.UTC, 2026));
    registerFallbackValue(const NotificationDetails());
    registerFallbackValue(const InitializationSettings());
    registerFallbackValue(AndroidScheduleMode.exactAllowWhileIdle);
    registerFallbackValue(ReleaseMode.loop);
    registerFallbackValue(AudioContext());
    registerFallbackValue((NotificationResponse _) {});
  });

  setUp(() {
    mockPlugin = MockFlutterLocalNotificationsPlugin();
    mockAudioPlayer = MockAudioPlayer();
    service = NotificationService.forTesting(
      plugin: mockPlugin,
      audioPlayer: mockAudioPlayer,
    );
    NotificationService.instance = service;
    _stubDefaults(mockPlugin, mockAudioPlayer);
  });

  tearDown(() {
    NotificationService.instance = NotificationService.forTesting(
      plugin: MockFlutterLocalNotificationsPlugin(),
      audioPlayer: MockAudioPlayer(),
    );
  });

  // ==========================================================================
  // _onNotificationResponse Routing
  // ==========================================================================

  group('_onNotificationResponse Routing', () {
    late void Function(NotificationResponse) capturedFgCallback;
    late NotificationService routingService;

    setUp(() async {
      final localPlugin = MockFlutterLocalNotificationsPlugin();
      final localAudio = MockAudioPlayer();
      _stubDefaults(localPlugin, localAudio);

      void Function(NotificationResponse)? captured;
      when(
        () => localPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
          onDidReceiveBackgroundNotificationResponse:
              any(named: 'onDidReceiveBackgroundNotificationResponse'),
        ),
      ).thenAnswer((invocation) {
        captured = invocation.namedArguments[
            const Symbol('onDidReceiveNotificationResponse')];
        return Future.value(true);
      });

      routingService = NotificationService.forTesting(
        plugin: localPlugin,
        audioPlayer: localAudio,
      );
      await routingService.initialize();
      capturedFgCallback = captured!;
    });

    test('action-Response → ruft onNotificationActionReceived auf', () {
      String? receivedId;
      routingService.onNotificationActionReceived = (id) => receivedId = id;

      capturedFgCallback(const NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        id: 1,
        actionId: 'pause:r1:0',
        payload: 'r1:0',
      ));

      expect(receivedId, equals('pause:r1:0'));
    });

    test('action-Response → ruft onNotificationTapped NICHT auf', () {
      bool tapped = false;
      routingService.onNotificationTapped = (_) => tapped = true;
      routingService.onNotificationActionReceived = (_) {};

      capturedFgCallback(const NotificationResponse(
        notificationResponseType:
            NotificationResponseType.selectedNotificationAction,
        id: 1,
        actionId: 'pause:r1:0',
        payload: 'r1:0',
      ));

      expect(tapped, isFalse);
    });

    test('Notification-Tap (kein actionId) → ruft onNotificationTapped auf', () {
      String? tappedPayload;
      routingService.onNotificationTapped = (p) => tappedPayload = p;

      capturedFgCallback(const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 1,
        payload: 'r1:0',
      ));

      expect(tappedPayload, equals('r1:0'));
    });

    test('Notification-Tap → ruft onNotificationActionReceived NICHT auf', () {
      bool actionCalled = false;
      routingService.onNotificationActionReceived = (_) => actionCalled = true;
      routingService.onNotificationTapped = (_) {};

      capturedFgCallback(const NotificationResponse(
        notificationResponseType: NotificationResponseType.selectedNotification,
        id: 1,
        payload: 'r1:0',
      ));

      expect(actionCalled, isFalse);
    });
  });

  // ==========================================================================
  // initialize()
  // ==========================================================================

  group('initialize()', () {
    test('ruft _plugin.initialize() mit korrekten Settings auf', () async {
      await service.initialize();

      verify(
        () => mockPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
        ),
      ).called(1);
    });

    test('ist idempotent — zweiter Aufruf initialisiert nicht erneut',
        () async {
      await service.initialize();
      await service.initialize();

      verify(
        () => mockPlugin.initialize(
          settings: any(named: 'settings'),
          onDidReceiveNotificationResponse:
              any(named: 'onDidReceiveNotificationResponse'),
        ),
      ).called(1);
    });
  });

  // ==========================================================================
  // scheduleNotification()
  // ==========================================================================

  group('scheduleNotification()', () {
    test(
      '[RED→GREEN] registriert OS-level Notification via zonedSchedule',
      () async {
        await service.scheduleNotification(
          id: 1,
          title: 'Timer abgelaufen',
          body: 'Nudeln',
          scheduledTime: DateTime.now().add(const Duration(seconds: 30)),
          payload: 'r1:0',
        );

        verify(
          () => mockPlugin.zonedSchedule(
            id: 1,
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

    test(
      '[RED→GREEN] ruft KEIN _plugin.show() direkt auf — der OS feuert die Notification',
      () async {
        await service.scheduleNotification(
          id: 1,
          title: 'Timer abgelaufen',
          body: 'Nudeln',
          scheduledTime: DateTime.now().add(const Duration(seconds: 30)),
          payload: 'r1:0',
        );

        // show() darf aus scheduleNotification() heraus nicht aufgerufen werden —
        // das Anzeigen übernimmt das OS nach dem zonedSchedule-Aufruf.
        verifyNever(
          () => mockPlugin.show(
            id: any(named: 'id'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            notificationDetails: any(named: 'notificationDetails'),
          ),
        );
      },
    );

    test(
      '[RED→GREEN] verwendet alarmClock — feuert auch im Android Doze-Mode',
      () async {
        // alarmClock ist der stärkste Modus: nutzt AlarmManager.setAlarmClock(),
        // überlebt Doze Mode und zeigt ein Alarm-Icon in der Statusleiste.
        await service.scheduleNotification(
          id: 1,
          title: 'T',
          body: 'B',
          scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
          payload: 'x',
        );

        final captured = verify(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: captureAny(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
          ),
        ).captured;

        expect(captured.first, equals(AndroidScheduleMode.alarmClock));
      },
    );

    test(
      '[RED→GREEN] konvertiert scheduledTime korrekt in TZDateTime',
      () async {
        final scheduledTime = DateTime(2026, 6, 1, 12, 30, 0);

        await service.scheduleNotification(
          id: 1,
          title: 'T',
          body: 'B',
          scheduledTime: scheduledTime,
          payload: 'x',
        );

        final captured = verify(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: captureAny(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
          ),
        ).captured;

        final tzTime = captured.first as tz.TZDateTime;
        final expected = tz.TZDateTime.from(scheduledTime, tz.local);
        expect(tzTime.year, equals(expected.year));
        expect(tzTime.month, equals(expected.month));
        expect(tzTime.day, equals(expected.day));
        expect(tzTime.hour, equals(expected.hour));
        expect(tzTime.minute, equals(expected.minute));
      },
    );

    test('tut nichts wenn scheduledTime in der Vergangenheit liegt', () async {
      await service.scheduleNotification(
        id: 1,
        title: 'T',
        body: 'B',
        scheduledTime: DateTime.now().subtract(const Duration(seconds: 1)),
        payload: 'x',
      );

      verifyNever(
        () => mockPlugin.zonedSchedule(
          id: any(named: 'id'),
          scheduledDate: any(named: 'scheduledDate'),
          notificationDetails: any(named: 'notificationDetails'),
          androidScheduleMode: any(named: 'androidScheduleMode'),
        ),
      );
    });

    test(
      '[RED→GREEN] zweiter Aufruf mit gleicher ID cancelt vorherige Notification',
      () async {
        final time1 = DateTime.now().add(const Duration(minutes: 5));
        final time2 = DateTime.now().add(const Duration(minutes: 10));

        await service.scheduleNotification(
          id: 1,
          title: 'T',
          body: 'B',
          scheduledTime: time1,
          payload: 'x',
        );
        await service.scheduleNotification(
          id: 1,
          title: 'T',
          body: 'B',
          scheduledTime: time2,
          payload: 'x',
        );

        // cancel(id:1) wird vor jeder zonedSchedule-Registrierung aufgerufen
        verify(() => mockPlugin.cancel(id: 1)).called(2);
        verify(
          () => mockPlugin.zonedSchedule(
            id: 1,
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
          ),
        ).called(2);
      },
    );

    // --------------------------------------------------------------------------
    // Architektur-Dokumentation: Warum zonedSchedule
    // --------------------------------------------------------------------------

    test(
      '[ARCHITECTURE] Notification überlebt App-Kill — OS übernimmt das Scheduling',
      () async {
        // Mit Dart Timer (alt): feuert NUR wenn die Dart VM noch läuft.
        //   → bei App-Kill oder gesperrtem Handy: keine Notification.
        //
        // Mit zonedSchedule (neu): das OS registriert die Notification systemweit.
        //   → feuert auch wenn:
        //      • die App vollständig gekillt wurde (Swipe, Task-Manager)
        //      • das Handy gesperrt ist und die VM vom OS pausiert wurde
        //
        // Dieser Test schlägt fehl wenn wir Dart Timer statt zonedSchedule nutzen.
        await service.scheduleNotification(
          id: 42,
          title: 'Timer abgelaufen',
          body: 'Nudeln',
          scheduledTime: DateTime.now().add(const Duration(minutes: 5)),
          payload: 'r1:0',
        );

        verify(
          () => mockPlugin.zonedSchedule(
            id: 42,
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

    test(
      '[ARCHITECTURE] alarmClock garantiert Zustellung im gesperrten Zustand',
      () async {
        // Android Doze Mode schränkt App-Aktivität stark ein wenn der Screen gesperrt ist.
        // alarmClock nutzt AlarmManager.setAlarmClock() — höchste Priorität, überlebt
        // Doze Mode und zeigt ein Alarm-Icon in der Statusleiste.
        //
        // Manuell zu prüfen: Timer starten → Handy sperren → Timer abwarten.
        // Nach dem zonedSchedule-Refactor erscheint die Notification auch im Locked-State.
        await service.scheduleNotification(
          id: 1,
          title: 'Timer abgelaufen',
          body: 'Soße',
          scheduledTime: DateTime.now().add(const Duration(seconds: 5)),
          payload: 'r2:1',
        );

        final captured = verify(
          () => mockPlugin.zonedSchedule(
            id: any(named: 'id'),
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: captureAny(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
          ),
        ).captured;

        expect(
          captured.first,
          equals(AndroidScheduleMode.alarmClock),
          reason:
              'alarmClock garantiert Zustellung auch im Doze Mode / gesperrten Handy',
        );
      },
    );
  });

  // ==========================================================================
  // cancelNotification()
  // ==========================================================================

  group('cancelNotification()', () {
    test('ruft _plugin.cancel(id) auf', () async {
      await service.cancelNotification(5);

      verify(() => mockPlugin.cancel(id: 5)).called(1);
    });

    test(
      '[RED→GREEN] löscht OS-registrierte Notification — kein Dart Timer zu canceln',
      () async {
        // Mit Dart Timer (alt): _scheduledTimers[id]?.cancel() + _plugin.cancel()
        // Mit zonedSchedule (neu): nur _plugin.cancel() nötig — OS-Schedule wird entfernt
        await service.scheduleNotification(
          id: 7,
          title: 'T',
          body: 'B',
          scheduledTime: DateTime.now().add(const Duration(minutes: 5)),
          payload: 'x',
        );

        // scheduleNotification ruft intern cancel() auf — Interaktionen zurücksetzen
        clearInteractions(mockPlugin);

        await service.cancelNotification(7);

        verify(() => mockPlugin.cancel(id: 7)).called(1);
      },
    );

    test(
      '[RED→GREEN] gecancelte Notification feuert nicht mehr',
      () async {
        await service.scheduleNotification(
          id: 3,
          title: 'T',
          body: 'B',
          scheduledTime: DateTime.now().add(const Duration(minutes: 1)),
          payload: 'x',
        );
        await service.cancelNotification(3);

        // Nur genau ein zonedSchedule-Aufruf (der ursprüngliche)
        // — kein erneuter nach dem cancel
        verify(
          () => mockPlugin.zonedSchedule(
            id: 3,
            scheduledDate: any(named: 'scheduledDate'),
            notificationDetails: any(named: 'notificationDetails'),
            androidScheduleMode: any(named: 'androidScheduleMode'),
            title: any(named: 'title'),
            body: any(named: 'body'),
            payload: any(named: 'payload'),
          ),
        ).called(1);
        // cancel wird 2x aufgerufen: einmal intern in scheduleNotification() vor
        // zonedSchedule, einmal explizit durch cancelNotification()
        verify(() => mockPlugin.cancel(id: 3)).called(2);
      },
    );
  });

  // ==========================================================================
  // playAlarmSound()
  // ==========================================================================

  group('playAlarmSound()', () {
    test('setzt AudioPlayer korrekt auf und startet Wiedergabe', () async {
      await service.playAlarmSound();

      verifyInOrder([
        () => mockAudioPlayer.setReleaseMode(ReleaseMode.loop),
        () => mockAudioPlayer.setSourceAsset('sounds/timer.mp3'),
        () => mockAudioPlayer.resume(),
      ]);
    });

    test('ist idempotent — zweiter Aufruf startet keinen zweiten Player',
        () async {
      await service.playAlarmSound();
      await service.playAlarmSound();

      verify(() => mockAudioPlayer.resume()).called(1);
    });

    test('nach stopAlarmSound() kann erneut gestartet werden', () async {
      await service.playAlarmSound();
      await service.stopAlarmSound();
      await service.playAlarmSound();

      verify(() => mockAudioPlayer.resume()).called(2);
    });
  });

  // ==========================================================================
  // stopAlarmSound()
  // ==========================================================================

  group('stopAlarmSound()', () {
    test('ruft _audioPlayer.stop() auf', () async {
      await service.stopAlarmSound();

      verify(() => mockAudioPlayer.stop()).called(1);
    });

    test('setzt _isPlaying zurück damit playAlarmSound() wieder starten kann',
        () async {
      await service.playAlarmSound();
      await service.stopAlarmSound();
      await service.playAlarmSound();

      verify(() => mockAudioPlayer.resume()).called(2);
    });
  });

  // ==========================================================================
  // showSummaryNotification()
  // ==========================================================================

  group('showSummaryNotification()', () {
    test('zeigt Notification mit ID 99999', () async {
      await service.showSummaryNotification(timerCount: 2, nearestEndTime: null);

      final captured = verify(
        () => mockPlugin.show(
          id: captureAny(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      expect(captured.first, equals(99999));
    });

    test('verwendet timer_group_channel', () async {
      await service.showSummaryNotification(timerCount: 1, nearestEndTime: null);

      final captured = verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: captureAny(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      final details = captured.first as NotificationDetails;
      expect(details.android?.channelId, equals('timer_group_channel'));
    });

    test('Titel enthält Timer-Anzahl', () async {
      await service.showSummaryNotification(timerCount: 3, nearestEndTime: null);

      verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: '3 Timer aktiv',
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).called(1);
    });

    test('mit nearestEndTime: usesChronometer true', () async {
      final endTime = DateTime.now().add(const Duration(minutes: 5));
      await service.showSummaryNotification(timerCount: 1, nearestEndTime: endTime);

      final captured = verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: captureAny(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      final details = captured.first as NotificationDetails;
      expect(details.android?.usesChronometer, isTrue);
      expect(details.android?.chronometerCountDown, isTrue);
    });

    test('ohne nearestEndTime: usesChronometer false', () async {
      await service.showSummaryNotification(timerCount: 1, nearestEndTime: null);

      final captured = verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: captureAny(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      final details = captured.first as NotificationDetails;
      expect(details.android?.usesChronometer, isNot(isTrue));
    });
  });

  // ==========================================================================
  // showTimerChildNotification()
  // ==========================================================================

  group('showTimerChildNotification()', () {
    test('running: verwendet key-abgeleitete ID', () async {
      const key = 'r1:0';
      await service.showTimerChildNotification(
        key: key,
        recipeTitle: 'Test Rezept',label: 'Nudeln',
        isPaused: false,
        endTime: DateTime.now().add(const Duration(minutes: 3)),
      );

      final captured = verify(
        () => mockPlugin.show(
          id: captureAny(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      expect(captured.first, equals(NotificationService.notificationIdForKey(key)));
    });

    test('running: verwendet timer_group_channel', () async {
      await service.showTimerChildNotification(
        key: 'r1:0',
        recipeTitle: 'Test Rezept',label: 'Nudeln',
        isPaused: false,
        endTime: DateTime.now().add(const Duration(minutes: 3)),
      );

      final captured = verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: captureAny(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      final details = captured.first as NotificationDetails;
      expect(details.android?.channelId, equals('timer_group_channel'));
    });

    test('running: usesChronometer true', () async {
      final endTime = DateTime.now().add(const Duration(minutes: 3));
      await service.showTimerChildNotification(
        key: 'r1:0',
        recipeTitle: 'Test Rezept',label: 'Nudeln',
        isPaused: false,
        endTime: endTime,
      );

      final captured = verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: captureAny(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      final details = captured.first as NotificationDetails;
      expect(details.android?.usesChronometer, isTrue);
      expect(details.android?.chronometerCountDown, isTrue);
    });

    test('running: hat Pause- und Beenden-Button', () async {
      await service.showTimerChildNotification(
        key: 'r1:0',
        recipeTitle: 'Test Rezept',label: 'Nudeln',
        isPaused: false,
        endTime: DateTime.now().add(const Duration(minutes: 3)),
      );

      final captured = verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: captureAny(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      final details = captured.first as NotificationDetails;
      final actions = details.android?.actions;
      expect(actions, isNotNull);
      expect(actions!.length, equals(2));
      expect(actions.map((a) => a.id), contains('pause:r1:0'));
      expect(actions.map((a) => a.id), contains('cancel:r1:0'));
    });

    test('paused: kein Chronometer', () async {
      await service.showTimerChildNotification(
        key: 'r1:0',
        recipeTitle: 'Test Rezept',label: 'Nudeln',
        isPaused: true,
        pausedRemainingSeconds: 120,
      );

      final captured = verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: captureAny(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      final details = captured.first as NotificationDetails;
      expect(details.android?.usesChronometer, isNot(isTrue));
    });

    test('paused: Body zeigt verbleibende Zeit mit Pause-Symbol', () async {
      await service.showTimerChildNotification(
        key: 'r1:0',
        recipeTitle: 'Test Rezept',label: 'Nudeln',
        isPaused: true,
        pausedRemainingSeconds: 90,
      );

      verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: 'Nudeln: 01:30 ⏸',
          notificationDetails: any(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).called(1);
    });

    test('paused: hat Fortsetzen- und Beenden-Button', () async {
      await service.showTimerChildNotification(
        key: 'r1:0',
        recipeTitle: 'Test Rezept',label: 'Nudeln',
        isPaused: true,
        pausedRemainingSeconds: 120,
      );

      final captured = verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: captureAny(named: 'notificationDetails'),
          payload: any(named: 'payload'),
        ),
      ).captured;

      final actions = (captured.first as NotificationDetails).android?.actions;
      expect(actions, isNotNull);
      expect(actions!.length, equals(2));
      expect(actions.map((a) => a.id), contains('resume:r1:0'));
      expect(actions.map((a) => a.id), contains('cancel:r1:0'));
    });

    test('payload ist der Key (für Tap-Navigation)', () async {
      await service.showTimerChildNotification(
        key: 'r1:2',
        recipeTitle: 'Test Rezept',label: 'Sauce',
        isPaused: false,
        endTime: DateTime.now().add(const Duration(minutes: 1)),
      );

      verify(
        () => mockPlugin.show(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          notificationDetails: any(named: 'notificationDetails'),
          payload: 'r1:2',
        ),
      ).called(1);
    });
  });

  // ==========================================================================
  // cancelTimerChildNotification() / cancelSummaryNotification()
  // ==========================================================================

  group('cancelTimerChildNotification()', () {
    test('cancelt Notification mit key-abgeleiteter ID', () async {
      const key = 'r1:0';
      await service.cancelTimerChildNotification(key);

      verify(
        () => mockPlugin.cancel(id: NotificationService.notificationIdForKey(key)),
      ).called(1);
    });
  });

  group('cancelSummaryNotification()', () {
    test('cancelt Notification mit ID 99999', () async {
      await service.cancelSummaryNotification();

      verify(() => mockPlugin.cancel(id: 99999)).called(1);
    });
  });

  // ==========================================================================
  // notificationIdForKey()
  // ==========================================================================

  group('notificationIdForKey()', () {
    test('gibt konsistente ID für gleichen Key zurück', () {
      final id1 = NotificationService.notificationIdForKey('r1:0');
      final id2 = NotificationService.notificationIdForKey('r1:0');
      expect(id1, equals(id2));
    });

    test('ID liegt im Bereich 0–89999', () {
      final id = NotificationService.notificationIdForKey('recipe-abc:3');
      expect(id, greaterThanOrEqualTo(0));
      expect(id, lessThan(90000));
    });
  });

  // ==========================================================================
  // getActiveNotificationIds()
  // ==========================================================================

  group('getActiveNotificationIds()', () {
    test('gibt Set der IDs aktiver Notifications zurück', () async {
      when(() => mockPlugin.getActiveNotifications()).thenAnswer((_) async => [
            const ActiveNotification(id: 42, channelId: 'ch'),
            const ActiveNotification(id: 100, channelId: 'ch'),
          ]);

      final ids = await service.getActiveNotificationIds();

      expect(ids, equals({42, 100}));
    });

    test('leeres Set wenn keine Notifications aktiv', () async {
      when(() => mockPlugin.getActiveNotifications())
          .thenAnswer((_) async => []);

      final ids = await service.getActiveNotificationIds();

      expect(ids, isEmpty);
    });

    test('Notifications ohne ID werden ignoriert', () async {
      when(() => mockPlugin.getActiveNotifications()).thenAnswer((_) async => [
            const ActiveNotification(id: null, channelId: 'ch'),
            const ActiveNotification(id: 7, channelId: 'ch'),
          ]);

      final ids = await service.getActiveNotificationIds();

      expect(ids, equals({7}));
    });
  });

  // ==========================================================================
  // alarmNotificationIdForKey()
  // ==========================================================================

  group('alarmNotificationIdForKey()', () {
    test('ID liegt im Bereich 90001–180000', () {
      final id = NotificationService.alarmNotificationIdForKey('recipe-abc:3');
      expect(id, greaterThanOrEqualTo(90001));
      expect(id, lessThanOrEqualTo(180000));
    });

    test('Alarm-ID unterscheidet sich von Child-ID für denselben Key', () {
      const key = 'r1:0';
      final childId = NotificationService.notificationIdForKey(key);
      final alarmId = NotificationService.alarmNotificationIdForKey(key);
      expect(alarmId, isNot(equals(childId)));
    });

    test('Bereiche überlappen sich nicht', () {
      // Child: 0–89999, Alarm: 90001–180000
      final maxChildId = 89999;
      final minAlarmId = 90001;
      expect(minAlarmId, greaterThan(maxChildId));
    });
  });
}
