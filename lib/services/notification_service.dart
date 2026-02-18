import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Map<int, Timer> _scheduledTimers = {};

  void Function(String payload)? onNotificationTapped;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    _initialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    onNotificationTapped?.call(payload);
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required String payload,
  }) async {
    final delay = scheduledTime.difference(DateTime.now());
    if (delay.isNegative) return;

    // Vorherigen Timer mit gleicher ID canceln falls vorhanden
    _scheduledTimers[id]?.cancel();

    _scheduledTimers[id] = Timer(delay, () {
      _plugin.show(
        id: id,
        title: title,
        body: body,
        payload: payload,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'timer_channel',
            'Koch-Timer',
            channelDescription: 'Benachrichtigungen für Koch-Timer',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      playAlarmSound();
      _scheduledTimers.remove(id);
    });
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  Future<void> cancelNotification(int id) async {
    _scheduledTimers[id]?.cancel();
    _scheduledTimers.remove(id);
    await _plugin.cancel(id: id);
  }

  Future<void> playAlarmSound() async {
    if (_isPlaying) return;
    _isPlaying = true;
    await _audioPlayer.setReleaseMode(ReleaseMode.loop);
    await _audioPlayer.setSourceAsset('sounds/timer.mp3');
    await _audioPlayer.resume();
  }

  Future<void> stopAlarmSound() async {
    _isPlaying = false;
    await _audioPlayer.stop();
  }
}
