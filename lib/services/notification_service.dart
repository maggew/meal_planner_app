import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static NotificationService _instance = NotificationService._();
  static NotificationService get instance => _instance;

  @visibleForTesting
  static set instance(NotificationService value) => _instance = value;

  NotificationService._()
      : _plugin = FlutterLocalNotificationsPlugin(),
        _audioPlayer = AudioPlayer();

  @visibleForTesting
  NotificationService.forTesting({
    required FlutterLocalNotificationsPlugin plugin,
    required AudioPlayer audioPlayer,
  })  : _plugin = plugin,
        _audioPlayer = audioPlayer;

  static const int _ongoingNotificationId = 99999;

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer;

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

    // Vorherige Notification mit gleicher ID canceln falls vorhanden
    await _plugin.cancel(id: id);

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_alarm_channel_v3',
          'Koch-Timer Alarm',
          channelDescription: 'Alarm wenn ein Koch-Timer abgelaufen ist',
          importance: Importance.max,
          priority: Priority.high,
          sound: const RawResourceAndroidNotificationSound('timer_alarm'),
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          additionalFlags: Int32List.fromList([4]), // FLAG_INSISTENT
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();

    final canSchedule = await android?.canScheduleExactNotifications();
    if (canSchedule == false) {
      await android?.requestExactAlarmsPermission();
    }
  }

  Future<void> cancelNotification(int id) async {
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

  Future<void> showOngoingTimerNotification(
    List<String> timerLines, {
    DateTime? nearestEndTime,
  }) async {
    final hasChronometer = nearestEndTime != null;

    await _plugin.show(
      id: _ongoingNotificationId,
      title: 'Timer läuft (${timerLines.length})',
      body: timerLines.first,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'timer_ongoing_channel',
          'Laufende Timer',
          channelDescription: 'Zeigt laufende Koch-Timer an',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: hasChronometer,
          usesChronometer: hasChronometer,
          chronometerCountDown: hasChronometer,
          when: nearestEndTime?.millisecondsSinceEpoch,
          styleInformation: InboxStyleInformation(
            timerLines,
            contentTitle: 'Timer läuft (${timerLines.length})',
            summaryText: '${timerLines.length} aktive Timer',
          ),
        ),
      ),
    );
  }

  Future<void> cancelOngoingTimerNotification() async {
    await _plugin.cancel(id: _ongoingNotificationId);
  }
}
